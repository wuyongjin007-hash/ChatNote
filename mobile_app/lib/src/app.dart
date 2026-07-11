import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/query/query_page.dart';
import 'features/settings/settings_page.dart';
import 'features/voice/voice_page.dart';
import 'theme/app_colors.dart';
import 'widgets/app_drawer_controller.dart';

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
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const VoicePage(),
          ),
        ),
        GoRoute(
          path: '/query',
          redirect: (context, state) => '/todos',
        ),
        GoRoute(
          path: '/todos',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const TodoQueryPage(),
          ),
        ),
        GoRoute(
          path: '/ideas',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const IdeaQueryPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => NoTransitionPage<void>(
            key: state.pageKey,
            child: const SettingsPage(),
          ),
        ),
      ],
    ),
  ],
);

class _AppShell extends StatefulWidget {
  const _AppShell({required this.child});

  final Widget child;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drawerController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 170),
    );
    AppDrawerController.attach(this, _openDrawer);
  }

  @override
  void dispose() {
    AppDrawerController.detach(this);
    _drawerController.dispose();
    super.dispose();
  }

  void _openDrawer() {
    if (!_isNavigating) _drawerController.forward();
  }

  void _closeDrawer() {
    if (!_isNavigating) _drawerController.reverse();
  }

  Future<void> _navigateFromDrawer(String path) async {
    if (_isNavigating) return;
    final currentPath = GoRouterState.of(context).uri.path;
    if (currentPath == path) {
      _closeDrawer();
      return;
    }

    _isNavigating = true;
    await _drawerController.reverse();
    if (!mounted) return;
    context.go(path);
    _isNavigating = false;
  }

  @override
  Widget build(BuildContext context) {
    AppDrawerController.attach(this, _openDrawer);
    final location = GoRouterState.of(context).uri.path;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = math.min(screenWidth * 0.82, 360.0);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: _drawerController,
        builder: (context, _) {
          final progress = Curves.easeOutCubic.transform(
            _drawerController.value,
          );
          final contentOffset = drawerWidth * 0.86 * progress;

          return Stack(
            children: [
              if (_drawerController.value > 0)
                Transform.translate(
                  offset: Offset(-drawerWidth * (1 - progress), 0),
                  child: SizedBox(
                    width: drawerWidth,
                    child: _AppDrawer(
                      currentLocation: location,
                      onNavigate: _navigateFromDrawer,
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(contentOffset, 0),
                child: Stack(
                  key: const Key('app-pushed-content'),
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(
                      key: const Key('app-background-fill'),
                      color: AppColors.background,
                      child: SafeArea(child: widget.child),
                    ),
                    if (_drawerController.value > 0)
                      GestureDetector(
                        onTap: _closeDrawer,
                        child: Opacity(
                          key: const Key('app-content-fade-overlay'),
                          opacity: 0.46 * progress,
                          child: const ColoredBox(
                            color: AppColors.surface,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AppDrawer extends StatelessWidget {
  const _AppDrawer({
    required this.currentLocation,
    required this.onNavigate,
  });

  final String currentLocation;
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      key: const Key('app-side-drawer'),
      width: double.infinity,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 58, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primarySoft,
                      child: Icon(
                        Icons.mic_none_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('语音记录',
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w700)),
                          SizedBox(height: 1),
                          Text('本地 AI 想法记录',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12)),
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
                onNavigate: onNavigate,
              ),
              _DrawerDestinationTile(
                id: 'todos',
                icon: Icons.event_note_outlined,
                selectedIcon: Icons.event_note,
                label: '待办',
                path: '/todos',
                selected: currentLocation == '/todos',
                onNavigate: onNavigate,
              ),
              _DrawerDestinationTile(
                id: 'ideas',
                icon: Icons.lightbulb_outline,
                selectedIcon: Icons.lightbulb,
                label: '想法',
                path: '/ideas',
                selected: currentLocation == '/ideas',
                onNavigate: onNavigate,
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
                    onPressed: () => onNavigate('/settings'),
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
    required this.onNavigate,
  });

  final String id;
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String path;
  final bool selected;
  final ValueChanged<String> onNavigate;

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
          onTap: () => onNavigate(path),
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
