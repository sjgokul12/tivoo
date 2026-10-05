import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom-nav destinations. Discover opens the full-screen live viewer
/// instead of switching tabs, so it has no page in the shell.
enum ShellTab { home, discover, goLive, messages, profile }

final shellTabProvider = NotifierProvider<ShellTabNotifier, ShellTab>(ShellTabNotifier.new);

class ShellTabNotifier extends Notifier<ShellTab> {
  @override
  ShellTab build() => ShellTab.home;

  void select(ShellTab tab) => state = tab;
}
