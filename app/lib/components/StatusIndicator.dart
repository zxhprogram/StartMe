import 'package:app/components/LoginTriggerComponent.dart';
import 'package:app/components/NavigationAccordion.dart';
import 'package:app/global/global_status.dart';
import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:signals/signals_flutter.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    var isPlay = playState.watch(context);
    return Container(
      margin: .symmetric(horizontal: 60.0, vertical: 20.0),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Builder(
            builder: (context) {
              return OutlineButton(
                trailing: const Icon(RadixIcons.caretDown, color: Colors.white),
                density: .dense,
                size: .new(1.2),
                onPressed: () {
                  showDropdown(
                    context: context,
                    alignment: .topCenter,
                    margin: .symmetric(horizontal: 60.0),
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
                  child: const Text('Home', style: .new(color: Colors.white)),
                ),
              );
            },
          ),
          Row(
            spacing: 0,
            children: [
              isPlay
                  ? Button.text(
                      child: Icon(
                        BootstrapIcons.playFill,
                        color: Colors.white,
                        size: 16,
                      ),
                    )
                  : SizedBox.shrink(),
              TextButton(
                size: .new(1),
                onPressed: () {},
                child: Text('Gmail', style: .new(color: Colors.white)),
              ),
              TextButton(
                size: .new(1),
                onPressed: () {},
                child: Text('Images', style: .new(color: Colors.white)),
              ),
              Button.text(
                child: Icon(
                  BootstrapIcons.gridFill,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              Button.text(
                onPressed: () {
                  // Handle notifications button press
                  openDrawer(
                    context: context,
                    expands: true,
                    builder: (context) {
                      return Container(
                        padding: const EdgeInsets.all(48),
                        color: Colors.white,
                        child: IntrinsicWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [Text('there is no notification')],
                          ),
                        ),
                      );
                    },
                    position: .right,
                    // position: positions[count % positions.length],
                  );
                },
                child: Icon(
                  BootstrapIcons.bellFill,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              LoginTriggerComponent(),
            ],
          ),
        ],
      ),
    );
  }
}
