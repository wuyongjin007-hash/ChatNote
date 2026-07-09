import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/query/query_page.dart';
import 'features/settings/settings_page.dart';
import 'features/voice/voice_page.dart';

class IdeaCaptureApp extends StatelessWidget {
  const IdeaCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '语音想法记录',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff2f6df6),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xfffbfcff),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/voice',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/voice',
          builder: (context, state) => const VoicePage(),
        ),
        GoRoute(
          path: '/query',
          builder: (context, state) => const QueryPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final index = switch (location) {
      '/query' => 1,
      '/settings' => 2,
      _ => 0,
    };

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) {
          switch (value) {
            case 0:
              context.go('/voice');
            case 1:
              context.go('/query');
            case 2:
              context.go('/settings');
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.mic_none), selectedIcon: Icon(Icons.mic), label: '记录'),
          NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.manage_search), label: '查询'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: '设置'),
        ],
      ),
    );
  }
}
