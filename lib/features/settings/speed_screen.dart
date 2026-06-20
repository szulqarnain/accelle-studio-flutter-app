import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/widgets/common.dart';
import '../../theme/app_theme.dart';

class SpeedScreen extends StatefulWidget {
  const SpeedScreen({super.key});

  @override
  State<SpeedScreen> createState() => _SpeedScreenState();
}

class _SpeedScreenState extends State<SpeedScreen> {
  String _profile = 'Normal';
  double _maxExecSpeed = 1200;
  bool _nightMode = false;
  double _nightSpeed = 400;
  double _acceleration = 1800;

  static const _profiles = ['Slow', 'Normal', 'Fast', 'Custom'];

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Speed'),
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
                  child: Text('Speed Profile', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                ),
                DropdownButton<String>(
                  value: _profile,
                  underline: const SizedBox(),
                  dropdownColor: c.surfaceRaised,
                  style: TextStyle(color: c.textPrimary, fontSize: 14),
                  items: _profiles.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                  onChanged: (v) => setState(() => _profile = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Max Execution Speed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 4),
                Text('${_maxExecSpeed.round()} steps/sec', style: monoStyle(fontSize: 13, color: c.textSecondary)),
                Slider(value: _maxExecSpeed, min: 100, max: 3000, onChanged: (v) => setState(() => _maxExecSpeed = v)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Night Mode', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Reduce speed at night', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                        ],
                      ),
                    ),
                    Switch(value: _nightMode, onChanged: (v) => setState(() => _nightMode = v)),
                  ],
                ),
                if (_nightMode) ...[
                  const SizedBox(height: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Night Mode Speed', style: TextStyle(fontSize: 13, color: c.textSecondary)),
                      const SizedBox(height: 4),
                      Text('${_nightSpeed.round()} steps/sec', style: monoStyle(fontSize: 13, color: c.textSecondary)),
                      Slider(value: _nightSpeed, min: 50, max: 1000, onChanged: (v) => setState(() => _nightSpeed = v)),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Acceleration', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 4),
                Text('${_acceleration.round()} steps/sec²', style: monoStyle(fontSize: 13, color: c.textSecondary)),
                Slider(value: _acceleration, min: 100, max: 5000, onChanged: (v) => setState(() => _acceleration = v)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
