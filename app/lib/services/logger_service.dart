import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  final Logger _logger = Logger('AppLogger');
  File? _logFile;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    Logger.root.level = Level.ALL;

    if (kIsWeb) {
      _initWebLogging();
    } else {
      await _initNativeLogging();
    }

    _initialized = true;
    info('LoggerService initialized');
  }

  void _initWebLogging() {
    Logger.root.onRecord.listen((record) {
      final message = _formatLogMessage(record);
      debugPrint(message);
    });
  }

  Future<void> _initNativeLogging() async {
    try {
      final logDir = Directory('./logs');
      if (!await logDir.exists()) {
        await logDir.create(recursive: true);
      }

      final now = DateTime.now();
      final fileName =
          'app_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}.log';
      _logFile = File('${logDir.path}/$fileName');

      Logger.root.onRecord.listen((record) async {
        final message = _formatLogMessage(record);
        debugPrint(message);

        if (_logFile != null) {
          try {
            await _logFile!.writeAsString('$message\n', mode: FileMode.append);
          } catch (e) {
            debugPrint('Failed to write log to file: $e');
          }
        }
      });
    } catch (e) {
      debugPrint('Failed to initialize file logging: $e');
      _initWebLogging();
    }
  }

  String _formatLogMessage(LogRecord record) {
    final time = record.time.toIso8601String();
    final level = record.level.name.padRight(7);
    final loggerName = record.loggerName;
    final message = record.message;

    if (record.error != null) {
      return '[$time] $level [$loggerName] $message\nError: ${record.error}\nStackTrace: ${record.stackTrace}';
    }
    return '[$time] $level [$loggerName] $message';
  }

  void finest(String message) => _logger.finest(message);
  void finer(String message) => _logger.finer(message);
  void fine(String message) => _logger.fine(message);
  void config(String message) => _logger.config(message);
  void info(String message) => _logger.info(message);
  void warning(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.warning(message, error, stackTrace);
  void severe(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.severe(message, error, stackTrace);
  void shout(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.shout(message, error, stackTrace);

  Future<String?> getLogFilePath() async {
    if (kIsWeb) return null;
    return _logFile?.path;
  }

  Future<void> clearLogs() async {
    if (kIsWeb || _logFile == null) return;
    try {
      if (await _logFile!.exists()) {
        await _logFile!.delete();
      }
      info('Logs cleared');
    } catch (e) {
      severe('Failed to clear logs', e);
    }
  }
}

final logger = LoggerService();
