import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_theme.dart';

class AppShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  static const _tabs = [
    (icon: LucideIcons.home, label: 'Home'),
    (icon: LucideIcons.layoutGrid, label: 'Patterns'),
    (icon: LucideIcons.listMusic, label: 'Playlists'),
    (icon: LucideIcons.lightbulb, label: 'LED'),
    (icon: LucideIcons.settings, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final idx = navigationShell.currentIndex;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: c.navBackground,
          border: Border(top: BorderSide(color: c.divider, width: 0.5)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final tabW = constraints.maxWidth / _tabs.length;
                final pillW = tabW - 20;

                return Stack(
                  children: [
                    // Animated sliding pill
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      left: idx * tabW + 10,
                      top: 8,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: pillW,
                        height: 48,
                        decoration: BoxDecoration(
                          color: c.accentMuted,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    // Tab items
                    Row(
                      children: List.generate(_tabs.length, (i) {
                        final selected = idx == i;
                        return Expanded(
                          child: _NavItem(
                            icon: _tabs[i].icon,
                            label: _tabs[i].label,
                            selected: selected,
                            onTap: () => navigationShell.goBranch(
                              i,
                              initialLocation: i == idx,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final color = selected ? c.accent : c.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: selected ? 1.12 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: color,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
