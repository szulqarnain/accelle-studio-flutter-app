import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/api_client.dart';
import '../../shared/widgets/common.dart';
import '../../theme/app_theme.dart';

class LedScreen extends StatefulWidget {
  const LedScreen({super.key});

  @override
  State<LedScreen> createState() => _LedScreenState();
}

class _LedScreenState extends State<LedScreen> {
  bool _loading = true;
  LedStatus? _status;
  List<String> _effects = [];
  String? _wledIp;

  // Local UI state
  bool _power = true;
  Color _color = const Color(0xFFD4A256);
  double _brightness = 0.72;
  double _speed = 0.4;
  double _intensity = 0.6;
  String? _selectedEffect;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        ApiClient.instance.getLedStatus(),
        ApiClient.instance.getWledIp(),
      ]);
      final status = results[0] as LedStatus;
      final wledIp = results[1] as String?;
      if (!mounted) return;
      setState(() {
        _status = status;
        _wledIp = wledIp;
        if (status.connected) {
          _power = status.power ?? true;
          if (status.brightness != null) {
            _brightness = (status.brightness! / 255).clamp(0.0, 1.0);
          }
          _loadEffects();
        }
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadEffects() async {
    try {
      final effects = await ApiClient.instance.getLedEffects();
      if (mounted) setState(() => _effects = effects);
    } catch (_) {}
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return SafeArea(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : _status?.connected == false
              ? _NotConfiguredView(
                  currentIp: _wledIp,
                  onSave: (ip) async {
                    try {
                      await ApiClient.instance.setWledIp(ip);
                      _showSnack('WLED IP saved');
                      await _load();
                    } catch (e) {
                      _showSnack('Error: $e');
                    }
                  },
                )
              : _buildLedControls(c),
    );
  }

  Widget _buildLedControls(AppColorSet c) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('LED', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary)),
            _PowerSwitch(
              value: _power,
              onChanged: (v) async {
                setState(() => _power = v);
                try {
                  await ApiClient.instance.setLedPower(v);
                } catch (e) {
                  _showSnack('Error: $e');
                }
              },
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AnimatedOpacity(
          opacity: _power ? 1 : 0.35,
          duration: const Duration(milliseconds: 200),
          child: IgnorePointer(
            ignoring: !_power,
            child: Column(
              children: [
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: HueRingPicker(
                    pickerColor: _color,
                    onColorChanged: (col) => setState(() => _color = col),
                    colorPickerHeight: 200,
                    hueRingStrokeWidth: 18,
                    displayThumbColor: true,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: TextButton(
                    onPressed: () async {
                      final r = _color.r.toInt();
                      final g = _color.g.toInt();
                      final b = _color.b.toInt();
                      try {
                        await ApiClient.instance.setLedColor(r, g, b);
                        _showSnack('Color applied');
                      } catch (e) {
                        _showSnack('Error: $e');
                      }
                    },
                    child: Text('Apply Color', style: TextStyle(color: c.accent)),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SliderRow(
                        icon: LucideIcons.sun,
                        label: 'Brightness',
                        value: _brightness,
                        onChanged: (v) => setState(() => _brightness = v),
                        onChangeEnd: (v) async {
                          try {
                            await ApiClient.instance.setLedBrightness((v * 255).round());
                          } catch (e) {
                            _showSnack('Error: $e');
                          }
                        },
                      ),
                      Divider(height: AppSpacing.lg, color: c.divider),
                      _SliderRow(
                        icon: LucideIcons.zap,
                        label: 'Speed',
                        value: _speed,
                        onChanged: (v) => setState(() => _speed = v),
                        onChangeEnd: (v) async {
                          try {
                            await ApiClient.instance.setLedSpeed((v * 255).round());
                          } catch (e) {
                            _showSnack('Error: $e');
                          }
                        },
                      ),
                      Divider(height: AppSpacing.lg, color: c.divider),
                      _SliderRow(
                        icon: LucideIcons.gauge,
                        label: 'Intensity',
                        value: _intensity,
                        onChanged: (v) => setState(() => _intensity = v),
                        onChangeEnd: (v) async {
                          try {
                            await ApiClient.instance.setLedIntensity((v * 255).round());
                          } catch (e) {
                            _showSnack('Error: $e');
                          }
                        },
                      ),
                    ],
                  ),
                ),
                if (_effects.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  SectionHeader(title: 'Effects'),
                  const SizedBox(height: AppSpacing.sm),
                  ..._effects.map(
                    (effect) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _EffectTile(
                        name: effect,
                        selected: effect == _selectedEffect,
                        onTap: () async {
                          setState(() => _selectedEffect = effect);
                          try {
                            await ApiClient.instance.setLedEffect(effect);
                          } catch (e) {
                            _showSnack('Error: $e');
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Not configured view ─────────────────────────────────────────────────────

class _NotConfiguredView extends StatefulWidget {
  const _NotConfiguredView({required this.currentIp, required this.onSave});
  final String? currentIp;
  final Future<void> Function(String ip) onSave;

  @override
  State<_NotConfiguredView> createState() => _NotConfiguredViewState();
}

class _NotConfiguredViewState extends State<_NotConfiguredView> {
  late final _ctrl = TextEditingController(text: widget.currentIp ?? '');
  bool _saving = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LED', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary)),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: c.surfaceRaised,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(LucideIcons.lightbulbOff, size: 36, color: c.textTertiary),
                ),
                const SizedBox(height: 20),
                Text('LED not configured',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary)),
                const SizedBox(height: 8),
                Text(
                  'Enter the IP address of your WLED controller\nto enable LED control.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: c.textSecondary, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WLED IP Address',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
                const SizedBox(height: 8),
                TextField(
                  controller: _ctrl,
                  keyboardType: TextInputType.url,
                  style: TextStyle(color: c.textPrimary),
                  decoration: InputDecoration(
                    hintText: '192.168.1.100',
                    hintStyle: TextStyle(color: c.textTertiary),
                    prefixIcon: Icon(LucideIcons.lightbulb, size: 18, color: c.textTertiary),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving
                        ? null
                        : () async {
                            final ip = _ctrl.text.trim();
                            if (ip.isEmpty) return;
                            setState(() => _saving = true);
                            await widget.onSave(ip);
                            if (mounted) setState(() => _saving = false);
                          },
                    child: _saving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Save & Connect'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _PowerSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PowerSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return TapScale(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: value ? c.ledAccentMuted : c.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: value ? c.ledAccent : c.surfaceOutline),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.power, size: 16, color: value ? c.ledAccent : c.textTertiary),
            const SizedBox(width: 6),
            Text(
              value ? 'On' : 'Off',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: value ? c.ledAccent : c.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;

  const _SliderRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    this.onChangeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: c.textSecondary),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: c.textPrimary)),
            const Spacer(),
            Text('${(value * 100).round()}%', style: monoStyle(fontSize: 13, color: c.textSecondary)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: c.ledAccent,
            thumbColor: c.ledAccent,
            overlayColor: c.ledAccent.withValues(alpha: 0.15),
          ),
          child: Slider(value: value, onChanged: onChanged, onChangeEnd: onChangeEnd),
        ),
      ],
    );
  }
}

class _EffectTile extends StatelessWidget {
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const _EffectTile({required this.name, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
      child: Row(
        children: [
          Icon(LucideIcons.sparkles, size: 18, color: selected ? c.ledAccent : c.textTertiary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: selected ? c.textPrimary : c.textSecondary,
                )),
          ),
          if (selected) Icon(LucideIcons.circleDot, size: 18, color: c.ledAccent),
        ],
      ),
    );
  }
}
