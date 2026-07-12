import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_drawer_controller.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              key: Key('app-drawer-menu-button'),
              tooltip: '打开侧边栏',
              icon: Icon(Icons.menu, size: 28),
              onPressed: AppDrawerController.open,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
