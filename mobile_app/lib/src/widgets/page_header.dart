import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'app_drawer_controller.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const IconButton(
          key: Key('app-drawer-menu-button'),
          tooltip: '打开侧边栏',
          icon: Icon(Icons.menu),
          onPressed: AppDrawerController.open,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
