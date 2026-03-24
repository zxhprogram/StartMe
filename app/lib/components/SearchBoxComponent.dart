import 'package:app/api/search_service_api.dart';
import 'package:app/components/IconButtonMenulItem.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class SearchBoxComponent extends StatefulWidget {
  const SearchBoxComponent({super.key});

  @override
  State<SearchBoxComponent> createState() => _SearchBoxComponentState();
}

class _SearchBoxComponentState extends State<SearchBoxComponent> {
  final TextEditingController _controller = TextEditingController();

  final List<String> suggestions = [];
  List<String> _currentSuggestions = [];
  void _updateSuggestions(String value) async {
    String? currentWord = _controller.currentWord;
    if (currentWord == null || currentWord.isEmpty) {
      setState(() {
        _currentSuggestions = [];
      });
      return;
    }
    EasyDebounce.debounce(
      'search-debouncer',
      const Duration(milliseconds: 300),
      () async {
        var r = await search(currentWord);
        setState(() {
          _currentSuggestions = r.data.map((e) => e.keyword).toList();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: .symmetric(horizontal: 20.0),
      width: 500,
      height: 55,
      child: Builder(
        builder: (context) {
          return AutoComplete(
            mode: .replaceAll,
            suggestions: _currentSuggestions,
            child: TextField(
              cursorColor: Colors.white,
              controller: _controller,
              style: .new(color: Colors.white),
              placeholder: Text(
                'Search the web...',
                style: .new(foreground: Paint()..color = Colors.white),
              ),
              onChanged: _updateSuggestions,
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
            ),
          );
        },
      ),
    );
  }
}
