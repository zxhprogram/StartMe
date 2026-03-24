import 'package:shadcn_flutter/shadcn_flutter.dart';

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
