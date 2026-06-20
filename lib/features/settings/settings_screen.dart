import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/api_client.dart';
import '../../data/app_state.dart';
import '../../shared/widgets/common.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_notifier.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            'Settings',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ThemeToggleCard(),
          const SizedBox(height: AppSpacing.md),
          _TableSwitcherCard(),
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: 'Machine'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(icon: LucideIcons.cpu, label: 'Motor & Calibration', onTap: () => context.push('/settings/motor')),
                const _SettingsDivider(),
                _SettingsRow(icon: LucideIcons.compass, label: 'Homing', onTap: () => context.push('/settings/homing')),
                const _SettingsDivider(),
                _SettingsRow(icon: LucideIcons.gauge, label: 'Speed', onTap: () => context.push('/settings/speed')),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: 'Automation'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: LucideIcons.moon,
                  label: 'Still Sands Schedule',
                  onTap: () => context.push('/settings/schedule'),
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: LucideIcons.bell,
                  label: 'Push Notifications',
                  onTap: () => _showNotificationsDialog(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: 'Connectivity'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(icon: LucideIcons.wifi, label: 'Wi-Fi', onTap: () => context.push('/settings/wifi')),
                const _SettingsDivider(),
                _SettingsRow(icon: LucideIcons.server, label: 'MQTT', onTap: () => context.push('/settings/mqtt')),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: LucideIcons.home,
                  label: 'Home Assistant',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Home Assistant integration coming soon')),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: 'System'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: LucideIcons.refreshCw,
                  label: 'Software Updates',
                  onTap: () => _showUpdateDialog(context),
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: LucideIcons.shield,
                  label: 'Security',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No auth configured. Feature coming soon.')),
                  ),
                ),
                const _SettingsDivider(),
                _SettingsRow(
                  icon: LucideIcons.terminal,
                  label: 'Developer / Serial Terminal',
                  onTap: () => context.push('/settings/developer'),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: 'About'),
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: LucideIcons.info,
                  label: 'App Info',
                  onTap: () => showAboutDialog(
                    context: context,
                    applicationName: 'Accelle Studio',
                    applicationVersion: '1.0.0',
                    applicationLegalese: '© 2026 Accelle Studio',
                    children: [
                      const SizedBox(height: 8),
                      const Text('Control your sand table from anywhere with Accelle Studio.'),
                    ],
                  ),
                ),
                const _SettingsDivider(),
                _SettingsRow(icon: LucideIcons.smartphone, label: 'Version 1.0.0'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _showNotificationsDialog(BuildContext context) {
    bool enabled = false;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Push Notifications'),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Enable notifications'),
              Switch(value: enabled, onChanged: (v) => setS(() => enabled = v)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(context: context, builder: (ctx) => const _UpdateDialog());
  }
}

class _ThemeToggleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final isDark = ThemeNotifier.instance.isDark;
    return AppCard(
      onTap: ThemeNotifier.instance.toggle,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: c.accentMuted, borderRadius: BorderRadius.circular(12)),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(isDark ? LucideIcons.moon : LucideIcons.sun, key: ValueKey(isDark), color: c.accent),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isDark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary)),
                const SizedBox(height: 2),
                Text('Tap to switch theme', style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
              ],
            ),
          ),
          Switch(value: !isDark, onChanged: (_) => ThemeNotifier.instance.toggle()),
        ],
      ),
    );
  }
}

class _TableSwitcherCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final name = AppState.instance.tableInfo?.name ?? 'No table connected';
        return AppCard(
          onTap: () => context.push('/connectivity'),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: c.accentMuted, borderRadius: BorderRadius.circular(12)),
                child: Icon(LucideIcons.layoutGrid, color: c.accent),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manage Device',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: c.textPrimary)),
                    const SizedBox(height: 2),
                    Text(name, style: TextStyle(fontSize: 12.5, color: c.textSecondary)),
                  ],
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 18, color: c.textTertiary),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _SettingsRow({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 18, color: c.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary),
                ),
              ),
              Icon(LucideIcons.chevronRight, size: 16, color: c.textTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Divider(height: 1, color: context.col.divider),
    );
  }
}

class _UpdateDialog extends StatefulWidget {
  const _UpdateDialog();

  @override
  State<_UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<_UpdateDialog> {
  bool _loading = false;
  UpdateResult? _result;

  Future<void> _check() async {
    setState(() {
      _loading = true;
      _result = null;
    });
    try {
      final r = await ApiClient.instance.checkForUpdates();
      if (mounted) setState(() { _result = r; _loading = false; });
    } catch (e) {
      if (mounted) setState(() {
        _result = UpdateResult(status: 'error', message: e.toString());
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return AlertDialog(
      title: const Text('Software Updates'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              )
            else if (_result == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Check if a newer version of the device software is available on GitHub.',
                  style: TextStyle(fontSize: 13, color: c.textSecondary),
                ),
              )
            else
              _ResultTile(result: _result!),
          ],
        ),
      ),
      actions: [
        if (!_loading && (_result == null || _result!.isError))
          TextButton(
            onPressed: _check,
            child: Text(_result == null ? 'Check for Updates' : 'Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _ResultTile extends StatelessWidget {
  final UpdateResult result;
  const _ResultTile({required this.result});

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final (icon, color) = result.isError
        ? (LucideIcons.alertCircle, Colors.red)
        : result.isUpdated
            ? (LucideIcons.checkCircle, Colors.green)
            : (LucideIcons.checkCircle, Colors.green);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(result.message, style: TextStyle(fontSize: 13, color: c.textPrimary)),
              if (result.fromCommit != null && result.toCommit != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${result.fromCommit} → ${result.toCommit}',
                  style: TextStyle(fontSize: 11, color: c.textSecondary, fontFamily: 'monospace'),
                ),
              ],
              if (result.commit != null) ...[
                const SizedBox(height: 4),
                Text(
                  'commit ${result.commit}',
                  style: TextStyle(fontSize: 11, color: c.textSecondary, fontFamily: 'monospace'),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
