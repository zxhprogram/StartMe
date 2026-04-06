import 'package:dio/dio.dart';
import 'package:signals/signals_flutter.dart';

final playState = signal(false);
var dio = Dio(
  BaseOptions(
    baseUrl: 'https://ivlgtyljpapc.ap-northeast-1.clawcloudrun.com',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ),
);
