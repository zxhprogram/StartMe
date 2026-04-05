import 'dart:async'; // 引入 Timer
import 'dart:math';
import 'package:app/api/bookmark_service_api.dart';
import 'package:app/api/unsplash_service_api.dart';
import 'package:app/services/logger_service.dart';
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

class _BookmarksPageState extends State<BookmarksPage> {
  final _bookmarksState = signal<List<BookmarkGroup>>([]);

  // 用于控制 1 秒悬浮的定时器
  Timer? _hoverTimer;

  // 用于标记本次拖拽是否已经触发了合并，防止松手时又触发重排
  bool _hasMerged = false;

  // 用于备份拖拽事件开始之前的所有的数据
  List<BookmarkGroup> _backupBookmarks = [];
  final _willMergeItem = signal<BookmarkGroup?>(null);
  final _mergeTarget = signal<BookmarkGroup?>(null);
  final _urlInfo = signal<UrlInfoData?>(null);
  late TextEditingController nameController = TextEditingController();
  final _backgroundState = signal(
    'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
  );

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
    _bookmarksState.value = r.data.where((e) => e.items.isNotEmpty).toList();
  }

  // ==== 核心业务逻辑：合并 ====
  void _mergeItems(BookmarkGroup source, BookmarkGroup target) {
    logger.info('触发合并逻辑：${source.groupName} 合并到 ${target.groupName}');

    var currentList = List<BookmarkGroup>.from(_bookmarksState.value);
    var targetIndex = currentList.indexWhere(
      (e) => e.groupId == target.groupId,
    );
    if (targetIndex != -1) {
      _willMergeItem.value = source;
      _mergeTarget.value = target;
    }
  }

  // ==== 核心业务逻辑：排序 ====
  void _reorderItems(BookmarkGroup source, BookmarkGroup target) async {
    logger.info('触发重排逻辑：${source.groupName} 移动到 ${target.groupName}');

    var currentList = List<BookmarkGroup>.from(_bookmarksState.value);

    // 1. 获取两者的当前真实索引
    int sourceIndex = currentList.indexWhere(
      (e) => e.groupId == source.groupId,
    );
    int targetIndex = currentList.indexWhere(
      (e) => e.groupId == target.groupId,
    );

    if (sourceIndex == -1 || targetIndex == -1) return;

    // 2. 移除源元素
    var removedItem = currentList.removeAt(sourceIndex);

    // 3. 插入到目标位置
    currentList.insert(targetIndex, removedItem);

    _bookmarksState.value = currentList;

    // 4. 调用 API 保存新的顺序（通过更新所有组的名称来触发后端保存顺序，或者需要后端提供专门的排序接口）
    // 这里我们逐个更新组的位置信息
    for (int i = 0; i < currentList.length; i++) {
      var group = currentList[i];
      await updateBookmarkGroup(
        groupId: group.groupId,
        groupName: group.groupName,
        items: group.items,
      );
    }
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
                                    logger.fine('输入了 $value');
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
                var r = await createBookmarkGroup(
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
                        title: const Text('添加书签组成功'),
                        content: Text('添加书签组成功 id = ${r.data!.groupId}'),
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

  void _changeBackground(BuildContext context) async {
    var r = await getRandomPhotos();
    if (r.data != null) {
      _backgroundState.value = r.data![0].url;
    }
  }

  @override
  Widget build(BuildContext context) {
    var bookmarks = _bookmarksState.watch(context);
    var willMergeItem = _willMergeItem.watch(context);
    var mergeTarget = _mergeTarget.watch(context);
    var backgroundUrl = _backgroundState.watch(context);

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
        MenuButton(
          trailing: MenuShortcut(
            activator: SingleActivator(
              LogicalKeyboardKey.bracketLeft,
              control: true,
            ),
          ),
          onPressed: _changeBackground,
          child: Row(
            children: [
              const Icon(BootstrapIcons.imageFill),
              const Gap(4),
              Text('更换背景'),
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
              image: NetworkImage(backgroundUrl),
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
                return DragTarget<BookmarkGroup>(
                  // 1. 当有拖拽物移动到自己上方时触发
                  onWillAcceptWithDetails: (details) {
                    final draggedItem = details.data;
                    // 不能自己和自己合并/重排
                    if (draggedItem == targetItem) return false;

                    // 清除旧的定时器
                    _hoverTimer?.cancel();

                    // 只有当拖拽的分组只有一个书签时，才支持合并
                    // 多个书签的分组只能排序
                    if (draggedItem.items.length == 1) {
                      // 启动 3 秒定时器
                      _hoverTimer = Timer(const Duration(seconds: 3), () {
                        // 如果 3 秒到了，用户还没移开也没松手，触发合并预览！
                        _hasMerged = true;
                        _mergeItems(draggedItem, targetItem);
                      });
                    }

                    return true; // 告诉框架：我允许接受这个拖拽物
                  },

                  // 2. 当拖拽物不到3秒就移开时触发
                  onLeave: (data) {
                    // 如果已经触发了合并预览（_willMergeItem 不为空），则恢复备份
                    if (_willMergeItem.value != null) {
                      logger.info('触发移开逻辑：${targetItem.groupName} 移开 $data');
                      logger.fine('合并被取消，恢复备份数据, 备份数据: $_backupBookmarks');
                      _bookmarksState.value = _backupBookmarks;
                      _hasMerged = false;
                      _willMergeItem.value = null;
                      _mergeTarget.value = null;
                    }

                    // 取消合并的定时器
                    _hoverTimer?.cancel();
                  },

                  // 3. 当用户在自己上方松手放开时触发
                  onAcceptWithDetails: (details) {
                    final draggedItem = details.data;
                    // 松手了，必须马上停掉合并定时器
                    _hoverTimer?.cancel();

                    // 如果定时器没有执行完3秒（尚未发生合并），说明用户是想重排
                    if (!_hasMerged) {
                      _reorderItems(draggedItem, targetItem);
                    }
                  },

                  builder: (context, candidateData, rejectedData) {
                    // candidateData.isNotEmpty 表示此时有东西悬浮在我头上
                    bool isHovered = candidateData.isNotEmpty;

                    return Draggable<BookmarkGroup>(
                      data: targetItem,

                      // 【重要】把当前数据作为 data 传出去
                      onDragStarted: () {
                        _backupBookmarks = <BookmarkGroup>[];
                        for (var item in _bookmarksState.value) {
                          _backupBookmarks.add(
                            .new(
                              groupId: item.groupId,
                              groupName: item.groupName,
                              items: item.items,
                            ),
                          );
                        }
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
                      onDragCompleted: () async {
                        logger.info(
                          '触发拖拽完成逻辑：${targetItem.groupName} and willMergeItem: $willMergeItem',
                        );
                        // 只有当合并预览被触发（willMergeItem != null）且拖拽的分组只有一个书签时才执行合并
                        if (willMergeItem != null &&
                            mergeTarget != null &&
                            willMergeItem.items.length == 1) {
                          // 1. 找到目标组（mergeTarget 是合并的目标）
                          var targetGroup = bookmarks.firstWhere(
                            (e) => e.groupId == mergeTarget.groupId,
                          );

                          // 2. 创建新的书签项列表（深拷贝避免引用问题）
                          // willMergeItem 是被拖拽的源元素，它的书签项要合并到目标组
                          var mergedItems = List<BookmarkItem>.from(
                            targetGroup.items,
                          )..addAll(willMergeItem.items);

                          // 3. 更新 UI 状态
                          var nb = List<BookmarkGroup>.from(bookmarks);
                          // 从列表中移除被拖拽的源元素（willMergeItem）
                          nb.removeWhere(
                            (e) => e.groupId == willMergeItem.groupId,
                          );
                          _bookmarksState.value = nb;
                          _willMergeItem.value = null;
                          _mergeTarget.value = null;
                          _backupBookmarks.clear();

                          // 4. 调用 API 保存合并结果
                          // 更新目标组，添加合并的书签
                          await updateBookmarkGroup(
                            groupId: targetGroup.groupId,
                            groupName: targetGroup.groupName,
                            items: mergedItems,
                          );

                          // 5. 调用api 更新被拖拽的源元素（willMergeItem）
                          await updateBookmarkGroup(
                            groupId: willMergeItem.groupId,
                            groupName: willMergeItem.groupName,
                            items: [],
                          );

                          // 5. 重新获取数据以同步后端状态
                          _fetchData();
                        }
                      },

                      // UI渲染，如果是被悬浮状态，可以加个边框或缩放提示用户要合并了
                      child: GestureDetector(
                        onTap: () {
                          //展开文件夹中的内容，显示在弹窗中
                          showDialog(
                            context: context,
                            builder: (context) {
                              final FormController controller =
                                  FormController();
                              return AlertDialog(
                                title: Text(targetItem.groupName),
                                content: _buildBookmarkList(targetItem.items),
                                actions: [
                                  // PrimaryButton(
                                  //   child: const Text('Save changes'),
                                  //   onPressed: () {
                                  //     // Return the form values and close the dialog.
                                  //     Navigator.of(
                                  //       context,
                                  //     ).pop(controller.values);
                                  //   },
                                  // ),
                                ],
                              );
                            },
                          );
                        },
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
                            mergeTarget: mergeTarget,
                          ),
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

  Widget _buildBookmarkList(List<BookmarkItem> items) {
    logger.fine('items: $items');
    return SizedBox(
      height: 300,
      width: 300,
      child: SingleChildScrollView(
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items
              .map(
                (e) => SizedBox(
                  width: 48,
                  height: 48,
                  child: Column(
                    children: [
                      Image.network(e.icon, width: 40, height: 40),
                      Text(
                        e.bookmarkName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  int people = 0;
  bool showBookmarksBar = false;
  bool showFullUrls = true;

  // 为了代码整洁，单独抽离卡片UI
  Widget _buildItemUI({
    required BookmarkGroup e,
    bool isDragging = false,
    BookmarkGroup? willMergeItem,
    BookmarkGroup? mergeTarget,
  }) {
    // 如果当前元素是合并的目标（target），且拖拽的分组只有一个书签，则显示合并后的预览
    if (willMergeItem != null &&
        mergeTarget != null &&
        willMergeItem.items.length == 1) {
      if (mergeTarget.groupId == e.groupId) {
        logger.fine('合并预览：${willMergeItem.groupName} 合并到 ${e.groupName}');
        // 创建合并后的列表用于预览，不修改原始数据
        var mergedItems = List<BookmarkItem>.from(e.items)
          ..addAll(willMergeItem.items);

        logger.fine('合并后：${mergedItems.length}');
        return Container(
          width: 100,
          height: 100,
          color: Colors.transparent,
          child: buildChild(mergedItems),
        );
      }
    }
    logger.finest('willMergeItem is null and 子项：${e.groupName}');
    var c = (List<BookmarkItem>.from(e.items));
    return AnimatedContainer(
      // 添加动画过渡，让拖拽前后的变化更加丝滑
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      width: 90,
      // 稍微调整尺寸比例，显得更精致
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        // 默认提供一个纯净的背景色，拖拽时微微透明withOpacity(
        color: isDragging ? Colors.white.withValues(alpha: 0.9) : Colors.white,
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
              MenuRadio(value: 1, autoClose: false, child: Text('Colm Tuite')),
            ],
          ),
        ],
        child: buildChild(c.toList(), name: e.groupName),
      ),
    );
  }

  Widget buildChild(List<BookmarkItem> elements, {String? name}) {
    if (elements.length <= 2) {
      var list = elements.map((e) {
        return Image.network(e.icon, width: 28, height: 28);
      }).toList();
      logger.finest('list length: ${list.length}');
      return Column(
        mainAxisAlignment: .center,
        children: [
          Expanded(
            child: Row(mainAxisAlignment: .center, spacing: 8, children: list),
          ),
          Text(
            name?.trim() ?? '收藏夹',
            style: .new(color: Colors.pink),
            maxLines: 1,
          ),
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
          Text(
            name?.trim() ?? '收藏夹',
            style: .new(color: Colors.pink),
            maxLines: 1,
          ),
        ],
      );
    }
    return Container();
  }
}
