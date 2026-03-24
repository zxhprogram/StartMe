import 'package:shadcn_flutter/shadcn_flutter.dart';

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
