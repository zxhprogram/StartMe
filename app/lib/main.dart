import 'dart:ui';

import 'package:app/components/MailComponent.dart';
import 'package:app/components/MusicComponent.dart';
import 'package:app/components/NewsComponent.dart';
import 'package:app/components/RecentBookmarksComponent.dart';
import 'package:app/components/SearchBoxComponent.dart';
import 'package:app/components/StatusIndicator.dart';
import 'package:app/components/TaskComponent.dart';
import 'package:app/components/TimeComponent.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  runApp(
    ShadcnApp(
      scaling: const AdaptiveScaling(0.95),
      theme: ThemeData(
        colorScheme: ColorSchemes.lightZinc.sky,
        density: Density.compactDensity,
        surfaceOpacity: 0.1,
        surfaceBlur: 12.0,
        radius: 1,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    ),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: .new(
                image: NetworkImage(
                  'https://staticedu-wps-cache.iciba.com/image/2f56c95a6cf4753e781e48a3c421aca9.png',
                ),
                // opacity: 0.7,
                fit: BoxFit.fill,
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 15.0),
              // 必须有一个 child，通常用半透明的 Container 增加滤镜质感
              child: Container(
                color: Colors.black.withAlpha(
                  255 * 0.1.round(),
                ), // 稍微加一点黑色遮罩，让上方文字更清晰
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: .center,
              children: [
                StatusIndicator(),
                Expanded(
                  child: Column(
                    mainAxisAlignment: .center,
                    children: [
                      TimeComponent(),
                      Text(
                        'Monday, 17 April 2023',
                        style: .new(color: Colors.white, fontSize: 16),
                      ),
                      gap(10),
                      Text(
                        'Halfway there. Finish strong!',
                        style: .new(color: Colors.white, fontSize: 20),
                      ),
                      gap(20.0),
                      SearchBoxComponent(),
                      gap(20.0),
                      Column(
                        mainAxisAlignment: .center,
                        spacing: 10,
                        children: [
                          RecentBookmarksComponent(),
                          Padding(
                            padding: const .symmetric(horizontal: 80.0),
                            child: Card(
                              surfaceOpacity: 0,
                              surfaceBlur: 0,
                              borderColor: Colors.white,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  spacing: 15,
                                  mainAxisAlignment: .center,
                                  children: [
                                    MusicComponent(),
                                    TaskComponent(),
                                    MailComponent(),
                                    NewsComponent(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class EditableMenuLabel extends StatelessWidget implements MenuItem {
  const EditableMenuLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [Text('Editable Label'), Icon(RadixIcons.pencil1, size: 16.0)],
    );
  }

  @override
  bool get hasLeading => false;

  @override
  PopoverController? get popoverController => null;
}
