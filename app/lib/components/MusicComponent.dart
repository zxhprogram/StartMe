import 'package:app/global/global_status.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:signals/signals_flutter.dart';

class MusicComponent extends StatefulWidget {
  const MusicComponent({super.key});

  @override
  State<MusicComponent> createState() => _MusicComponentState();
}

class _MusicComponentState extends State<MusicComponent> {
  // bool _playState = false;

  @override
  Widget build(BuildContext context) {
    var isPlay = playState.watch(context);
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
                  onPressed: () {
                    playState.value = !playState.value;
                  },
                  child: Icon(
                    isPlay
                        ? BootstrapIcons.pauseFill
                        : BootstrapIcons.playCircleFill,
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
