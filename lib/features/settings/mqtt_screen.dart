import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../shared/widgets/common.dart';
import '../../theme/app_theme.dart';

class MqttScreen extends StatefulWidget {
  const MqttScreen({super.key});

  @override
  State<MqttScreen> createState() => _MqttScreenState();
}

class _MqttScreenState extends State<MqttScreen> {
  final _brokerCtrl = TextEditingController(text: 'mqtt.local');
  final _portCtrl = TextEditingController(text: '1883');
  final _clientIdCtrl = TextEditingController(text: 'dw-a3f7-bc29-e41d');
  final _topicCtrl = TextEditingController(text: 'accellestudio/');
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _enableAuth = false;
  bool _tlsSsl = false;

  @override
  void dispose() {
    _brokerCtrl.dispose();
    _portCtrl.dispose();
    _clientIdCtrl.dispose();
    _topicCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('MQTT Broker'),
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
                _FieldLabel('Broker Host'),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _brokerCtrl,
                  style: monoStyle(fontSize: 14, color: c.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                _FieldLabel('Port'),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _portCtrl,
                  keyboardType: TextInputType.number,
                  style: monoStyle(fontSize: 14, color: c.textPrimary),
                ),
                const SizedBox(height: AppSpacing.md),
                _FieldLabel('Client ID'),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _clientIdCtrl,
                        readOnly: true,
                        style: monoStyle(fontSize: 13, color: c.textSecondary),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _clientIdCtrl.text));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Client ID copied')),
                        );
                      },
                      icon: Icon(LucideIcons.copy, size: 18, color: c.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _FieldLabel('Topic Prefix'),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _topicCtrl,
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
                      child: Text('Enable Authentication', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                    ),
                    Switch(value: _enableAuth, onChanged: (v) => setState(() => _enableAuth = v)),
                  ],
                ),
                if (_enableAuth) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: _usernameCtrl,
                    style: TextStyle(color: c.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(labelText: 'Username'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: true,
                    style: TextStyle(color: c.textPrimary, fontSize: 14),
                    decoration: const InputDecoration(labelText: 'Password'),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Text('TLS / SSL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                ),
                Switch(value: _tlsSsl, onChanged: (v) => setState(() => _tlsSsl = v)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Connecting to broker…')),
              );
            },
            icon: const Icon(LucideIcons.zap, size: 18),
            label: const Text('Test Connection'),
            style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.col.textSecondary),
    );
  }
}
