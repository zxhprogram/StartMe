import 'package:shadcn_flutter/shadcn_flutter.dart';

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
