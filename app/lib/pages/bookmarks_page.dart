import 'dart:async'; // 引入 Timer
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
  int preservedIndex;
  BookmarkItem item;

  // 假定你可能需要一个字段来存储它内部是不是包含了多个书签（文件夹模式）
  List<BookmarkItem>? children;

  BookmarkItemWithIndex({
    required this.preservedIndex,
    required this.item,
    this.children,
  });

  @override
  String toString() {
    return '{preservedIndex = $preservedIndex, item = $item}';
  }
}

class _BookmarksPageState extends State<BookmarksPage> {
  final _bookmarksState = signal<List<BookmarkItemWithIndex>>([]);

  // 用于控制 1 秒悬浮的定时器
  Timer? _hoverTimer;
  // 用于标记本次拖拽是否已经触发了合并，防止松手时又触发重排
  bool _hasMerged = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    var r = await bookmarkList();
    var index = 0;
    _bookmarksState.value = r.data
        .map((e) => BookmarkItemWithIndex(preservedIndex: index++, item: e))
        .toList();
  }

  // ==== 核心业务逻辑：合并 ====
  void _mergeItems(BookmarkItemWithIndex source, BookmarkItemWithIndex target) {
    print('触发合并逻辑：${source.item.name} 合并到 ${target.item.name}');

    var currentList = List<BookmarkItemWithIndex>.from(_bookmarksState.value);

    // 1. 从列表中移除被拖拽的源元素
    currentList.removeWhere(
      (e) => e.item.name == source.item.name,
    ); // 建议用唯一ID比较

    // 2. 找到目标元素，并将其改造为“文件夹”或把内容放进去
    var targetIndex = currentList.indexWhere(
      (e) => e.item.name == target.item.name,
    );
    if (targetIndex != -1) {
      // 初始化 children 列表（如果是第一次合并）
      currentList[targetIndex].children ??= [];
      currentList[targetIndex].children!.add(source.item);
    }

    // 3. 重新整理索引
    for (int i = 0; i < currentList.length; i++) {
      currentList[i].preservedIndex = i;
    }

    _bookmarksState.value = currentList;
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

    // 4. 重要！重新生成所有的 preservedIndex，防止后续拖拽错乱
    for (int i = 0; i < currentList.length; i++) {
      currentList[i].preservedIndex = i;
    }

    _bookmarksState.value = currentList;
  }

  @override
  Widget build(BuildContext context) {
    var bookmarks = _bookmarksState.watch(context);

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
                  _hoverTimer = Timer(const Duration(seconds: 1), () {
                    // 如果 1 秒到了，用户还没移开也没松手，触发合并！
                    _hasMerged = true;
                    _mergeItems(draggedItem, targetItem);
                  });

                  return true; // 告诉框架：我允许接受这个拖拽物
                },

                // 2. 当拖拽物不到1秒就移开时触发
                onLeave: (data) {
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
                      // 开始拖拽时，重置合并标记
                      _hasMerged = false;
                    },

                    childWhenDragging: Opacity(
                      opacity: 0.3, // 拖拽时，原本的位置变成半透明
                      child: _buildItemUI(targetItem, false),
                    ),

                    feedback: Material(
                      // 必须包裹 Material 避免拖拽时样式丢失
                      color: Colors.transparent,
                      child: _buildItemUI(targetItem, true),
                    ),

                    // UI渲染，如果是被悬浮状态，可以加个边框或缩放提示用户要合并了
                    child: Container(
                      decoration: BoxDecoration(
                        border: isHovered
                            ? Border.all(color: Colors.blue, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _buildItemUI(targetItem, false),
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
  Widget _buildItemUI(BookmarkItemWithIndex e, bool isDragging) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.white.withOpacity(isDragging ? 0.8 : 0.5),
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
}
