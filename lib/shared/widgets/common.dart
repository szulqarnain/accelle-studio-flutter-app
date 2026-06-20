import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';

// ─── TapScale ────────────────────────────────────────────────────────────────

/// Wraps any widget with a press-scale animation for satisfying tap feedback.
class TapScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;

  const TapScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
  });

  @override
  State<TapScale> createState() => _TapScaleState();
}

class _TapScaleState extends State<TapScale>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 80),
    reverseDuration: const Duration(milliseconds: 200),
  );
  late final _anim = Tween<double>(begin: 1.0, end: widget.scale)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(scale: _anim, child: widget.child),
    );
  }
}

// ─── SectionHeader ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            decoration: BoxDecoration(
              color: c.accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
          ),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
              ),
              child: Text(actionLabel!),
            ),
        ],
      ),
    );
  }
}

// ─── StatusDot ───────────────────────────────────────────────────────────────

class StatusDot extends StatelessWidget {
  final Color color;
  final double size;

  const StatusDot({super.key, required this.color, this.size = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ─── AppChip ─────────────────────────────────────────────────────────────────

class AppChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Color? color;

  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final accent = color ?? c.accent;
    return TapScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.16) : c.surface,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(
            color: selected ? accent : c.surfaceOutline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? accent : c.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ─── RoundIconButton ─────────────────────────────────────────────────────────

class RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final Color? background;
  final Color? foreground;
  final bool pulsing;

  const RoundIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.size = 56,
    this.background,
    this.foreground,
    this.pulsing = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final bg = background ?? c.accent;
    final fg = foreground ?? (bg == c.accent ? Colors.black : c.textPrimary);

    final button = TapScale(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          boxShadow: bg == c.accent
              ? [BoxShadow(color: c.accent.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 4))]
              : null,
        ),
        child: Icon(icon, color: fg, size: size * 0.42),
      ),
    );

    if (!pulsing) return button;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulse ring
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 1.0, end: 1.5),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOut,
          onEnd: () {},
          builder: (_, v, _) {
            return Container(
              width: size * v,
              height: size * v,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: c.accent.withValues(alpha: (1.5 - v)),
                  width: 1.5,
                ),
              ),
            );
          },
        ),
        button,
      ],
    );
  }
}

// ─── AppCard ─────────────────────────────────────────────────────────────────

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    final bg = backgroundColor ?? c.surface;

    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: c.surfaceOutline),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return TapScale(
      onTap: onTap,
      child: content,
    );
  }
}

// ─── Sheet drag handle ────────────────────────────────────────────────────────

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: c.surfaceOutline,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
