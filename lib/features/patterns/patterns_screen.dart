import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/app_state.dart';
import '../../data/api_client.dart';
import '../../shared/widgets/common.dart';
import '../../theme/app_theme.dart';

class PatternsScreen extends StatefulWidget {
  const PatternsScreen({super.key});

  @override
  State<PatternsScreen> createState() => _PatternsScreenState();
}

enum _SortBy { name, playCount, duration }

class _PatternsScreenState extends State<PatternsScreen> {
  String _query = '';
  _SortBy _sort = _SortBy.playCount;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (!AppState.instance.patternsLoaded) _loadPatterns();
  }

  Future<void> _loadPatterns() async {
    setState(() { _loading = true; _error = null; });
    try {
      await AppState.instance.loadPatterns();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<PatternFile> get _filtered {
    var items = AppState.instance.patterns.where((p) {
      return _query.isEmpty || p.displayName.toLowerCase().contains(_query.toLowerCase()) ||
          p.filename.toLowerCase().contains(_query.toLowerCase());
    }).toList();
    switch (_sort) {
      case _SortBy.name:
        items.sort((a, b) => a.displayName.compareTo(b.displayName));
      case _SortBy.playCount:
        items.sort((a, b) => b.playCount.compareTo(a.playCount));
      case _SortBy.duration:
        items.sort((a, b) => (b.durationSeconds ?? 0).compareTo(a.durationSeconds ?? 0));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final c = context.col;
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('Patterns',
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: c.textPrimary)),
                    ),
                    if (AppState.instance.patternsLoaded)
                      Text('${AppState.instance.patterns.length}',
                          style: TextStyle(fontSize: 14, color: c.textTertiary)),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton(
                      onPressed: _loadPatterns,
                      icon: Icon(LucideIcons.refreshCw, size: 18, color: c.textSecondary),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
                child: _SearchField(onChanged: (v) => setState(() => _query = v)),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  children: [
                    _SortButton(sort: _sort, onChanged: (s) => setState(() => _sort = s)),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(child: _buildBody(c)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBody(AppColorSet c) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return _ErrorView(error: _error!, onRetry: _loadPatterns);
    if (!AppState.instance.patternsLoaded) return const SizedBox();

    final patterns = _filtered;
    if (patterns.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.searchX, size: 40, color: c.textTertiary),
            const SizedBox(height: 12),
            Text('No patterns found', style: TextStyle(color: c.textSecondary)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.88,
      ),
      itemCount: patterns.length,
      itemBuilder: (context, i) {
        final p = patterns[i];
        return _PatternCard(
          pattern: p,
          isNowPlaying: AppState.instance.currentFilename == p.filename && !AppState.instance.isStopped,
          onTap: () => _showDetail(context, p),
        );
      },
    );
  }

  void _showDetail(BuildContext context, PatternFile pattern) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.col.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      builder: (_) => _PatternDetailSheet(
        pattern: pattern,
        onRun: () {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('▶ ${pattern.displayName}')),
            );
          }
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return TextField(
      onChanged: onChanged,
      style: TextStyle(color: c.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: 'Search patterns…',
        prefixIcon: Icon(LucideIcons.search, size: 18, color: c.textTertiary),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final _SortBy sort;
  final ValueChanged<_SortBy> onChanged;
  const _SortButton({required this.sort, required this.onChanged});

  String get _label {
    switch (sort) {
      case _SortBy.name: return 'Sort: Name';
      case _SortBy.playCount: return 'Sort: Plays';
      case _SortBy.duration: return 'Sort: Duration';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_SortBy>(
      onSelected: onChanged,
      itemBuilder: (_) => const [
        PopupMenuItem(value: _SortBy.playCount, child: Text('Sort by plays')),
        PopupMenuItem(value: _SortBy.name, child: Text('Sort by name')),
        PopupMenuItem(value: _SortBy.duration, child: Text('Sort by duration')),
      ],
      child: AppChip(label: _label),
    );
  }
}

class _PatternCard extends StatelessWidget {
  final PatternFile pattern;
  final bool isNowPlaying;
  final VoidCallback onTap;
  const _PatternCard({required this.pattern, required this.isNowPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final hash = pattern.filename.hashCode;
    final hue = (hash % 360).toDouble().abs();
    final bgColor = HSLColor.fromAHSL(1, hue, 0.3, 0.12).toColor();
    final fgColor = HSLColor.fromAHSL(1, hue, 0.6, 0.65).toColor();

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Icon(LucideIcons.music2, color: fgColor, size: 32),
                  ),
                ),
                if (isNowPlaying)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: c.accent,
                        borderRadius: BorderRadius.circular(AppRadius.chip),
                      ),
                      child: const Text('▶ Playing',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black)),
                    ),
                  )
                else if (pattern.playCount > 0)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: StatusDot(color: c.accent, size: 8),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(pattern.displayName, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary)),
          const SizedBox(height: 2),
          Row(
            children: [
              if (pattern.durationFormatted != null)
                Text(pattern.durationFormatted!,
                    style: TextStyle(fontSize: 11, color: c.textTertiary)),
              if (pattern.durationFormatted != null && pattern.playCount > 0)
                Text(' · ', style: TextStyle(fontSize: 11, color: c.textTertiary)),
              if (pattern.playCount > 0)
                Text('${pattern.playCount}x', style: TextStyle(fontSize: 11, color: c.textTertiary)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PatternDetailSheet extends StatelessWidget {
  final PatternFile pattern;
  final VoidCallback onRun;
  const _PatternDetailSheet({required this.pattern, required this.onRun});

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final playlists = AppState.instance.playlistNames;
    final hash = pattern.filename.hashCode;
    final hue = (hash % 360).toDouble().abs();
    final bgColor = HSLColor.fromAHSL(1, hue, 0.3, 0.10).toColor();
    final fgColor = HSLColor.fromAHSL(1, hue, 0.6, 0.65).toColor();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetHandle(),
            Container(
              height: 120,
              decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(AppRadius.card)),
              child: Center(child: Icon(LucideIcons.music2, color: fgColor, size: 48)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(pattern.displayName,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary)),
            const SizedBox(height: 4),
            Text(
              [
                if (pattern.durationFormatted != null) 'Duration: ${pattern.durationFormatted}',
                if (pattern.playCount > 0) 'Played ${pattern.playCount}x',
              ].join(' · '),
              style: TextStyle(fontSize: 13, color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final nav = Navigator.of(context);
                      try {
                        await AppState.instance.playPattern(pattern.filename);
                        nav.pop();
                        onRun();
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    icon: const Icon(LucideIcons.play, size: 18),
                    label: const Text('Run Pattern'),
                  ),
                ),
                if (playlists.isNotEmpty) ...[
                  const SizedBox(width: AppSpacing.sm),
                  PopupMenuButton<String>(
                    onSelected: (playlist) async {
                      try {
                        await ApiClient.instance.addToPlaylist(playlist, pattern.filename);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added to $playlist')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context)
                            .showSnackBar(SnackBar(content: Text('Error: $e')));
                      }
                    },
                    itemBuilder: (_) => playlists
                        .map((p) => PopupMenuItem(value: p, child: Text(p)))
                        .toList(),
                    child: OutlinedButton(
                      onPressed: null,
                      child: const Icon(LucideIcons.plus, size: 18),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.wifiOff, size: 40, color: context.col.textTertiary),
          const SizedBox(height: 12),
          const Text('Cannot load patterns'),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(LucideIcons.refreshCw, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
