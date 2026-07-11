import 'dart:math' as math;

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
          redirect: (context, state) => '/todos',
        ),
        GoRoute(
          path: '/todos',
          builder: (context, state) => const TodoQueryPage(),
        ),
        GoRoute(
          path: '/ideas',
          builder: (context, state) => const IdeaQueryPage(),
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
    return Scaffold(
      drawer: _AppDrawer(currentLocation: location),
      body: SafeArea(child: child),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({required this.currentLocation});

  final String currentLocation;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return Drawer(
      key: const Key('app-side-drawer'),
      width: math.min(width * 0.82, 360),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                enabled: false,
                decoration: InputDecoration(
                  hintText: '搜索记录',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xfff3f6fb),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xfff7f9fc),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: Color(0xffdbeafe),
                      child: Icon(Icons.mic, color: Color(0xff2f6df6)),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('语音记录',
                              style: TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.w800)),
                          SizedBox(height: 2),
                          Text('本地 AI 想法记录',
                              style: TextStyle(color: Color(0xff6b7280))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _DrawerDestinationTile(
                id: 'voice',
                icon: Icons.mic_none,
                selectedIcon: Icons.mic,
                label: '记录',
                path: '/voice',
                selected: currentLocation == '/voice',
              ),
              _DrawerDestinationTile(
                id: 'todos',
                icon: Icons.event_note_outlined,
                selectedIcon: Icons.event_note,
                label: '待办',
                path: '/todos',
                selected: currentLocation == '/todos',
              ),
              _DrawerDestinationTile(
                id: 'ideas',
                icon: Icons.lightbulb_outline,
                selectedIcon: Icons.lightbulb,
                label: '想法',
                path: '/ideas',
                selected: currentLocation == '/ideas',
              ),
              const Spacer(),
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.storage_outlined, color: Color(0xff64748b)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('本地数据',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('只保存在手机上',
                            style: TextStyle(
                                color: Color(0xff6b7280), fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: '设置',
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/settings');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerDestinationTile extends StatelessWidget {
  const _DrawerDestinationTile({
    required this.id,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.path,
    required this.selected,
  });

  final String id;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected ? const Color(0xffeaf2ff) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          key: Key('drawer-destination-$id'),
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.of(context).pop();
            context.go(path);
          },
          child: Container(
            key: selected ? Key('drawer-destination-$id-selected') : null,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected
                      ? const Color(0xff2f6df6)
                      : const Color(0xff111827),
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? const Color(0xff1d4ed8)
                        : const Color(0xff111827),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
