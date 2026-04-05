import 'package:app/global/global_status.dart';

Future<UnsplashRandomResponse> getRandomPhotos() async {
  final response = await dio.get('/unsplash/random');
  return UnsplashRandomResponse.fromJson(response.data);
}

class UnsplashRandomResponse {
  String message;
  List<UnsplashPhotoData>? data;
  UnsplashRandomResponse({required this.message, this.data});
  factory UnsplashRandomResponse.fromJson(Map<String, dynamic> json) {
    return UnsplashRandomResponse(
      message: json['message'],
      data: json['data'] == null
          ? []
          : (json['data'] as List<dynamic>)
                .map((e) => UnsplashPhotoData.fromJson(e))
                .toList(),
    );
  }
}

class UnsplashPhotoData {
  String id;
  String description;
  String altDescription;
  String url;
  String thumUrl;
  String author;
  String authorUrl;
  int width;
  int height;
  UnsplashPhotoData({
    required this.id,
    required this.description,
    required this.altDescription,
    required this.url,
    required this.width,
    required this.height,
    required this.thumUrl,
    required this.author,
    required this.authorUrl,
  });
  factory UnsplashPhotoData.fromJson(Map<String, dynamic> json) {
    return UnsplashPhotoData(
      id: json['id'],
      description: json['description'],
      altDescription: json['alt_description'],
      url: json['url'],
      thumUrl: json['thumb_url'],
      author: json['author'],
      authorUrl: json['author_url'],
      width: json['width'],
      height: json['height'],
    );
  }
}
