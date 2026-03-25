import 'dart:math';

import 'package:app/api/bookmark_service_api.dart';
import 'package:flutter/material.dart' show Material;
import 'package:flutter_sortable_wrap/sortable_wrap.dart';
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
  BookmarkItemWithIndex({required this.preservedIndex, required this.item});
  @override
  String toString() {
    return '{preservedIndex = $preservedIndex,item = $item}';
  }
}

class _BookmarksPageState extends State<BookmarksPage> {
  final _bookmarksState = signal<List<BookmarkItemWithIndex>>([]);
  // SortableWrapOptions options = SortableWrapOptions()
  //   ..draggableFeedbackBuilder = (Widget child) {
  //     return Material(
  //       elevation: 18.0,
  //       shadowColor: Colors.transparent,
  //       color: Colors.transparent,
  //       borderRadius: BorderRadius.zero,
  //       child: Card(child: child),
  //     );
  // };
  BookmarkItemWithIndex? _startItem;
  BookmarkItemWithIndex? _endItem;

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

  @override
  Widget build(BuildContext context) {
    var bookmarks = _bookmarksState.watch(context);
    return Scaffold(
      floatingFooter: true,
      footers: [
        Row(
          mainAxisAlignment: .end,
          children: [
            Button.text(
              onPressed: () {
                context.go('/');
              },
              child: Icon(BootstrapIcons.houseFill, size: 24),
            ),
          ],
        ),
      ],
      child: Container(
        decoration: BoxDecoration(
          image: .new(
            fit: .cover,
            opacity: 0.3,
            image: NetworkImage(
              'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b',
            ),
          ),
        ),
        child: Card(
          fillColor: Colors.transparent,
          filled: true,
          // child: SortableWrap(
          //   onSorted: (int oldIndex, int newIndex) {
          //     bookmarks.insert(newIndex, bookmarks.removeAt(oldIndex));
          //     var n = List<BookmarkItem>.from(bookmarks);
          //     _bookmarksState.value = n;
          //   },
          //   onSortStart: (int index) {},
          //   spacing: 10,
          //   runSpacing: 15,
          //   options: options,
          //   children: bookmarks.map((e) {
          //     return SizedBox(
          //       width: 100,
          //       height: 100,
          //       child: Column(
          //         children: [
          //           Image.network(e.icon, width: 48, height: 48),
          //           Text(e.name),
          //         ],
          //       ),
          //     );
          //   }).toList(),
          // ),
          child: Wrap(
            children: [
              ...bookmarks.map((e) {
                return DragTarget(
                  onAcceptWithDetails: (detail) {
                    print('onAcceptWithDetails detail = $detail');
                  },
                  onMove: (details) {
                    print('onMove detail = $details');
                  },

                  builder: (context, candidateData, rejectedData) {
                    // print(
                    //   'candidateData = $candidateData and rejectedData = $rejectedData',
                    // );
                    // print('name = ${e.item.name}');
                    _endItem = e;

                    return Draggable(
                      childWhenDragging: Container(
                        width: 100,
                        height: 100,
                        color: Colors.blue,
                      ),
                      onDragStarted: () {
                        _startItem = e;
                      },
                      onDragEnd: (details) {
                        // _endItem = e;
                      },
                      onDragCompleted: () {
                        print(
                          'startItem = ${_startItem?.preservedIndex} and endItem = ${_endItem?.preservedIndex}',
                        );
                        if (_startItem != null && _endItem != null) {
                          var newResult = <BookmarkItemWithIndex>[];
                          if (_startItem!.preservedIndex >
                              _endItem!.preservedIndex) {
                            print('swap start -> end');
                            var m = _startItem;
                            _startItem = _endItem;
                            _endItem = m;
                          }
                          var prevList = bookmarks.sublist(
                            0,
                            _startItem?.preservedIndex,
                          );
                          var middleList = bookmarks.sublist(
                            _startItem!.preservedIndex,
                            _endItem!.preservedIndex + 1,
                          );
                          if (middleList.length > 1) {
                            var newMiddleList = <BookmarkItemWithIndex>[];
                            for (var i = 1; i < middleList.length; i++) {
                              newMiddleList.add(middleList[i]);
                            }
                            newMiddleList.add(middleList[0]);
                            middleList = newMiddleList;
                          }
                          var afterList = bookmarks.sublist(
                            _endItem!.preservedIndex + 1,
                            bookmarks.length,
                          );

                          print('''
                          prevList = $prevList
                          middleList = $middleList
                          afterList = $afterList
                          ''');
                          newResult.addAll(prevList);
                          newResult.addAll(middleList);
                          newResult.addAll(afterList);

                          _bookmarksState.value = newResult;
                        }
                      },
                      feedback: Container(
                        width: 100,
                        height: 100,
                        color: Colors.red,
                      ),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Column(
                          children: [
                            Image.network(e.item.icon, width: 48, height: 48),
                            Text(e.item.name),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
