import 'package:shadcn_flutter/shadcn_flutter.dart';

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
