import 'package:app/global/global_status.dart';

Future<BookmarkListResponse> bookmarkList() async {
  var response = await dio.get('/bookmark/list');
  return .fromJson(response.data);
}

Future<UrlInfoResponse> urlInfo({required String url}) async {
  var response = await dio.post('/url/info', data: {'url': url});
  print(response.data);
  return .fromJson(response.data);
}

Future<SaveBookmarkResponse> saveBookmark({
  required String name,
  required String url,
  required String icon,
}) async {
  var response = await dio.post(
    '/bookmark/save',
    data: {'name': name, 'url': url, 'icon': icon},
  );
  return .fromJson(response.data);
}

class SaveBookmarkResponse {
  String message;
  SaveBookmarkResponseData? data;
  SaveBookmarkResponse({required this.message, this.data});
  factory SaveBookmarkResponse.fromJson(Map<String, dynamic> json) {
    return .new(
      message: json['message'],
      data: json['data'] != null
          ? SaveBookmarkResponseData.fromJson(json['data'])
          : null,
    );
  }
}

class SaveBookmarkResponseData {
  int id;
  String name;
  String url;
  String icon;
  SaveBookmarkResponseData({
    required this.id,
    required this.name,
    required this.url,
    required this.icon,
  });
  factory SaveBookmarkResponseData.fromJson(Map<String, dynamic> json) {
    return .new(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      icon: json['icon'],
    );
  }
}

class UrlInfoResponse {
  String message;
  UrlInfoData? data;
  UrlInfoResponse({required this.message, this.data});
  factory UrlInfoResponse.fromJson(Map<String, dynamic> json) {
    return .new(
      message: json['message'],
      data: json['data'] != null ? UrlInfoData.fromJson(json['data']) : null,
    );
  }
}

class UrlInfoData {
  String title;
  String url;
  String favicon;
  UrlInfoData({required this.title, required this.url, required this.favicon});
  factory UrlInfoData.fromJson(Map<String, dynamic> json) {
    return .new(
      title: json['title'],
      url: json['url'],
      favicon: json['favicon'],
    );
  }
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
  String folderName;
  String name;
  String url;
  String icon;
  int parentId;
  String type;
  List<BookmarkItem>? children;
  BookmarkItem({
    required this.id,
    required this.name,
    required this.url,
    required this.icon,
    required this.folderName,
    required this.parentId,
    required this.type,
    this.children,
  });
  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return .new(
      id: json['id'],
      folderName: json['folderName'],
      name: json['name'],
      url: json['url'],
      icon: json['icon'],
      parentId: json['parentId'],
      type: json['type'],
      children: json['children'] == null
          ? null
          : (json['children'] as List<dynamic>)
                .map((e) => BookmarkItem.fromJson(e))
                .toList(),
    );
  }

  @override
  String toString() {
    return '{id = $id,name = $name,url = $url,icon=$icon}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BookmarkItem) return false;
    return id == other.id;
  }

  @override
  int get hashCode => id.hashCode;
}
