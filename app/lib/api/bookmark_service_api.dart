import 'package:app/global/global_status.dart';

Future<BookmarkListResponse> bookmarkList() async {
  var response = await dio.get('/bookmark/list');
  return .fromJson(response.data);
}

class BookmarkListResponse {
  String message;
  List<BookmarkItem> data;
  BookmarkListResponse({required this.message, required this.data});
  factory BookmarkListResponse.fromJson(Map<String, dynamic> json) {
    return .new(
      message: json['message'],
      data: (json['data'] as List<dynamic>)
          .map((e) => BookmarkItem.fromJson(e))
          .toList(),
    );
  }
}

class BookmarkItem {
  int id;
  String name;
  String url;
  String icon;
  BookmarkItem({
    required this.id,
    required this.name,
    required this.url,
    required this.icon,
  });
  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return .new(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      icon: json['icon'],
    );
  }
}
