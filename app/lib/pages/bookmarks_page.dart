import 'dart:async'; // 引入 Timer
import 'dart:math';
import 'package:app/api/bookmark_service_api.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart' show Material;
import 'package:flutter/services.dart';
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
  final _urlInfo = signal<UrlInfoData?>(null);
  late TextEditingController nameController;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
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

  void _saveBookmark(BuildContext context) {
    nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        var urlInfoResult = _urlInfo.watch(context);
        final FormController controller = FormController();
        return AlertDialog(
          title: const Text('新增书签'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('请输入书签名称和 URL'),
              const Gap(16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  children: [
                    // Container(width: 60, height: 60, color: Colors.red),
                    urlInfoResult == null
                        ? Container()
                        : Image.network(
                            urlInfoResult.favicon,
                            width: 60,
                            height: 60,
                          ),
                    Form(
                      controller: controller,
                      child: FormTableLayout(
                        rows: [
                          FormField<String>(
                            key: FormKey(#url),
                            label: Text('书签 URL'),
                            child: TextField(
                              placeholder: Text('请输入书签 URL'),
                              autofocus: true,
                              onChanged: (value) {
                                EasyDebounce.debounce(
                                  'search-debouncer',
                                  const Duration(milliseconds: 700),
                                  () async {
                                    print('输入了 $value');
                                    // nameController.text = value;
                                    if (value.isEmpty) {
                                      return;
                                    } else {
                                      var r = await urlInfo(url: value);
                                      _urlInfo.value = r.data;
                                      nameController.text = r.data!.title;
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          FormField<String>(
                            key: FormKey(#name),
                            label: Text('书签名称'),
                            child: TextField(
                              placeholder: Text('请输入书签名称'),
                              autofocus: false,
                              controller: nameController,
                            ),
                          ),
                        ],
                      ),
                    ).withPadding(vertical: 16),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            PrimaryButton(
              child: const Text('Save changes'),
              onPressed: () async {
                var r = await saveBookmark(
                  name: controller.values[FormKey(#name)] as String,
                  url: controller.values[FormKey(#url)] as String,
                  icon: urlInfoResult?.favicon ?? '',
                );
                _fetchData();
                if (context.mounted) {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('添加书签成功'),
                        content: Text('添加书签成功 id = ${r.data!.id}}'),
                        actions: [
                          PrimaryButton(
                            child: const Text('OK'),
                            onPressed: () {
                              // Close the dialog. In real apps, perform work before closing.
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      },
    );
    _urlInfo.value = null;
    nameController.clear();
  }

  @override
  Widget build(BuildContext context) {
    var bookmarks = _bookmarksState.watch(context);
    var willMergeItem = _willMergeItem.watch(context);

    return ContextMenu(
      items: [
        MenuButton(
          trailing: MenuShortcut(
            activator: SingleActivator(
              LogicalKeyboardKey.bracketLeft,
              control: true,
            ),
          ),
          onPressed: _saveBookmark,
          child: Row(
            children: [
              const Icon(BootstrapIcons.bookmarkPlus),
              const Gap(4),
              Text('新增书签'),
            ],
          ),
        ),
      ],
      child: Scaffold(
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
                          color: Colors.transparent,
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
      ),
    );
  }

  int people = 0;
  bool showBookmarksBar = false;
  bool showFullUrls = true;

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
          color: Colors.transparent,
          child: buildChild(elements.toList()),
        );
      }
    }
    if (e.children != null && e.children!.isNotEmpty) {
      print('willMergeItem is null and 子项：${e.children} and ${e.item}');
      var c = (List<BookmarkItem>.from(e.children!))..add(e.item);
      return AnimatedContainer(
        // 添加动画过渡，让拖拽前后的变化更加丝滑
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 90, // 稍微调整尺寸比例，显得更精致
        height: 100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          // 默认提供一个纯净的背景色，拖拽时微微透明
          color: isDragging ? Colors.white.withOpacity(0.9) : Colors.white,
          borderRadius: BorderRadius.circular(16), // 更圆润的倒角（现代APP标配）
          // 拖拽时显示粉色边框，平时隐藏
          border: Border.all(
            color: isDragging ? Colors.pink : Colors.transparent,
            width: 1.5,
          ),
          // 添加柔和的投影，拖拽时投影变大，产生“浮起”的视觉效果
          boxShadow: [
            BoxShadow(
              color: isDragging
                  ? Colors.pink.withOpacity(0.2) // 拖拽时粉色发光投影
                  : Colors.black.withOpacity(0.04), // 平时微弱的灰色投影
              blurRadius: isDragging ? 12 : 8,
              spreadRadius: isDragging ? 2 : 0,
              offset: isDragging ? const Offset(0, 6) : const Offset(0, 2),
            ),
          ],
        ),
        child: ContextMenu(
          items: [
            // Simple command with Ctrl+[ shortcut.
            const MenuButton(
              trailing: MenuShortcut(
                activator: SingleActivator(
                  LogicalKeyboardKey.bracketLeft,
                  control: true,
                ),
              ),
              child: Text('重命名'),
            ),
            // Disabled command example with Ctrl+] shortcut.
            const MenuButton(
              trailing: MenuShortcut(
                activator: SingleActivator(
                  LogicalKeyboardKey.bracketRight,
                  control: true,
                ),
              ),
              enabled: false,
              child: Text('Forward'),
            ),
            // Enabled command with Ctrl+R shortcut.
            const MenuButton(
              trailing: MenuShortcut(
                activator: SingleActivator(
                  LogicalKeyboardKey.keyR,
                  control: true,
                ),
              ),
              child: Text('Reload'),
            ),
            // Submenu with additional tools and a divider.
            const MenuButton(
              subMenu: [
                MenuButton(
                  trailing: MenuShortcut(
                    activator: SingleActivator(
                      LogicalKeyboardKey.keyS,
                      control: true,
                    ),
                  ),
                  child: Text('Save Page As...'),
                ),
                MenuButton(child: Text('Create Shortcut...')),
                MenuButton(child: Text('Name Window...')),
                MenuDivider(),
                MenuButton(child: Text('Developer Tools')),
              ],
              child: Text('More Tools'),
            ),
            const MenuDivider(),
            // Checkbox item; keep menu open while toggling for quick changes.
            MenuCheckbox(
              value: showBookmarksBar,
              onChanged: (context, value) {
                setState(() {
                  showBookmarksBar = value;
                });
              },
              autoClose: false,
              trailing: const MenuShortcut(
                activator: SingleActivator(
                  LogicalKeyboardKey.keyB,
                  control: true,
                  shift: true,
                ),
              ),
              child: const Text('Show Bookmarks Bar'),
            ),
            MenuCheckbox(
              value: showFullUrls,
              onChanged: (context, value) {
                setState(() {
                  showFullUrls = value;
                });
              },
              autoClose: false,
              child: const Text('Show Full URLs'),
            ),
            const MenuDivider(),
            const MenuLabel(child: Text('People')),
            const MenuDivider(),
            // Radio group; only one person can be selected at a time.
            MenuRadioGroup(
              value: people,
              onChanged: (context, value) {
                setState(() {
                  people = value;
                });
              },
              children: const [
                MenuRadio(
                  value: 0,
                  autoClose: false,
                  child: Text('Pedro Duarte'),
                ),
                MenuRadio(
                  value: 1,
                  autoClose: false,
                  child: Text('Colm Tuite'),
                ),
              ],
            ),
          ],
          child: buildChild(c.toList()),
        ),
      );
    }
    return AnimatedContainer(
      // 添加动画过渡，让拖拽前后的变化更加丝滑
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 90, // 稍微调整尺寸比例，显得更精致
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        // 默认提供一个纯净的背景色，拖拽时微微透明
        color: isDragging ? Colors.white.withOpacity(0.9) : Colors.white,
        borderRadius: BorderRadius.circular(16), // 更圆润的倒角（现代APP标配）
        // 拖拽时显示粉色边框，平时隐藏
        border: Border.all(
          color: isDragging ? Colors.pink : Colors.transparent,
          width: 1.5,
        ),
        // 添加柔和的投影，拖拽时投影变大，产生“浮起”的视觉效果
        boxShadow: [
          BoxShadow(
            color: isDragging
                ? Colors.pink.withOpacity(0.2) // 拖拽时粉色发光投影
                : Colors.black.withOpacity(0.04), // 平时微弱的灰色投影
            blurRadius: isDragging ? 12 : 8,
            spreadRadius: isDragging ? 2 : 0,
            offset: isDragging ? const Offset(0, 6) : const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标区域：给图标加一个非常淡的背景圆圈，提升图标的精致度
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.gray.shade50,
              shape: BoxShape.circle,
            ),
            child: Image.network(
              e.item.icon,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
              // 添加加载失败的备用图标，防止网络图片出错时UI崩溃
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.bookmark, color: Colors.gray, size: 32),
            ),
          ),
          const Spacer(), // 替代 Expanded，把图标和文字优美地推开
          // 文本区域：限制行数、处理溢出、优化字体样式
          Text(
            e.item.name,
            maxLines: 1, // 限制单行
            overflow: TextOverflow.ellipsis, // 超出显示省略号
            style: const TextStyle(
              color: Color(0xFF4A4A4A), // 使用深灰色而不是纯黑或浅灰，更高级
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2, // 稍微增加字间距
            ),
          ),
        ],
      ),
    );
  }

  Widget buildChild(List<BookmarkItem> elements) {
    if (elements.length <= 2) {
      var list = elements.map((e) {
        return Image.network(e.icon, width: 28, height: 28);
      }).toList();
      return Column(
        mainAxisAlignment: .center,
        children: [
          Expanded(
            child: Row(mainAxisAlignment: .center, spacing: 8, children: list),
          ),
          Text('收藏夹', style: .new(color: Colors.pink)),
        ],
      );
    }
    if (elements.length > 2) {
      var firstLine = elements.sublist(0, 2);
      var secondLine = elements.sublist(2, min(elements.length, 4));
      return Column(
        mainAxisAlignment: .center,
        crossAxisAlignment: .center,
        spacing: 8,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: .center,
              mainAxisAlignment: .center,
              spacing: 4,
              children: [
                Row(
                  spacing: 8,
                  mainAxisAlignment: .center,
                  children: firstLine.map((e) {
                    return Image.network(e.icon, width: 24, height: 24);
                  }).toList(),
                ),
                Row(
                  spacing: 8,
                  mainAxisAlignment: .center,
                  children: secondLine.map((e) {
                    return Image.network(e.icon, width: 24, height: 24);
                  }).toList(),
                ),
              ],
            ),
          ),
          Text('收藏夹', style: .new(color: Colors.pink)),
        ],
      );
    }
    return Container();
  }
}
