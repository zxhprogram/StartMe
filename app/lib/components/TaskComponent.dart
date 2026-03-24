import 'package:shadcn_flutter/shadcn_flutter.dart';

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
