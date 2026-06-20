import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/app_state.dart';
import '../../shared/widgets/common.dart';
import '../../theme/app_theme.dart';

class HomingScreen extends StatefulWidget {
  const HomingScreen({super.key});

  @override
  State<HomingScreen> createState() => _HomingScreenState();
}

class _HomingScreenState extends State<HomingScreen> {
  String _homingMethod = 'Optical sensor';
  double _homingSpeed = 500;
  double _xOffset = 0;
  double _yOffset = 0;

  static const _methods = ['Optical sensor', 'Mechanical endstop', 'Software'];

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Homing'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(LucideIcons.chevronLeft, color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text('Homing Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                ),
                DropdownButton<String>(
                  value: _homingMethod,
                  underline: const SizedBox(),
                  dropdownColor: c.surfaceRaised,
                  style: TextStyle(color: c.textPrimary, fontSize: 14),
                  items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (v) => setState(() => _homingMethod = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Homing Speed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 4),
                Text('${_homingSpeed.round()} steps/sec', style: monoStyle(fontSize: 13, color: c.textSecondary)),
                Slider(value: _homingSpeed, min: 50, max: 2000, onChanged: (v) => setState(() => _homingSpeed = v)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('X Offset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 4),
                Text('${_xOffset.round()} mm', style: monoStyle(fontSize: 13, color: c.textSecondary)),
                Slider(value: _xOffset, min: -50, max: 50, onChanged: (v) => setState(() => _xOffset = v)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Y Offset', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 4),
                Text('${_yOffset.round()} mm', style: monoStyle(fontSize: 13, color: c.textSecondary)),
                Slider(value: _yOffset, min: -50, max: 50, onChanged: (v) => setState(() => _yOffset = v)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {
              AppState.instance.home();
              Navigator.pop(context);
            },
            icon: const Icon(LucideIcons.home, size: 18),
            label: const Text('Run Homing Now'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
        ],
      ),
    );
  }
}
