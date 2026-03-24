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

class _BookmarksPageState extends State<BookmarksPage> {
  final _bookmarksState = signal<List<BookmarkItem>>([]);
  SortableWrapOptions options = SortableWrapOptions()
    ..draggableFeedbackBuilder = (Widget child) {
      return Material(
        elevation: 18.0,
        shadowColor: Colors.transparent,
        color: Colors.transparent,
        borderRadius: BorderRadius.zero,
        child: Card(child: child),
      );
    };
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() async {
    var r = await bookmarkList();
    _bookmarksState.value = r.data;
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
          child: SortableWrap(
            onSorted: (int oldIndex, int newIndex) {
              bookmarks.insert(newIndex, bookmarks.removeAt(oldIndex));
              var n = List<BookmarkItem>.from(bookmarks);
              _bookmarksState.value = n;
            },
            onSortStart: (int index) {},
            spacing: 10,
            runSpacing: 15,
            options: options,
            children: bookmarks.map((e) {
              return Container(
                width: 100,
                height: 100,
                color: Colors.blue,
                child: Text(e.name),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
