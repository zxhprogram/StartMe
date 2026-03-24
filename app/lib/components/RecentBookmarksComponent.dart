import 'package:app/components/BookmarkItemComponent.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

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
