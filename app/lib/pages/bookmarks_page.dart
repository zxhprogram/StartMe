import 'dart:async'; // 引入 Timer
import 'dart:math';
import 'package:app/api/bookmark_service_api.dart';
import 'package:flutter/material.dart' show Material;
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:signals/signals_flutter.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class BookmarkItemWithIndex {
  BookmarkItem item;

  // 假定你可能需要一个字段来存储它内部是不是包含了多个书签（文件夹模式）
  List<BookmarkItem>? children;

  BookmarkItemWithIndex({required this.item, this.children});

  @override
  String toString() {
    return '{item = $item},children = $children}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookmarkItemWithIndex) return false;
    return item == other.item;
  }

  @override
  int get hashCode => item.hashCode;
}

class WillMergeItem {
  int targetIndex;
  BookmarkItem item;
  WillMergeItem({required this.targetIndex, required this.item});
  @override
  String toString() {
    return '{targetIndex = $targetIndex,item = $item}';
  }
}

class _BookmarksPageState extends State<BookmarksPage> {
  final _bookmarksState = signal<List<BookmarkItemWithIndex>>([]);

  // 用于控制 1 秒悬浮的定时器
  Timer? _hoverTimer;
  // 用于标记本次拖拽是否已经触发了合并，防止松手时又触发重排
  bool _hasMerged = false;
  // 用于备份拖拽事件开始之前的所有的数据
  List<BookmarkItemWithIndex> _backupBookmarks = [];
  final _willMergeItem = signal<WillMergeItem?>(null);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    var r = await bookmarkList();
    _bookmarksState.value = r.data
        .map((e) => BookmarkItemWithIndex(item: e))
        .toList();
  }

  // ==== 核心业务逻辑：合并 ====
  void _mergeItems(BookmarkItemWithIndex source, BookmarkItemWithIndex target) {
    print('触发合并逻辑：${source.item.name} 合并到 ${target.item.name}');

    var currentList = List<BookmarkItemWithIndex>.from(_bookmarksState.value);
    var targetIndex = currentList.indexWhere(
      (e) => e.item.name == target.item.name,
    );
    if (targetIndex != -1) {
      _willMergeItem.value = WillMergeItem(
        targetIndex: targetIndex,
        item: source.item,
      );
    }
  }

  // ==== 核心业务逻辑：排序 ====
  void _reorderItems(
    BookmarkItemWithIndex source,
    BookmarkItemWithIndex target,
  ) {
    print('触发重排逻辑：${source.item.name} 移动到 ${target.item.name}');

    var currentList = List<BookmarkItemWithIndex>.from(_bookmarksState.value);

    // 1. 获取两者的当前真实索引
    int sourceIndex = currentList.indexOf(source);
    int targetIndex = currentList.indexOf(target);

    if (sourceIndex == -1 || targetIndex == -1) return;

    // 2. 移除源元素
    var removedItem = currentList.removeAt(sourceIndex);

    // 3. 插入到目标位置
    currentList.insert(targetIndex, removedItem);

    _bookmarksState.value = currentList;
  }

  @override
  Widget build(BuildContext context) {
    var bookmarks = _bookmarksState.watch(context);
    var willMergeItem = _willMergeItem.watch(context);

    return Scaffold(
      floatingFooter: true,
      footers: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Button.text(
              onPressed: () => context.go('/'),
              child: const Icon(BootstrapIcons.houseFill, size: 24),
            ),
          ],
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.cover,
            opacity: 0.3,
            image: const NetworkImage(
              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
            ),
          ),
        ),
        child: Card(
          fillColor: Colors.transparent,
          filled: true,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: bookmarks.map((targetItem) {
              // 给 DragTarget 和 Draggable 指定数据类型
              return DragTarget<BookmarkItemWithIndex>(
                // 1. 当有拖拽物移动到自己上方时触发
                onWillAcceptWithDetails: (details) {
                  final draggedItem = details.data;
                  // 不能自己和自己合并/重排
                  if (draggedItem == targetItem) return false;

                  // 清除旧的定时器
                  _hoverTimer?.cancel();

                  // 启动 1 秒定时器
                  _hoverTimer = Timer(const Duration(seconds: 3), () {
                    // 如果 1 秒到了，用户还没移开也没松手，触发合并！
                    _hasMerged = true;
                    _mergeItems(draggedItem, targetItem);
                  });

                  return true; // 告诉框架：我允许接受这个拖拽物
                },

                // 2. 当拖拽物不到1秒就移开时触发
                onLeave: (data) {
                  if (_hasMerged) {
                    print('触发移开逻辑：${targetItem.item.name} 移开 $data');
                    print('合并被取消，恢复备份数据, 备份数据: $_backupBookmarks');
                    _bookmarksState.value = _backupBookmarks;
                    _hasMerged = false;
                    _willMergeItem.value = null;
                  }

                  // 取消合并的定时器
                  _hoverTimer?.cancel();
                },

                // 3. 当用户在自己上方松手放开时触发
                onAcceptWithDetails: (details) {
                  final draggedItem = details.data;
                  // 松手了，必须马上停掉合并定时器
                  _hoverTimer?.cancel();

                  // 如果定时器没有执行完1秒（尚未发生合并），说明用户是想重排
                  if (!_hasMerged) {
                    _reorderItems(draggedItem, targetItem);
                  }
                },

                builder: (context, candidateData, rejectedData) {
                  // candidateData.isNotEmpty 表示此时有东西悬浮在我头上
                  bool isHovered = candidateData.isNotEmpty;

                  return Draggable<BookmarkItemWithIndex>(
                    data: targetItem, // 【重要】把当前数据作为 data 传出去

                    onDragStarted: () {
                      _backupBookmarks = <BookmarkItemWithIndex>[];
                      for (var item in _bookmarksState.value) {
                        _backupBookmarks.add(
                          .new(item: item.item, children: item.children),
                        );
                      }
                      print('备份数据: $_backupBookmarks');

                      _hasMerged = false;
                    },

                    childWhenDragging: Opacity(
                      opacity: 0.3, // 拖拽时，原本的位置变成半透明
                      child: _buildItemUI(e: targetItem, isDragging: false),
                    ),
                    feedback: Material(
                      // 必须包裹 Material 避免拖拽时样式丢失
                      color: Colors.transparent,
                      child: _buildItemUI(
                        e: targetItem,
                        isDragging: true,
                        willMergeItem: willMergeItem,
                      ),
                    ),
                    onDragCompleted: () {
                      print(
                        '触发拖拽完成逻辑：${targetItem.item.name} and willMergeItem: $willMergeItem',
                      );
                      if (willMergeItem != null) {
                        var targetH = bookmarks[willMergeItem.targetIndex];
                        (targetH.children ??= []);
                        if (!targetH.children!.contains(targetItem.item)) {
                          targetH.children!.add(targetItem.item);
                        }
                        var nb = List<BookmarkItemWithIndex>.from(bookmarks);
                        // 1. 从列表中移除被拖拽的源元素
                        nb.removeWhere(
                          (e) => e.item.name == targetItem.item.name,
                        ); // 建议用唯一ID比较
                        _bookmarksState.value = nb;
                        _willMergeItem.value = null;
                        _backupBookmarks.clear();
                      }
                    },

                    // UI渲染，如果是被悬浮状态，可以加个边框或缩放提示用户要合并了
                    child: Container(
                      decoration: BoxDecoration(
                        border: isHovered
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildItemUI(
                        e: targetItem,
                        isDragging: false,
                        willMergeItem: willMergeItem,
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  // 为了代码整洁，单独抽离卡片UI
  Widget _buildItemUI({
    required BookmarkItemWithIndex e,
    bool isDragging = false,
    WillMergeItem? willMergeItem,
  }) {
    if (willMergeItem != null) {
      var t = _bookmarksState.value[willMergeItem.targetIndex];
      if (t.item.name == e.item.name) {
        print('合并项：${willMergeItem.item.name}');
        var ccc = List<BookmarkItem>.from(e.children ?? []);
        if (!ccc.contains(willMergeItem.item)) {
          ccc.add(willMergeItem.item);
        }

        var elements = <BookmarkItem>{};
        elements.addAll(ccc);
        elements.add(e.item);

        print('合并后：$elements.length');
        return Container(
          width: 100,
          height: 100,
          color: Colors.pink,
          child: buildChild(elements.toList()),
        );
      }
    }
    if (e.children != null && e.children!.isNotEmpty) {
      print('willMergeItem is null and 子项：${e.children} and ${e.item}');
      var c = (List<BookmarkItem>.from(e.children!))..add(e.item);
      return Container(
        width: 100,
        height: 100,
        color: Colors.pink,
        child: buildChild(c.toList()),
      );
    }
    return Container(
      width: 100,
      height: 100,
      color: Colors.white.withAlpha(
        isDragging ? 255 * 0.8.round() : 255 * 0.5.round(),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(e.item.icon, width: 48, height: 48),
          Text(e.item.name),
          // 简单提示这里有个子元素（文件夹模式）
          if (e.children != null && e.children!.isNotEmpty)
            Text(
              '(${e.children!.length} items)',
              style: TextStyle(fontSize: 10),
            ),
        ],
      ),
    );
  }

  Widget buildChild(List<BookmarkItem> elements) {
    if (elements.length <= 2) {
      var list = elements.map((e) {
        return Image.network(e.icon, width: 40, height: 40);
      }).toList();
      return Row(mainAxisAlignment: .center, spacing: 8, children: list);
    }
    if (elements.length > 2) {
      var firstLine = elements.sublist(0, 2);
      var secondLine = elements.sublist(2, min(elements.length, 4));
      return Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .stretch,
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            mainAxisAlignment: .center,
            children: firstLine.map((e) {
              return Image.network(e.icon, width: 40, height: 40);
            }).toList(),
          ),
          Row(
            spacing: 8,
            mainAxisAlignment: .center,
            children: secondLine.map((e) {
              return Image.network(e.icon, width: 40, height: 40);
            }).toList(),
          ),
        ],
      );
    }
    return Container();
  }
}
