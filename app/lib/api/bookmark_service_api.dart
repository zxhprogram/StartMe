import 'package:app/global/global_status.dart';
import 'package:app/services/logger_service.dart';

Future<BookmarkListResponse> bookmarkList() async {
  logger.info('API: 获取书签列表');
  try {
    var response = await dio.get('/bookmark/list');
    logger.info('API: 获取书签列表成功');
    return BookmarkListResponse.fromJson(response.data);
  } catch (e, stackTrace) {
    logger.severe('API: 获取书签列表失败', e, stackTrace);
    rethrow;
  }
}

Future<UrlInfoResponse> urlInfo({required String url}) async {
  logger.info('API: 获取URL信息 - $url');
  try {
    var response = await dio.post('/url/info', data: {'url': url});
    logger.fine('API: URL信息响应 - ${response.data}');
    return UrlInfoResponse.fromJson(response.data);
  } catch (e, stackTrace) {
    logger.severe('API: 获取URL信息失败 - $url', e, stackTrace);
    rethrow;
  }
}

Future<CreateBookmarkGroupResponse> createBookmarkGroup({
  required String name,
  required String url,
  required String icon,
}) async {
  logger.info('API: 创建书签组 - $name');
  try {
    var response = await dio.post(
      '/bookmark/createGroup',
      data: {'name': name, 'url': url, 'icon': icon},
    );
    logger.info('API: 创建书签组成功 - $name');
    return CreateBookmarkGroupResponse.fromJson(response.data);
  } catch (e, stackTrace) {
    logger.severe('API: 创建书签组失败 - $name', e, stackTrace);
    rethrow;
  }
}

Future<UpdateBookmarkGroupResponse> updateBookmarkGroup({
  required int groupId,
  required String groupName,
  required List<BookmarkItem> items,
}) async {
  logger.info('API: 更新书签组 - $groupName (ID: $groupId) items: $items');
  try {
    var response = await dio.post(
      '/bookmark/updateGroup',
      data: {
        'id': groupId,
        'name': groupName,
        'items': items.map((e) => e.toJson()).toList(),
      },
    );
    logger.info('API: 更新书签组成功 - $groupName');
    return UpdateBookmarkGroupResponse.fromJson(response.data);
  } catch (e, stackTrace) {
    logger.severe('API: 更新书签组失败 - $groupName', e, stackTrace);
    rethrow;
  }
}

Future<void> increaseBookmarkCount({required int bookmarkId}) async {
  logger.info('API: 增加书签访问量 - $bookmarkId');
  try {
    var response = await dio.post('/bookmark/increase/$bookmarkId');
    logger.info('API: 增加书签访问量成功 - $bookmarkId 响应: ${response.data}');
  } catch (e, stackTrace) {
    logger.severe('API: 增加书签访问量失败 - $bookmarkId', e, stackTrace);
    rethrow;
  }
}

class CreateBookmarkGroupResponse {
  String message;
  CreateBookmarkGroupResponseData? data;
  CreateBookmarkGroupResponse({required this.message, this.data});
  factory CreateBookmarkGroupResponse.fromJson(Map<String, dynamic> json) {
    return CreateBookmarkGroupResponse(
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
    return CreateBookmarkGroupResponseData(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      icon: json['icon'],
      groupId: json['groupId'],
    );
  }
}

class UpdateBookmarkGroupResponse {
  String message;
  UpdateBookmarkGroupResponse({required this.message});
  factory UpdateBookmarkGroupResponse.fromJson(Map<String, dynamic> json) {
    return UpdateBookmarkGroupResponse(message: json['message']);
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
  Map<String, dynamic> toJson() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'items': items.map((e) => e.toJson()).toList(),
    };
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
    return {
      'bookmarkId': bookmarkId,
      'name': bookmarkName,
      'url': url,
      'icon': icon,
      'groupId': groupId,
    };
  }

  @override
  String toString() {
    return 'BookmarkItem{bookmarkId: $bookmarkId, bookmarkName: $bookmarkName, url: $url, icon: $icon, groupId: $groupId}';
  }
}
