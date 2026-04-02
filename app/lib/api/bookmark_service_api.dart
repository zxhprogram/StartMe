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

Future<CreateBookmarkGroupResponse> createBookmarkGroup({
  required String name,
  required String url,
  required String icon,
}) async {
  var response = await dio.post(
    '/bookmark/createGroup',
    data: {'name': name, 'url': url, 'icon': icon},
  );
  return .fromJson(response.data);
}

class CreateBookmarkGroupResponse {
  String message;
  CreateBookmarkGroupResponseData? data;
  CreateBookmarkGroupResponse({required this.message, this.data});
  factory CreateBookmarkGroupResponse.fromJson(Map<String, dynamic> json) {
    return .new(
      message: json['message'],
      data: json['data'] != null
          ? CreateBookmarkGroupResponseData.fromJson(json['data'])
          : null,
    );
  }
}

class CreateBookmarkGroupResponseData {
  int id;
  String name;
  String url;
  String icon;
  int groupId;
  CreateBookmarkGroupResponseData({
    required this.id,
    required this.name,
    required this.url,
    required this.icon,
    required this.groupId,
  });
  factory CreateBookmarkGroupResponseData.fromJson(Map<String, dynamic> json) {
    return .new(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      icon: json['icon'],
      groupId: json['groupId'],
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
  List<BookmarkGroup> data;
  BookmarkListResponse({required this.message, required this.data});
  factory BookmarkListResponse.fromJson(Map<String, dynamic> json) {
    return .new(
      message: json['message'],
      data: json['data'] == null
          ? []
          : (json['data'] as List<dynamic>)
                .map((e) => BookmarkGroup.fromJson(e))
                .toList(),
    );
  }
}

class BookmarkGroup {
  int groupId;
  String groupName;
  List<BookmarkItem> items;

  BookmarkGroup({
    required this.groupId,
    required this.groupName,
    required this.items,
  });
  factory BookmarkGroup.fromJson(Map<String, dynamic> json) {
    return .new(
      groupId: json['groupId'],
      groupName: json['groupName'],
      items: json['bookmarkList'] == null
          ? []
          : (json['bookmarkList'] as List<dynamic>)
                .map((e) => BookmarkItem.fromJson(e))
                .toList(),
    );
  }
}

class BookmarkItem {
  int bookmarkId;
  String bookmarkName;
  String url;
  String icon;
  int groupId;
  BookmarkItem({
    required this.bookmarkId,
    required this.bookmarkName,
    required this.url,
    required this.icon,
    required this.groupId,
  });
  factory BookmarkItem.fromJson(Map<String, dynamic> json) {
    return .new(
      bookmarkId: json['bookmarkId'],
      bookmarkName: json['bookmarkName'],
      url: json['url'],
      icon: json['icon'],
      groupId: json['groupId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': bookmarkId, 'name': bookmarkName, 'url': url, 'icon': icon};
  }
}

Future<UpdateBookmarkGroupResponse> updateBookmarkGroup({
  required int groupId,
  required String groupName,
  required List<BookmarkItem> items,
}) async {
  var response = await dio.post(
    '/bookmark/updateGroup',
    data: {
      'id': groupId,
      'name': groupName,
      'items': items.map((e) => e.toJson()).toList(),
    },
  );
  return .fromJson(response.data);
}

class UpdateBookmarkGroupResponse {
  String message;
  UpdateBookmarkGroupResponse({required this.message});
  factory UpdateBookmarkGroupResponse.fromJson(Map<String, dynamic> json) {
    return .new(message: json['message']);
  }
}
