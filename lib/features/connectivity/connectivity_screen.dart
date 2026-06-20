import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/api_client.dart';
import '../../theme/app_theme.dart';
import '../../shared/widgets/common.dart';

class ConnectivityScreen extends StatefulWidget {
  const ConnectivityScreen({super.key});

  @override
  State<ConnectivityScreen> createState() => _ConnectivityScreenState();
}

class _ConnectivityScreenState extends State<ConnectivityScreen> {
  // State
  bool _loading = true;
  String? _error;
  TableInfo? _tableInfo;
  WifiStatus? _wifiStatus;
  List<SavedNetwork> _savedNetworks = [];
  List<ScannedNetwork> _scannedNetworks = [];
  bool _scanning = false;
  String _hotspotPassword = '';
  String _hotspotSsid = '';
  String _hostname = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        ApiClient.instance.getTableInfo(),
        ApiClient.instance.getWifiStatus(),
        ApiClient.instance.getSavedNetworks(),
        ApiClient.instance.getHotspotPassword(),
      ]);
      if (!mounted) return;
      setState(() {
        _tableInfo = results[0] as TableInfo;
        _wifiStatus = results[1] as WifiStatus;
        _savedNetworks = results[2] as List<SavedNetwork>;
        _hotspotPassword = results[3] as String;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
      return;
    }
    // These endpoints are added in the updated backend — fail silently if not yet deployed.
    try {
      _hotspotSsid = await ApiClient.instance.getHotspotSsid();
      if (mounted) setState(() {});
    } catch (_) {}
    try {
      _hostname = await ApiClient.instance.getHostname();
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _scanNetworks() async {
    setState(() { _scanning = true; _scannedNetworks = []; });
    try {
      final nets = await ApiClient.instance.scanNetworks();
      if (!mounted) return;
      setState(() { _scannedNetworks = nets; });
    } catch (e) {
      if (!mounted) return;
      _showError('Scan failed: $e');
    } finally {
      if (mounted) setState(() => _scanning = false);
    }
  }

  Future<void> _forgetNetwork(String ssid) async {
    try {
      await ApiClient.instance.forgetNetwork(ssid);
      _showSnack('Removed "$ssid"');
      await _loadAll();
    } catch (e) {
      _showError('Failed: $e');
    }
  }

  Future<void> _saveHotspotPassword(String pw) async {
    try {
      await ApiClient.instance.setHotspotPassword(pw);
      setState(() => _hotspotPassword = pw);
      _showSnack(pw.isEmpty ? 'Hotspot is now open' : 'Hotspot password updated');
    } catch (e) {
      _showError('Failed: $e');
    }
  }

  Future<void> _saveHotspotSsid(String ssid) async {
    try {
      await ApiClient.instance.setHotspotSsid(ssid);
      setState(() => _hotspotSsid = ssid);
      _showSnack('Hotspot name updated to "$ssid"');
    } catch (e) {
      _showError('Failed: $e');
    }
  }

  Future<void> _saveHostname(String hostname) async {
    try {
      await ApiClient.instance.setHostname(hostname);
      setState(() => _hostname = hostname);
      _showSnack('Hostname updated — reconnect via "$hostname.local"');
    } catch (e) {
      _showError('Failed: $e');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          child: Column(
            children: [
              _Header(onBack: () => context.pop(), onSetup: () => context.go('/setup')),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? _ErrorState(error: _error!, onRetry: _loadAll)
                        : _buildBody(c),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(AppColorSet c) {
    return RefreshIndicator(
      onRefresh: _loadAll,
      color: c.accent,
      backgroundColor: c.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        children: [
          const SizedBox(height: 16),
          _DeviceCard(tableInfo: _tableInfo!, wifiStatus: _wifiStatus!, hotspotSsid: _hotspotSsid),
          const SizedBox(height: 24),
          _SectionLabel('Wi-Fi'),
          const SizedBox(height: 10),
          _SavedNetworksCard(
            saved: _savedNetworks,
            activeSSID: _wifiStatus?.ssid,
            onForget: (ssid) => _confirmForget(ssid),
            onAddNetwork: () => _showAddNetworkSheet(),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Network Scan'),
          const SizedBox(height: 10),
          _NetworkScanCard(
            networks: _scannedNetworks,
            scanning: _scanning,
            onScan: _scanNetworks,
            onConnect: (net) => _showConnectSheet(net),
          ),
          const SizedBox(height: 24),
          _SectionLabel('Hotspot'),
          const SizedBox(height: 10),
          _HotspotCard(
            currentSsid: _hotspotSsid,
            currentPassword: _hotspotPassword,
            currentHostname: _hostname,
            onSaveSsid: _saveHotspotSsid,
            onSavePassword: _saveHotspotPassword,
            onSaveHostname: _saveHostname,
          ),
          const SizedBox(height: 24),
          _SectionLabel('System'),
          const SizedBox(height: 10),
          _SystemCard(
            onRestart: () => _confirmSystemAction('restart'),
            onShutdown: () => _confirmSystemAction('shutdown'),
          ),
        ],
      ),
    );
  }

  void _confirmForget(String ssid) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.col.surface,
        title: const Text('Forget Network'),
        content: Text('Remove "$ssid" from saved networks?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () { Navigator.pop(ctx); _forgetNetwork(ssid); },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Forget'),
          ),
        ],
      ),
    );
  }

  void _confirmSystemAction(String action) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.col.surface,
        title: Text(action == 'restart' ? 'Restart System?' : 'Shutdown System?'),
        content: Text(action == 'restart'
            ? 'The table will restart. Connection will drop for ~30 seconds.'
            : 'The table will shut down completely. You will need to power-cycle it.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                if (action == 'restart') {
                  await ApiClient.instance.restartSystem();
                  _showSnack('Restarting… reconnect in ~30s');
                } else {
                  await ApiClient.instance.shutdownSystem();
                  _showSnack('Table is shutting down');
                }
              } catch (e) {
                _showError('$e');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'restart' ? context.col.accent : Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: Text(action == 'restart' ? 'Restart' : 'Shutdown'),
          ),
        ],
      ),
    );
  }

  void _showConnectSheet(ScannedNetwork net) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConnectSheet(
        network: net,
        onConnect: (ssid, pw) async {
          try {
            await ApiClient.instance.connectToWifi(ssid, pw);
            if (!mounted) return;
            _showSnack('Connecting to "$ssid"… table will reboot');
            await Future.delayed(const Duration(seconds: 2));
            await _loadAll();
          } catch (e) {
            _showError('Failed: $e');
          }
        },
      ),
    );
  }

  void _showAddNetworkSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConnectSheet(
        onConnect: (ssid, pw) async {
          try {
            await ApiClient.instance.connectToWifi(ssid, pw);
            if (!mounted) return;
            _showSnack('Connecting to "$ssid"… table will reboot');
            await Future.delayed(const Duration(seconds: 2));
            await _loadAll();
          } catch (e) {
            _showError('Failed: $e');
          }
        },
      ),
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.onBack, required this.onSetup});
  final VoidCallback onBack;
  final VoidCallback onSetup;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: Icon(LucideIcons.chevronLeft, size: 22, color: c.textPrimary),
          ),
          Expanded(
            child: Text(
              'Device & Wi-Fi',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary),
            ),
          ),
          GestureDetector(
            onTap: onSetup,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: c.accentMuted,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.plusCircle, size: 14, color: c.accent),
                  const SizedBox(width: 5),
                  Text('New Device', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.accent)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: context.col.textTertiary,
        letterSpacing: 1.0,
      ),
    );
  }
}

// ─── Device card ─────────────────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.tableInfo, required this.wifiStatus, required this.hotspotSsid});
  final TableInfo tableInfo;
  final WifiStatus wifiStatus;
  final String hotspotSsid;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final connected = wifiStatus.isConnected;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.accentMuted, c.accent.withValues(alpha: 0.06)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _PulsingDot(color: connected ? c.success : c.danger),
              const SizedBox(width: 8),
              Text(
                connected ? 'CONNECTED' : 'HOTSPOT MODE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  color: connected ? c.success : c.warning,
                ),
              ),
              const Spacer(),
              Text(
                'v${tableInfo.version}',
                style: TextStyle(fontSize: 12, color: c.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            tableInfo.name,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: c.textPrimary),
          ),
          const SizedBox(height: 6),
          if (connected) ...[
            _InfoRow(icon: LucideIcons.wifi, label: wifiStatus.ssid ?? ''),
            const SizedBox(height: 4),
            _InfoRow(icon: LucideIcons.mapPin, label: wifiStatus.ip ?? ''),
            const SizedBox(height: 4),
            _InfoRow(icon: LucideIcons.server, label: '${wifiStatus.hostname ?? 'raspberrypi'}.local'),
          ] else ...[
            _InfoRow(icon: LucideIcons.wifiOff, label: 'Hotspot: "$hotspotSsid"'),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0);
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Row(
      children: [
        Icon(icon, size: 13, color: c.textTertiary),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: c.textSecondary)),
      ],
    );
  }
}

// ─── Saved networks ───────────────────────────────────────────────────────────

class _SavedNetworksCard extends StatelessWidget {
  const _SavedNetworksCard({
    required this.saved,
    required this.activeSSID,
    required this.onForget,
    required this.onAddNetwork,
  });
  final List<SavedNetwork> saved;
  final String? activeSSID;
  final void Function(String ssid) onForget;
  final VoidCallback onAddNetwork;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ...saved.asMap().entries.map((entry) {
            final i = entry.key;
            final net = entry.value;
            final isActive = net.ssid == activeSSID;
            return Column(
              children: [
                if (i > 0) Divider(height: 1, color: c.divider, indent: 16),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Icon(
                    LucideIcons.wifi,
                    size: 20,
                    color: isActive ? c.accent : c.textSecondary,
                  ),
                  title: Text(
                    net.ssid,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: c.textPrimary,
                    ),
                  ),
                  subtitle: isActive
                      ? Text('Connected', style: TextStyle(fontSize: 12, color: c.success))
                      : Text('Saved', style: TextStyle(fontSize: 12, color: c.textTertiary)),
                  trailing: isActive
                      ? null
                      : IconButton(
                          icon: Icon(LucideIcons.trash2, size: 16, color: c.danger),
                          onPressed: () => onForget(net.ssid),
                        ),
                ),
              ],
            );
          }),
          Divider(height: 1, color: c.divider),
          InkWell(
            onTap: onAddNetwork,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(LucideIcons.plus, size: 18, color: c.accent),
                  const SizedBox(width: 10),
                  Text(
                    'Add Wi-Fi Network',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Network scan ─────────────────────────────────────────────────────────────

class _NetworkScanCard extends StatelessWidget {
  const _NetworkScanCard({
    required this.networks,
    required this.scanning,
    required this.onScan,
    required this.onConnect,
  });
  final List<ScannedNetwork> networks;
  final bool scanning;
  final VoidCallback onScan;
  final void Function(ScannedNetwork net) onConnect;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // Scan header row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                Icon(LucideIcons.searchCode, size: 18, color: c.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    scanning
                        ? 'Scanning…'
                        : networks.isEmpty
                            ? 'Tap to scan nearby networks'
                            : '${networks.length} networks found',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: c.textPrimary),
                  ),
                ),
                if (scanning)
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: c.accent),
                  )
                else
                  IconButton(
                    onPressed: onScan,
                    icon: Icon(LucideIcons.refreshCw, size: 18, color: c.accent),
                    tooltip: 'Scan',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
              ],
            ),
          ),
          if (networks.isNotEmpty) ...[
            Divider(height: 1, color: c.divider),
            ...networks.asMap().entries.map((entry) {
              final i = entry.key;
              final net = entry.value;
              return Column(
                children: [
                  if (i > 0) Divider(height: 1, color: c.divider, indent: 16),
                  _ScannedNetworkRow(
                    net: net,
                    onConnect: net.active ? null : () => onConnect(net),
                  ).animate(delay: Duration(milliseconds: i * 50)).fadeIn().slideX(begin: 0.04, end: 0),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _ScannedNetworkRow extends StatelessWidget {
  const _ScannedNetworkRow({required this.net, required this.onConnect});
  final ScannedNetwork net;
  final VoidCallback? onConnect;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: _SignalIcon(signal: net.signal, active: net.active),
      title: Row(
        children: [
          Expanded(
            child: Text(
              net.ssid,
              style: TextStyle(
                fontSize: 14,
                fontWeight: net.active ? FontWeight.w600 : FontWeight.w500,
                color: c.textPrimary,
              ),
            ),
          ),
          if (net.saved)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: c.accentMuted,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text('Saved', style: TextStyle(fontSize: 10, color: c.accent, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      subtitle: Text(
        '${net.security}  ·  ${net.signal}%',
        style: TextStyle(fontSize: 12, color: c.textTertiary),
      ),
      trailing: net.active
          ? Text('Active', style: TextStyle(fontSize: 12, color: c.success, fontWeight: FontWeight.w600))
          : TextButton(
              onPressed: onConnect,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text('Connect', style: TextStyle(fontSize: 13, color: c.accent)),
            ),
    );
  }
}

class _SignalIcon extends StatelessWidget {
  const _SignalIcon({required this.signal, required this.active});
  final int signal;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final color = active ? c.accent : c.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final threshold = (i + 1) * 25;
        return Container(
          width: 4,
          height: 6.0 + i * 4,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: signal >= threshold ? color : c.surfaceOutline,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

// ─── Hotspot card ─────────────────────────────────────────────────────────────

class _HotspotCard extends StatefulWidget {
  const _HotspotCard({
    required this.currentSsid,
    required this.currentPassword,
    required this.currentHostname,
    required this.onSaveSsid,
    required this.onSavePassword,
    required this.onSaveHostname,
  });
  final String currentSsid;
  final String currentPassword;
  final String currentHostname;
  final Future<void> Function(String) onSaveSsid;
  final Future<void> Function(String) onSavePassword;
  final Future<void> Function(String) onSaveHostname;

  @override
  State<_HotspotCard> createState() => _HotspotCardState();
}

class _HotspotCardState extends State<_HotspotCard> {
  late final _ssidCtrl = TextEditingController(text: widget.currentSsid);
  late final _pwCtrl = TextEditingController(text: widget.currentPassword);
  late final _hostnameCtrl = TextEditingController(text: widget.currentHostname);
  bool _pwVisible = false;
  bool _savingSsid = false;
  bool _savingPw = false;
  bool _savingHostname = false;

  @override
  void didUpdateWidget(_HotspotCard old) {
    super.didUpdateWidget(old);
    if (old.currentSsid != widget.currentSsid) _ssidCtrl.text = widget.currentSsid;
    if (old.currentPassword != widget.currentPassword) _pwCtrl.text = widget.currentPassword;
    if (old.currentHostname != widget.currentHostname) _hostnameCtrl.text = widget.currentHostname;
  }

  @override
  void dispose() {
    _ssidCtrl.dispose();
    _pwCtrl.dispose();
    _hostnameCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecor(AppColorSet c, IconData icon, {Widget? suffix}) => InputDecoration(
        prefixIcon: Icon(icon, size: 18, color: c.textTertiary),
        suffixIcon: suffix,
        filled: true,
        fillColor: c.surfaceRaised,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.surfaceOutline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.surfaceOutline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: c.accent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final isOpen = widget.currentPassword.isEmpty;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.wifiOff, size: 18, color: c.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Hotspot Settings',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isOpen ? c.success.withValues(alpha: 0.12) : c.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(isOpen ? 'Open' : 'Protected',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isOpen ? c.success : c.accent)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Settings for the fallback hotspot when no Wi-Fi is available.',
              style: TextStyle(fontSize: 12, color: c.textTertiary, height: 1.4)),
          const SizedBox(height: 16),

          // ── Hotspot Name (SSID) ──
          Text('Hotspot Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ssidCtrl,
                  style: TextStyle(color: c.textPrimary, fontSize: 14),
                  decoration: _fieldDecor(c, LucideIcons.wifi),
                ),
              ),
              const SizedBox(width: 8),
              _SaveButton(
                saving: _savingSsid,
                onTap: () async {
                  final v = _ssidCtrl.text.trim();
                  if (v.isEmpty) return;
                  setState(() => _savingSsid = true);
                  await widget.onSaveSsid(v);
                  if (mounted) setState(() => _savingSsid = false);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Hotspot Password ──
          Text('Hotspot Password', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pwCtrl,
                  obscureText: !_pwVisible,
                  style: TextStyle(color: c.textPrimary, fontSize: 14),
                  decoration: _fieldDecor(
                    c, LucideIcons.lock,
                    suffix: IconButton(
                      icon: Icon(_pwVisible ? LucideIcons.eyeOff : LucideIcons.eye, size: 18, color: c.textTertiary),
                      onPressed: () => setState(() => _pwVisible = !_pwVisible),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _SaveButton(
                saving: _savingPw,
                onTap: () async {
                  setState(() => _savingPw = true);
                  await widget.onSavePassword(_pwCtrl.text.trim());
                  if (mounted) setState(() => _savingPw = false);
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── mDNS Hostname ──
          Text('mDNS Hostname', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
          const SizedBox(height: 2),
          Text('Connect via "[name].local" on local network.',
              style: TextStyle(fontSize: 11, color: c.textTertiary)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hostnameCtrl,
                  style: TextStyle(color: c.textPrimary, fontSize: 14),
                  keyboardType: TextInputType.url,
                  decoration: _fieldDecor(c, LucideIcons.server),
                ),
              ),
              const SizedBox(width: 8),
              _SaveButton(
                saving: _savingHostname,
                onTap: () async {
                  final v = _hostnameCtrl.text.trim();
                  if (v.isEmpty) return;
                  setState(() => _savingHostname = true);
                  await widget.onSaveHostname(v);
                  if (mounted) setState(() => _savingHostname = false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saving, required this.onTap});
  final bool saving;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return GestureDetector(
      onTap: saving ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: saving
            ? const SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Text('Save', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black)),
      ),
    );
  }
}

// ─── System card ─────────────────────────────────────────────────────────────

class _SystemCard extends StatelessWidget {
  const _SystemCard({required this.onRestart, required this.onShutdown});
  final VoidCallback onRestart;
  final VoidCallback onShutdown;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return AppCard(
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onRestart,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Restart'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: c.accent,
                side: BorderSide(color: c.accent.withValues(alpha: 0.4)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onShutdown,
              icon: const Icon(LucideIcons.powerOff, size: 16),
              label: const Text('Shutdown'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                foregroundColor: c.danger,
                side: BorderSide(color: c.danger.withValues(alpha: 0.4)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Connect / Add network sheet ─────────────────────────────────────────────

class _ConnectSheet extends StatefulWidget {
  const _ConnectSheet({this.network, required this.onConnect});
  final ScannedNetwork? network;
  final Future<void> Function(String ssid, String pw) onConnect;

  @override
  State<_ConnectSheet> createState() => _ConnectSheetState();
}

class _ConnectSheetState extends State<_ConnectSheet> {
  late final _ssidCtrl = TextEditingController(text: widget.network?.ssid ?? '');
  final _pwCtrl = TextEditingController();
  bool _visible = false;
  bool _connecting = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _ssidCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final hasNetwork = widget.network != null;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SheetHandle(),
                  Text(
                    hasNetwork ? 'Connect to "${widget.network!.ssid}"' : 'Add Wi-Fi Network',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
                  ),
                  const SizedBox(height: 20),
                  if (!hasNetwork) ...[
                    _SheetField(
                      controller: _ssidCtrl,
                      label: 'Network Name (SSID)',
                      hint: 'e.g. Home Wi-Fi',
                      icon: LucideIcons.wifi,
                      validator: (v) => (v == null || v.isEmpty) ? 'Enter network name' : null,
                    ),
                    const SizedBox(height: 14),
                  ],
                  _SheetField(
                    controller: _pwCtrl,
                    label: 'Password',
                    hint: widget.network?.security.contains('Open') == true
                        ? 'No password required'
                        : 'Wi-Fi password',
                    icon: LucideIcons.lock,
                    obscure: !_visible,
                    suffix: IconButton(
                      icon: Icon(
                        _visible ? LucideIcons.eyeOff : LucideIcons.eye,
                        size: 18,
                        color: c.textTertiary,
                      ),
                      onPressed: () => setState(() => _visible = !_visible),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _connecting
                          ? null
                          : () async {
                              if (!_formKey.currentState!.validate()) return;
                              setState(() => _connecting = true);
                              final nav = Navigator.of(context);
                              try {
                                await widget.onConnect(_ssidCtrl.text.trim(), _pwCtrl.text);
                                if (!mounted) return;
                                nav.pop();
                              } catch (e) {
                                if (mounted) setState(() => _connecting = false);
                              }
                            },
                      child: _connecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(hasNetwork ? 'Connect & Reboot' : 'Save & Connect'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Table will reboot to apply the new network.',
                      style: TextStyle(fontSize: 12, color: c.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.obscure = false,
    this.suffix,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: TextStyle(color: c.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.textTertiary, fontSize: 13),
            prefixIcon: Icon(icon, size: 18, color: c.textTertiary),
            suffixIcon: suffix,
            filled: true,
            fillColor: c.surfaceRaised,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.surfaceOutline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.surfaceOutline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: c.accent, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Error state ─────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.wifiOff, size: 48, color: c.textTertiary),
            const SizedBox(height: 16),
            Text(
              'Cannot reach table',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              'Make sure your phone is on the same Wi-Fi network as the table.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: c.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shared ───────────────────────────────────────────────────────────────────

class _PulsingDot extends StatelessWidget {
  const _PulsingDot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.2)),
        )
            .animate(onPlay: (ctrl) => ctrl.repeat())
            .scale(begin: const Offset(1, 1), end: const Offset(1.5, 1.5), duration: 1200.ms)
            .fadeOut(duration: 1200.ms),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      ],
    );
  }
}
