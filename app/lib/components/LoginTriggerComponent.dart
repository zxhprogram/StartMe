import 'package:shadcn_flutter/shadcn_flutter.dart';

class LoginTriggerComponent extends StatelessWidget {
  const LoginTriggerComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Button.text(
      onPressed: () {
        // Handle profile button press
        showDialog(
          context: context,
          barrierColor: Colors.white.withAlpha(255 * 0.3.round()),
          builder: (context) {
            return AlertDialog(
              padding: .symmetric(horizontal: 0.0, vertical: 0.0),
              content: Card(
                padding: const EdgeInsets.all(24),
                filled: true,
                fillColor: Colors.gray.withAlpha(255 * 0.1.round()),
                child: SizedBox(
                  width: 350,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        BootstrapIcons.grid3x3,
                        color: Colors.white,
                        size: 32,
                      ),
                      const Text(
                        'Welcome',
                        style: .new(color: Colors.white),
                      ).h3,
                      const SizedBox(height: 4),
                      const Text(
                        'Deploy your new project in one-click',
                      ).light().small(),
                      const SizedBox(height: 24),
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          const Text('Name').light().small(),
                          const SizedBox(height: 4),
                          const TextField(
                            placeholder: Text('Name of your project'),
                            style: .new(fontSize: 20, color: Colors.white),
                            features: [
                              .leading(
                                Icon(
                                  BootstrapIcons.envelopeFill,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Column(
                        crossAxisAlignment: .start,
                        children: [
                          const Text('Password').light().small(),
                          const SizedBox(height: 4),
                          TextField(
                            placeholder: Text('Password for your project'),
                            obscureText: true,
                            features: [
                              .leading(
                                Icon(
                                  BootstrapIcons.lockFill,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                              .trailing(
                                Button.text(
                                  onPressed: () {},
                                  child: Icon(
                                    BootstrapIcons.eyeFill,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      gap(12),
                      Row(
                        mainAxisAlignment: .spaceBetween,
                        children: [
                          Row(
                            spacing: 4,
                            children: [
                              Checkbox(state: .unchecked, onChanged: (_) {}),
                              const Text(
                                'Remember Me',
                                style: .new(color: Colors.white),
                              ),
                            ],
                          ),
                          Button.text(
                            onPressed: () {
                              // Handle forgot password action
                            },
                            child: Text(
                              'Forgot Password?',
                              style: .new(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      gap(24),
                      Column(
                        crossAxisAlignment: .stretch,
                        children: [
                          Button.outline(
                            onPressed: () {
                              //
                            },
                            child: Text(
                              'SIGN IN',
                              style: .new(color: Colors.white),
                            ).h4.center(),
                          ),
                        ],
                      ),
                      gap(24),
                      Stack(
                        children: [
                          Positioned(
                            child: Container(
                              child: Text(
                                'OR CONTINUE WITH',
                                style: .new(
                                  color: Colors.white,
                                  background: Paint()..color = Colors.yellow,
                                ),
                              ).center(),
                            ),
                          ),
                          Divider(color: Colors.white.withOpacity(0.4)),
                        ],
                      ),
                      gap(24),
                      Padding(
                        padding: const .symmetric(horizontal: 35),
                        child: Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Button.outline(
                              child: Padding(
                                padding: const .symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    Icon(
                                      size: 20,
                                      BootstrapIcons.google,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'GOOGLE',
                                      style: .new(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Button.outline(
                              child: Padding(
                                padding: const .symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                child: Row(
                                  spacing: 10,
                                  children: [
                                    Icon(
                                      size: 20,
                                      BootstrapIcons.github,
                                      color: Colors.white,
                                    ),
                                    Text(
                                      'GITHUB',
                                      style: .new(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      gap(24),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          Text('Don\'t have an account?'),
                          Button.text(
                            onPressed: () {
                              //
                            },
                            child: Text(
                              'Create Account',
                              style: .new(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).intrinsic(),
              actions: [],
            );
          },
        );
      },
      child: Icon(BootstrapIcons.personFill, color: Colors.white, size: 16),
    );
  }
}
