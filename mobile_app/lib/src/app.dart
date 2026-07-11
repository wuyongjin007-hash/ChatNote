import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/query/query_page.dart';
import 'features/settings/settings_page.dart';
import 'features/voice/voice_page.dart';
import 'theme/app_colors.dart';

class IdeaCaptureApp extends StatelessWidget {
  const IdeaCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '语音想法记录',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardColor: AppColors.surface,
        dividerColor: AppColors.border,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
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
          pageBuilder: (context, state) => const NoTransitionPage(
            child: VoicePage(),
          ),
        ),
        GoRoute(
          path: '/query',
          redirect: (context, state) => '/todos',
        ),
        GoRoute(
          path: '/todos',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: TodoQueryPage(),
          ),
        ),
        GoRoute(
          path: '/ideas',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: IdeaQueryPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
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
      backgroundColor: AppColors.background,
      drawer: _AppDrawer(currentLocation: location),
      body: ColoredBox(
        key: const Key('app-background-fill'),
        color: AppColors.background,
        child: SafeArea(child: child),
      ),
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
      backgroundColor: AppColors.surface,
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
                  fillColor: AppColors.surfaceSoft,
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
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(Icons.mic, color: AppColors.primary),
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
                              style: TextStyle(color: AppColors.textSecondary)),
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
                  const Icon(Icons.storage_outlined,
                      color: AppColors.textSecondary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('本地数据',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        Text('只保存在手机上',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 12)),
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
        color: selected ? AppColors.primarySoft : Colors.transparent,
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
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.textPrimary,
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
