import 'package:app/global/global_status.dart';

Future<SearchKeywordResponse> search(String query) async {
  var response = await dio.get('/search/$query');
  return .fromJson(response.data);
}

class SearchKeywordResponse {
  String message;
  List<SearchKeywordResponseData> data;

  SearchKeywordResponse({required this.message, required this.data});
  factory SearchKeywordResponse.fromJson(Map<String, dynamic> json) {
    return .new(
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => SearchKeywordResponseData(keyword: item))
          .toList(),
    );
  }
}

class SearchKeywordResponseData {
  String keyword;
  SearchKeywordResponseData({required this.keyword});
}
