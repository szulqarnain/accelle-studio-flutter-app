import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/widgets/common.dart';
import '../../theme/app_theme.dart';

class WifiScreen extends StatefulWidget {
  const WifiScreen({super.key});

  @override
  State<WifiScreen> createState() => _WifiScreenState();
}

class _WifiScreenState extends State<WifiScreen> {
  final _networkCtrl = TextEditingController(text: 'HomeNetwork_5G');
  final _hostnameCtrl = TextEditingController(text: 'accellestudio.local');
  final _ipCtrl = TextEditingController(text: '192.168.1.42');
  final _gatewayCtrl = TextEditingController(text: '192.168.1.1');
  final _subnetCtrl = TextEditingController(text: '255.255.255.0');
  bool _useStaticIp = false;

  @override
  void dispose() {
    _networkCtrl.dispose();
    _hostnameCtrl.dispose();
    _ipCtrl.dispose();
    _gatewayCtrl.dispose();
    _subnetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Wi-Fi'),
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
                Text('Connected Network', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _networkCtrl,
                  style: TextStyle(color: c.textPrimary, fontSize: 15),
                  decoration: InputDecoration(
                    prefixIcon: Icon(LucideIcons.wifi, size: 16, color: c.textTertiary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('mDNS Hostname', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _hostnameCtrl,
                  style: monoStyle(fontSize: 14, color: c.textPrimary),
                ),
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
                          Text('Use Static IP', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                          const SizedBox(height: 2),
                          Text('Manually assign IP address', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                        ],
                      ),
                    ),
                    Switch(value: _useStaticIp, onChanged: (v) => setState(() => _useStaticIp = v)),
                  ],
                ),
                if (_useStaticIp) ...[
                  const SizedBox(height: AppSpacing.md),
                  _LabeledField(label: 'IP Address', controller: _ipCtrl),
                  const SizedBox(height: AppSpacing.sm),
                  _LabeledField(label: 'Gateway', controller: _gatewayCtrl),
                  const SizedBox(height: AppSpacing.sm),
                  _LabeledField(label: 'Subnet Mask', controller: _subnetCtrl),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Forget Network'),
                  content: const Text('Remove saved Wi-Fi credentials?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Network forgotten')),
                        );
                      },
                      child: Text('Forget', style: TextStyle(color: c.danger)),
                    ),
                  ],
                ),
              );
            },
            icon: Icon(LucideIcons.wifiOff, size: 18, color: c.danger),
            label: Text('Forget Network', style: TextStyle(color: c.danger)),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: c.danger),
              minimumSize: const Size.fromHeight(50),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  const _LabeledField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: monoStyle(fontSize: 14, color: c.textPrimary),
        ),
      ],
    );
  }
}
