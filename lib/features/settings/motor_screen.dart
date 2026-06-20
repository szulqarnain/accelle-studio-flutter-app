import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/widgets/common.dart';
import '../../theme/app_theme.dart';

class MotorScreen extends StatefulWidget {
  const MotorScreen({super.key});

  @override
  State<MotorScreen> createState() => _MotorScreenState();
}

class _MotorScreenState extends State<MotorScreen> {
  double _maxSpeed = 1500;
  double _acceleration = 2000;
  double _currentLimit = 1.0;
  String _stepResolution = 'Eighth';
  bool _motorLock = true;

  static const _resolutions = ['Full', 'Half', 'Quarter', 'Eighth', 'Sixteenth'];

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Motor & Calibration'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(LucideIcons.chevronLeft, color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Max Speed', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 4),
                Text('${_maxSpeed.round()} steps/sec', style: monoStyle(fontSize: 13, color: c.textSecondary)),
                Slider(value: _maxSpeed, min: 0, max: 3000, onChanged: (v) => setState(() => _maxSpeed = v)),
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
                Slider(value: _acceleration, min: 0, max: 5000, onChanged: (v) => setState(() => _acceleration = v)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Current Limit', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 4),
                Text('${_currentLimit.toStringAsFixed(1)} A', style: monoStyle(fontSize: 13, color: c.textSecondary)),
                Slider(value: _currentLimit, min: 0.0, max: 2.0, divisions: 20, onChanged: (v) => setState(() => _currentLimit = v)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text('Step Resolution', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                ),
                DropdownButton<String>(
                  value: _stepResolution,
                  underline: const SizedBox(),
                  dropdownColor: c.surfaceRaised,
                  style: TextStyle(color: c.textPrimary, fontSize: 14),
                  items: _resolutions.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setState(() => _stepResolution = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Motor Lock on Idle', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                      const SizedBox(height: 2),
                      Text('Hold position when not moving', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                    ],
                  ),
                ),
                Switch(value: _motorLock, onChanged: (v) => setState(() => _motorLock = v)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Testing motion…')),
              );
            },
            icon: const Icon(LucideIcons.play, size: 18),
            label: const Text('Test Motion'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calibration started…')),
              );
            },
            icon: const Icon(LucideIcons.crosshair, size: 18),
            label: const Text('Run Calibration'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: context.col.surfaceRaised,
              foregroundColor: context.col.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _maxSpeed = 1500;
                _acceleration = 2000;
                _currentLimit = 1.0;
                _stepResolution = 'Eighth';
                _motorLock = true;
              });
            },
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: const Text('Reset to Defaults'),
          ),
        ],
      ),
    );
  }
}
