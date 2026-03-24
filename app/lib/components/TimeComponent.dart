import 'dart:async';

import 'package:shadcn_flutter/shadcn_flutter.dart';

class TimeComponent extends StatefulWidget {
  const TimeComponent({super.key});

  @override
  State<TimeComponent> createState() => _TimeComponentState();
}

class _TimeComponentState extends State<TimeComponent> {
  String _currentTime =
      '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
  late Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        var now = DateTime.now();
        _currentTime =
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text(_currentTime, style: .new(color: Colors.white, fontSize: 90));
  }
}
