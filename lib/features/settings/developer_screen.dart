import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../theme/app_theme.dart';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final List<String> _log = [
    '[INFO] Accelle Studio v2.4.1',
    '[INFO] Motor controller: OK',
    '[INFO] LED driver: OK',
    '[WARN] LED driver: calibrating',
    '[INFO] Network: connected to HomeNetwork_5G',
    '[INFO] mDNS: listening on accellestudio.local',
    '[INFO] MQTT: connected to mqtt.local:1883',
    '[INFO] Ready.',
  ];

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _sendCommand() {
    final cmd = _inputCtrl.text.trim();
    if (cmd.isEmpty) return;
    setState(() {
      _log.add('> $cmd');
      _inputCtrl.clear();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _log.add('[OK] Command executed: $cmd');
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollCtrl.hasClients) {
          _scrollCtrl.animateTo(
            _scrollCtrl.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Developer / Serial Terminal'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(LucideIcons.chevronLeft, color: c.textPrimary),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.lg),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0D),
                borderRadius: BorderRadius.circular(AppSpacing.md),
                border: Border.all(color: const Color(0xFF2A2A2A)),
              ),
              child: ListView.builder(
                controller: _scrollCtrl,
                itemCount: _log.length,
                itemBuilder: (_, i) {
                  final line = _log[i];
                  Color color;
                  if (line.startsWith('[WARN]')) {
                    color = const Color(0xFFE0B04D);
                  } else if (line.startsWith('[ERROR]')) {
                    color = const Color(0xFFD2685A);
                  } else if (line.startsWith('>')) {
                    color = const Color(0xFF5B9BD5);
                  } else {
                    color = const Color(0xFF7FB88A);
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 1),
                    child: Text(
                      line,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: color,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputCtrl,
                    style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: 'Enter command…',
                      hintStyle: TextStyle(color: c.textTertiary),
                    ),
                    onSubmitted: (_) => _sendCommand(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: _sendCommand,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 13),
                  ),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
