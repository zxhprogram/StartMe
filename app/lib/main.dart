import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

void main() {
  // runApp(const MyApp());
  runApp(
    ShadcnApp(
      scaling: const AdaptiveScaling(0.95),
      theme: ThemeData(
        colorScheme: ColorSchemes.lightZinc.sky,
        density: Density.compactDensity,
        surfaceOpacity: 0.9,
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
                Container(
                  margin: .symmetric(horizontal: 60.0, vertical: 20.0),
                  child: Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      OutlineButton(
                        trailing: const Icon(
                          RadixIcons.caretDown,
                          color: Colors.white,
                        ),
                        density: .dense,
                        size: .new(1.2),
                        onPressed: () {
                          showDropdown(
                            context: context,
                            alignment: .topLeft,
                            margin: .symmetric(
                              horizontal: 60.0,
                              vertical: 65.0,
                            ),
                            builder: (context) {
                              return DropdownMenu(
                                surfaceOpacity: 0.1,
                                surfaceBlur: 10.0,
                                children: [NavigationAccordion()],
                              );
                            },
                          ).future.then((_) {
                            // Called when the dropdown is closed.
                            if (kDebugMode) {
                              print('Closed');
                            }
                          });
                        },
                        child: Container(
                          margin: .symmetric(horizontal: 12.0, vertical: 8.0),
                          child: const Text(
                            'Home',
                            style: .new(color: Colors.white),
                          ),
                        ),
                      ),
                      Row(
                        spacing: 0,
                        children: [
                          TextButton(
                            size: .new(1),
                            onPressed: () {},
                            child: Text(
                              'Gmail',
                              style: .new(color: Colors.white),
                            ),
                          ),
                          TextButton(
                            size: .new(1),
                            onPressed: () {},
                            child: Text(
                              'Images',
                              style: .new(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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

class RecentBookmarksComponent extends StatelessWidget {
  const RecentBookmarksComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: .symmetric(horizontal: 80.0),
      child: Card(
        surfaceOpacity: 0,
        surfaceBlur: 0,
        borderColor: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              BookmarkItemComponent(
                title: 'github',
                icon: Icon(
                  BootstrapIcons.github,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'google',
                icon: Icon(
                  BootstrapIcons.google,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'youtube',
                icon: Icon(
                  BootstrapIcons.youtube,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'facebook',
                icon: Icon(
                  BootstrapIcons.facebook,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'twitter',
                icon: Icon(
                  BootstrapIcons.twitter,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'meta',
                icon: Icon(BootstrapIcons.meta, color: Colors.white, size: 24),
              ),
              BookmarkItemComponent(
                title: 'linkedin',
                icon: Icon(
                  BootstrapIcons.linkedin,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'instagram',
                icon: Icon(
                  BootstrapIcons.instagram,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'stackoverflow',
                icon: Icon(
                  BootstrapIcons.stackOverflow,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'discord',
                icon: Icon(
                  BootstrapIcons.discord,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'slack',
                icon: Icon(BootstrapIcons.slack, color: Colors.white, size: 24),
              ),
              BookmarkItemComponent(
                title: 'spotify',
                icon: Icon(
                  BootstrapIcons.spotify,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'amazon',
                icon: Icon(
                  BootstrapIcons.amazon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'twitterX',
                icon: Icon(
                  BootstrapIcons.twitterX,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'twitch',
                icon: Icon(
                  BootstrapIcons.twitch,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'snapchat',
                icon: Icon(
                  BootstrapIcons.snapchat,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'reddit',
                icon: Icon(
                  BootstrapIcons.reddit,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'pinterest',
                icon: Icon(
                  BootstrapIcons.pinterest,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'gitlab',
                icon: Icon(
                  BootstrapIcons.gitlab,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'medium',
                icon: Icon(
                  BootstrapIcons.medium,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'dribbble',
                icon: Icon(
                  BootstrapIcons.dribbble,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              BookmarkItemComponent(
                title: 'behance',
                icon: Icon(
                  BootstrapIcons.behance,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewsComponent extends StatelessWidget {
  const NewsComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceOpacity: 0,
      surfaceBlur: 0,
      borderColor: Colors.white,
      child: Container(
        width: 200,
        height: 200,
        padding: .symmetric(horizontal: 3.0),
        margin: .symmetric(vertical: 15.0),
        child: Column(
          mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(BootstrapIcons.rssFill, color: Colors.white, size: 16),
                Text('News', style: .new(color: Colors.white)),
              ],
            ),
            gap(3.0),
            Row(
              crossAxisAlignment: .start,
              spacing: 10,
              children: [
                Icon(
                  BootstrapIcons.envelopeFill,
                  color: Colors.white,
                  size: 16,
                ),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Alice Johnson',
                      style: .new(color: Colors.white, fontSize: 12),
                    ).bold,
                    SizedBox(
                      width: 200 - 6,
                      child: Text(
                        'Final feedback for solar portal design to the team!',
                        style: .new(color: Colors.white),
                        overflow: .fade,
                        maxLines: 2,
                      ).thin,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              crossAxisAlignment: .start,
              spacing: 10,
              children: [
                Icon(
                  BootstrapIcons.envelopeFill,
                  color: Colors.white,
                  size: 16,
                ),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Alice Johnson',
                      style: .new(color: Colors.white, fontSize: 12),
                    ).bold,
                    SizedBox(
                      width: 200 - 6,
                      child: Text(
                        'Final feedback for solar portal design to the team!',
                        style: .new(color: Colors.white),
                        overflow: .fade,
                        maxLines: 2,
                      ).thin,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              crossAxisAlignment: .start,
              spacing: 10,
              children: [
                Icon(
                  BootstrapIcons.envelopeOpenFill,
                  color: Colors.white,
                  size: 16,
                ),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Alice Johnson',
                      style: .new(color: Colors.white, fontSize: 12),
                    ).bold,
                    SizedBox(
                      width: 200 - 6,
                      child: Text(
                        'Final feedback for solar portal design to the team!',
                        style: .new(color: Colors.white),
                        overflow: .fade,
                        maxLines: 2,
                      ).thin,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MailComponent extends StatelessWidget {
  const MailComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceOpacity: 0,
      surfaceBlur: 0,
      borderColor: Colors.white,
      child: Container(
        width: 200,
        height: 200,
        padding: .symmetric(horizontal: 3.0),
        margin: .symmetric(vertical: 15.0),
        child: Column(
          mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(BootstrapIcons.inboxFill, color: Colors.white, size: 16),
                Text('Inbox', style: .new(color: Colors.white)),
              ],
            ),
            gap(3.0),
            Row(
              crossAxisAlignment: .start,
              spacing: 10,
              children: [
                Icon(
                  BootstrapIcons.envelopeFill,
                  color: Colors.white,
                  size: 16,
                ),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Alice Johnson',
                      style: .new(color: Colors.white, fontSize: 12),
                    ).bold,
                    SizedBox(
                      width: 200 - 6,
                      child: Text(
                        'Final feedback for solar portal design to the team!',
                        style: .new(color: Colors.white),
                        overflow: .fade,
                        maxLines: 2,
                      ).thin,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              crossAxisAlignment: .start,
              spacing: 10,
              children: [
                Icon(
                  BootstrapIcons.envelopeFill,
                  color: Colors.white,
                  size: 16,
                ),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Alice Johnson',
                      style: .new(color: Colors.white, fontSize: 12),
                    ).bold,
                    SizedBox(
                      width: 200 - 6,
                      child: Text(
                        'Final feedback for solar portal design to the team!',
                        style: .new(color: Colors.white),
                        overflow: .fade,
                        maxLines: 2,
                      ).thin,
                    ),
                  ],
                ),
              ],
            ),
            Row(
              crossAxisAlignment: .start,
              spacing: 10,
              children: [
                Icon(
                  BootstrapIcons.envelopeOpenFill,
                  color: Colors.white,
                  size: 16,
                ),
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Alice Johnson',
                      style: .new(color: Colors.white, fontSize: 12),
                    ).bold,
                    SizedBox(
                      width: 200 - 6,
                      child: Text(
                        'Final feedback for solar portal design to the team!',
                        style: .new(color: Colors.white),
                        overflow: .fade,
                        maxLines: 2,
                      ).thin,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TaskComponent extends StatelessWidget {
  const TaskComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceOpacity: 0,
      surfaceBlur: 0,
      borderColor: Colors.white,
      child: Container(
        width: 200,
        height: 200,
        padding: .symmetric(horizontal: 3.0),
        margin: .symmetric(vertical: 15.0),
        child: Column(
          mainAxisAlignment: .start,
          crossAxisAlignment: .start,
          children: [
            Row(
              spacing: 8,
              children: [
                Icon(
                  BootstrapIcons.checkCircleFill,
                  color: Colors.white,
                  size: 16,
                ),
                Text('Tasks', style: .new(color: Colors.white)),
              ],
            ),
            gap(3.0),
            Row(
              crossAxisAlignment: .start,
              spacing: 10,
              children: [
                Checkbox(state: .checked, onChanged: (_) {}),
                SizedBox(
                  width: 200 - 6,
                  child: Text(
                    'Complete the project proposal',
                    style: .new(color: Colors.white),
                    overflow: .fade,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: .start,
              spacing: 10,
              children: [
                Checkbox(state: .unchecked, onChanged: (_) {}),
                SizedBox(
                  width: 200 - 6,
                  child: Text(
                    'Complete the project proposal',
                    style: .new(color: Colors.white),
                    overflow: .fade,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: .start,
              spacing: 10,
              children: [
                Checkbox(state: .unchecked, onChanged: (_) {}),
                SizedBox(
                  width: 200 - 6,
                  child: Text(
                    'create a presentation for the client meeting',
                    style: .new(color: Colors.white),
                    overflow: .fade,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MusicComponent extends StatelessWidget {
  const MusicComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceOpacity: 0,
      surfaceBlur: 0,
      borderColor: Colors.white,
      child: Container(
        margin: .symmetric(vertical: 15.0),
        width: 200,
        height: 200,
        child: Column(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Image.network(
                'https://staticedu-wps-cache.iciba.com/image/2f56c95a6cf4753e781e48a3c421aca9.png',
                fit: BoxFit.cover,
              ),
            ),
            Text('Golden Hour', style: .new(color: Colors.white)).bold,
            Text(
              'Floral Melody',
              style: .new(color: Colors.white.withAlpha(255 * 0.5.round())),
            ).italic.thin,
            Row(
              mainAxisAlignment: .center,
              children: [
                //上一首
                Button.text(
                  child: Icon(
                    BootstrapIcons.skipBackwardFill,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Button.text(
                  child: Icon(
                    BootstrapIcons.playCircleFill,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                //下一首
                Button.text(
                  child: Icon(
                    BootstrapIcons.skipForwardFill,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BookmarkItemComponent extends StatelessWidget {
  final String title;
  final Widget icon;
  final VoidCallback? onPressed;

  const BookmarkItemComponent({
    super.key,
    required this.title,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Button.text(
      onPressed: onPressed,
      child: Card(
        surfaceOpacity: 0.2,
        surfaceBlur: 0,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Column(
            mainAxisAlignment: .center,
            children: [
              icon,
              Text(
                title,
                style: .new(color: Colors.white, overflow: .fade),
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SearchBoxComponent extends StatelessWidget {
  SearchBoxComponent({super.key});

  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: .symmetric(horizontal: 20.0),
      width: 500,
      height: 55,
      child: Builder(
        builder: (context) {
          return TextField(
            cursorColor: Colors.white,
            controller: _searchController,
            style: .new(color: Colors.white),
            placeholder: Text(
              'Search the web...',
              style: .new(foreground: Paint()..color = Colors.white),
            ),
            onChanged: (str) {
              if (str == 'abc') {
                showDropdown(
                  context: context,
                  // alignment: .topCenter,
                  // offset: .new(-50, 0),
                  anchorAlignment: .bottomCenter,
                  widthConstraint: .anchorMaxSize,
                  builder: (context) {
                    return ConstrainedBox(
                      constraints: .expand(width: 500, height: 300),
                      child: DropdownMenu(
                        surfaceOpacity: 0.1,
                        surfaceBlur: 10.0,
                        children: [
                          IconButtonMenulItem(
                            icon: BootstrapIcons.google,
                            onPressed: () {
                              // Handle Google search action
                            },
                            text: 'Google',
                          ),
                          IconButtonMenulItem(
                            icon: BootstrapIcons.bing,
                            onPressed: () {
                              // Handle Bing search action
                            },
                            text: 'Bing',
                          ),
                          IconButtonMenulItem(
                            icon: BootstrapIcons.github,
                            onPressed: () {
                              // Handle GitHub search action
                            },
                            text: 'GitHub',
                          ),
                        ],
                      ),
                    );
                  },
                );
              }
            },
            decoration: .new(
              border: .all(
                width: 1,
                color: Theme.of(context).colorScheme.primary,
                style: BorderStyle.solid,
              ),
              borderRadius: .all(.circular(25)),
            ),
            features: [
              .leading(Icon(BootstrapIcons.search, color: Colors.white)),
              .trailing(
                Builder(
                  builder: (context) {
                    return Button.text(
                      onPressed: () {
                        showDropdown(
                          context: context,
                          alignment: .topLeft,
                          offset: .new(-50, 0),
                          builder: (context) {
                            return ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 100),
                              child: DropdownMenu(
                                surfaceOpacity: 0.1,
                                surfaceBlur: 10.0,
                                children: [
                                  IconButtonMenulItem(
                                    icon: BootstrapIcons.google,
                                    onPressed: () {
                                      // Handle Google search action
                                    },
                                    text: 'Google',
                                  ),
                                  IconButtonMenulItem(
                                    icon: BootstrapIcons.bing,
                                    onPressed: () {
                                      // Handle Bing search action
                                    },
                                    text: 'Bing',
                                  ),
                                  IconButtonMenulItem(
                                    icon: BootstrapIcons.github,
                                    onPressed: () {
                                      // Handle GitHub search action
                                    },
                                    text: 'GitHub',
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Row(
                        children: [
                          Icon(
                            BootstrapIcons.google,
                            color: Colors.white,
                            size: 20,
                          ),
                          Icon(
                            RadixIcons.caretDown,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
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

class NavigationAccordion extends StatefulWidget implements MenuItem {
  const NavigationAccordion({super.key});

  @override
  State<NavigationAccordion> createState() => _NavigationAccordionState();

  @override
  bool get hasLeading => false;

  @override
  PopoverController? get popoverController => null;
}

class _NavigationAccordionState extends State<NavigationAccordion> {
  @override
  Widget build(BuildContext context) {
    return Accordion(
      items: [
        // Item 1: Demonstrates a basic trigger and a longer content body.
        AccordionItem(
          expanded: true,
          trigger: AccordionTrigger(
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Row(
                  spacing: 4,
                  children: [
                    Icon(RadixIcons.check, size: 16.0, color: Colors.white),
                    Text('Home', style: .new(color: Colors.white)),
                  ],
                ),
                Row(
                  spacing: 4,
                  children: [
                    Icon(RadixIcons.pencil2, size: 14.0, color: Colors.white),
                    Icon(RadixIcons.copy, size: 14.0, color: Colors.white),
                    Icon(RadixIcons.trash, size: 14.0, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
          content: Column(
            children: [
              Button.link(
                onPressed: () {},
                child: Text(
                  'Simple dashboard overview.',
                  style: .new(color: Colors.white),
                ),
              ),
            ],
          ),
        ),

        // Item 3: A third example to show multiple items expand independently.
        AccordionItem(
          trigger: AccordionTrigger(
            child: Row(
              spacing: 4,
              children: [
                Icon(RadixIcons.plus, size: 16.0, color: Colors.white),
                Text('New Page', style: .new(color: Colors.white)),
              ],
            ),
          ),
          content: Text(''),
        ),
      ],
    );
  }
}

class IconButtonMenulItem extends StatelessWidget implements MenuItem {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;

  const IconButtonMenulItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Button.text(
      onPressed: onPressed,
      child: Row(
        spacing: 4,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          Text(text, style: .new(color: Colors.white)),
        ],
      ),
    );
  }

  @override
  bool get hasLeading => false;

  @override
  PopoverController? get popoverController => null;
}
