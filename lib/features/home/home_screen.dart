import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/app_state.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/progress_ring.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    if (!AppState.instance.patternsLoaded) {
      AppState.instance.loadPatterns().catchError((_) {});
    }
    if (!AppState.instance.playlistsLoaded) {
      AppState.instance.loadPlaylists().catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) {
        final state = AppState.instance;
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _Header()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      _NowPlayingCard(state: state),
                      const SizedBox(height: AppSpacing.lg),
                      _ProgressSection(state: state),
                      const SizedBox(height: AppSpacing.xl),
                      _Controls(state: state),
                      const SizedBox(height: AppSpacing.xl),
                      SectionHeader(title: 'Quick Actions'),
                      const SizedBox(height: AppSpacing.sm),
                      _ShortcutGrid(state: state),
                      const SizedBox(height: AppSpacing.xl),
                      if (state.patternsLoaded && state.patterns.any((p) => p.playCount > 0)) ...[
                        SectionHeader(title: 'Recently Played'),
                        const SizedBox(height: AppSpacing.sm),
                        _RecentList(state: state),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final state = AppState.instance;
    final online = state.deviceOnline;
    final name = state.tableInfo?.name ?? 'No Device';

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: online ? c.success : c.danger,
              boxShadow: [BoxShadow(color: (online ? c.success : c.danger).withValues(alpha: 0.5), blurRadius: 6)],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          TapScale(
            onTap: () => context.push('/connectivity'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: c.surfaceOutline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(LucideIcons.wifi, size: 14, color: c.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    online ? 'Connected' : 'Offline',
                    style: TextStyle(fontSize: 12, color: online ? c.success : c.danger),
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

class _NowPlayingCard extends StatelessWidget {
  const _NowPlayingCard({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final isStopped = state.isStopped;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isStopped ? c.surfaceRaised : c.accentMuted,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isStopped ? LucideIcons.circle : LucideIcons.music,
              color: isStopped ? c.textTertiary : c.accent,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.currentDisplayName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isStopped ? c.textSecondary : c.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _statusColor(state, c).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _statusLabel(state),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _statusColor(state, c),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _statusLabel(AppState s) {
    if (s.isPlaying) return '▶ Playing';
    if (s.isPaused) return '⏸ Paused';
    if (s.isHoming) return '⌂ Homing';
    return '◼ Stopped';
  }

  Color _statusColor(AppState s, AppColorSet c) {
    if (s.isPlaying) return c.success;
    if (s.isPaused) return c.warning;
    if (s.isHoming) return c.accent;
    return c.textTertiary;
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final ringColor = state.isPlaying ? c.accent : state.isHoming ? c.warning : c.surfaceOutline;
    final progress = state.isPlaying ? 1.0 : 0.0;

    return ProgressRing(
      progress: progress,
      color: ringColor,
      strokeWidth: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          state.isHoming
              ? Icon(LucideIcons.compass, size: 22, color: c.textSecondary)
                  .animate(onPlay: (ctrl) => ctrl.repeat())
                  .rotate(duration: 2.seconds)
              : Icon(
                  state.isPlaying ? LucideIcons.music2 : LucideIcons.moon,
                  size: 22,
                  color: c.textSecondary,
                ),
          const SizedBox(height: 6),
          Text(
            state.isHoming ? 'Homing…' : state.isPlaying ? 'Running' : 'Idle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary),
          ),
          const SizedBox(height: 2),
          Text(
            state.tableInfo?.name ?? '—',
            style: TextStyle(fontSize: 12, color: c.textTertiary),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.94, 0.94), curve: Curves.easeOutBack);
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RoundIconButton(
          icon: LucideIcons.square,
          background: c.surfaceRaised,
          foreground: c.textPrimary,
          size: 52,
          onTap: () => state.stop().catchError((_) {}),
        ),
        const SizedBox(width: AppSpacing.lg),
        RoundIconButton(
          icon: state.isPlaying ? LucideIcons.pause : LucideIcons.play,
          size: 72,
          onTap: state.isStopped
              ? () => state.playRandom().catchError((_) {})
              : () => state.togglePlayPause().catchError((_) {}),
        ),
        const SizedBox(width: AppSpacing.lg),
        RoundIconButton(
          icon: LucideIcons.skipForward,
          background: c.surfaceRaised,
          foreground: c.textPrimary,
          size: 52,
          onTap: () => state.skip().catchError((_) {}),
        ),
      ],
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final items = [
      (icon: LucideIcons.shuffle, label: 'Random\nPattern', onTap: () => _onRandom(context)),
      (icon: LucideIcons.listMusic, label: 'Run\nPlaylist', onTap: () => _onPlaylist(context)),
      (icon: LucideIcons.eraser, label: 'Clear\nSand', onTap: () => _onClear(context)),
      (icon: LucideIcons.home, label: 'Send\nHome', onTap: () => _onHome(context)),
    ];

    return Row(
      children: items.asMap().entries.map((entry) {
        final item = entry.value;
        final i = entry.key;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AppCard(
              onTap: item.onTap,
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(color: c.accentMuted, borderRadius: BorderRadius.circular(12)),
                    child: Icon(item.icon, color: c.accent, size: 20),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.textSecondary, height: 1.3),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: i * 60)).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          ),
        );
      }).toList(),
    );
  }

  void _onRandom(BuildContext context) async {
    try {
      await AppState.instance.playRandom();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('▶ ${AppState.instance.currentDisplayName}')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _onPlaylist(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.col.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet))),
      builder: (_) => const _PlaylistPickerSheet(),
    );
  }

  void _onClear(BuildContext context) async {
    try {
      await AppState.instance.stop();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stopped')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _onHome(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Returning to home…')));
    try {
      await AppState.instance.home();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList({required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final recent = state.patterns
        .where((p) => p.playCount > 0)
        .toList()
      ..sort((a, b) => (b.lastPlayed ?? '').compareTo(a.lastPlayed ?? ''));
    final display = recent.take(8).toList();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: display.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          final p = display[i];
          return SizedBox(
            width: 100,
            child: AppCard(
              onTap: () async {
                try {
                  await AppState.instance.playPattern(p.filename);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('▶ ${p.displayName}')),
                  );
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              },
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 42,
                    decoration: BoxDecoration(color: c.accentMuted, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Icon(LucideIcons.music, size: 18, color: c.accent)),
                  ),
                  const SizedBox(height: 6),
                  Text(p.displayName, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  Text('${p.playCount}x', style: TextStyle(fontSize: 10, color: c.textTertiary)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlaylistPickerSheet extends StatelessWidget {
  const _PlaylistPickerSheet();

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final playlists = AppState.instance.playlistNames;

    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetHandle(),
              Text('Select Playlist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary)),
              const SizedBox(height: AppSpacing.md),
              if (playlists.isEmpty)
                Center(child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('No playlists', style: TextStyle(color: c.textTertiary)),
                ))
              else
                ...playlists.map((name) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AppCard(
                    onTap: () async {
                      final nav = Navigator.of(context);
                      try {
                        await AppState.instance.runPlaylist(name);
                        nav.pop();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('▶ Playing: $name')),
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      }
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: c.accentMuted, borderRadius: BorderRadius.circular(10)),
                          child: Icon(LucideIcons.listMusic, size: 18, color: c.accent),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(name,
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                        ),
                        Icon(LucideIcons.chevronRight, size: 16, color: c.textTertiary),
                      ],
                    ),
                  ),
                )),
            ],
          ),
        ),
      ),
    );
  }
}
