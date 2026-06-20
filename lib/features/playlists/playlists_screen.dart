import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/app_state.dart';
import '../../data/api_client.dart';
import '../../shared/widgets/common.dart';
import '../../theme/app_theme.dart';

class PlaylistsScreen extends StatefulWidget {
  const PlaylistsScreen({super.key});

  @override
  State<PlaylistsScreen> createState() => _PlaylistsScreenState();
}

class _PlaylistsScreenState extends State<PlaylistsScreen> {
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!AppState.instance.playlistsLoaded) _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AppState.instance.loadPlaylists();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) => SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Playlists',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary)),
                  ),
                  IconButton(
                    onPressed: () => _showCreateSheet(context),
                    icon: Icon(LucideIcons.plus, size: 20, color: c.accent),
                    style: IconButton.styleFrom(
                      backgroundColor: c.accentMuted,
                      padding: const EdgeInsets.all(8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(c)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppColorSet c) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.wifiOff, size: 40, color: c.textTertiary),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(LucideIcons.refreshCw, size: 16),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final names = AppState.instance.playlistNames;
    if (names.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.listMusic, size: 48, color: c.textTertiary),
            const SizedBox(height: 16),
            Text('No playlists yet', style: TextStyle(fontSize: 16, color: c.textSecondary)),
            const SizedBox(height: 8),
            Text('Tap + to create one', style: TextStyle(fontSize: 13, color: c.textTertiary)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      color: c.accent,
      backgroundColor: c.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: names.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) => _PlaylistCard(
          name: names[i],
          onTap: () => _showEditor(context, names[i]),
          onDelete: () => _confirmDelete(context, names[i]),
          onRun: () => _runPlaylist(context, names[i]),
        ),
      ),
    );
  }

  Future<void> _runPlaylist(BuildContext context, String name) async {
    try {
      await AppState.instance.runPlaylist(name);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('▶ Playing: $name')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _confirmDelete(BuildContext context, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.col.surface,
        title: const Text('Delete Playlist'),
        content: Text('Delete "$name"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiClient.instance.deletePlaylist(name);
                await _load();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.col.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Text('New Playlist',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: context.col.textPrimary)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Playlist name'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final name = ctrl.text.trim();
                  if (name.isEmpty) return;
                  final nav = Navigator.of(ctx);
                  try {
                    await ApiClient.instance.createPlaylist(name);
                    nav.pop();
                    await _load();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Create'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showEditor(BuildContext context, String name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.col.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _PlaylistEditorSheet(name: name, onChanged: _load),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  const _PlaylistCard({
    required this.name,
    required this.onTap,
    required this.onDelete,
    required this.onRun,
  });
  final String name;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRun;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: c.accentMuted, borderRadius: BorderRadius.circular(12)),
            child: Icon(LucideIcons.listMusic, color: c.accent),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(name,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary)),
          ),
          IconButton(
            onPressed: onRun,
            icon: Icon(LucideIcons.play, size: 18, color: c.accent),
            style: IconButton.styleFrom(
              backgroundColor: c.accentMuted,
              padding: const EdgeInsets.all(8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            onSelected: (v) { if (v == 'delete') { onDelete(); } },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            icon: Icon(LucideIcons.moreVertical, size: 18, color: c.textTertiary),
          ),
        ],
      ),
    );
  }
}

class _PlaylistEditorSheet extends StatefulWidget {
  const _PlaylistEditorSheet({required this.name, required this.onChanged});
  final String name;
  final VoidCallback onChanged;

  @override
  State<_PlaylistEditorSheet> createState() => _PlaylistEditorSheetState();
}

class _PlaylistEditorSheetState extends State<_PlaylistEditorSheet> {
  PlaylistDetail? _playlist;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final d = await ApiClient.instance.getPlaylist(widget.name);
      if (mounted) setState(() { _playlist = d; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollCtrl) => Column(
        children: [
          const SheetHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.name,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_playlist == null)
            Expanded(child: Center(child: Text('Failed to load', style: TextStyle(color: c.textTertiary))))
          else ...[
            Divider(height: AppSpacing.md, color: c.divider),
            Expanded(
              child: _playlist!.files.isEmpty
                  ? Center(child: Text('No patterns yet', style: TextStyle(color: c.textTertiary)))
                  : ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                      itemCount: _playlist!.files.length,
                      itemBuilder: (context, i) {
                        final f = _playlist!.files[i];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
                            child: Row(
                              children: [
                                Text('${i + 1}', style: monoStyle(fontSize: 13, color: c.textTertiary)),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Text(PatternFile.nameFromFilename(f),
                                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                                ),
                                Icon(LucideIcons.gripVertical, size: 18, color: c.textTertiary),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ElevatedButton.icon(
                onPressed: () async {
                  final nav = Navigator.of(context);
                  try {
                    await AppState.instance.runPlaylist(widget.name);
                    nav.pop();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                icon: const Icon(LucideIcons.play, size: 18),
                label: const Text('Run Playlist'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
