import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../data/mock_data.dart';
import '../../data/models.dart';
import '../../shared/widgets/common.dart';
import '../../theme/app_theme.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  bool _scheduleEnabled = true;
  late List<ScheduleSlot> _slots;

  @override
  void initState() {
    super.initState();
    _slots = List.from(mockSchedule);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.col;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        title: const Text('Still Sands Schedule'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(LucideIcons.chevronLeft, color: c.textPrimary),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Enable Schedule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                      const SizedBox(height: 2),
                      Text('Auto-run at scheduled times', style: TextStyle(fontSize: 12, color: c.textSecondary)),
                    ],
                  ),
                ),
                Switch(value: _scheduleEnabled, onChanged: (v) => setState(() => _scheduleEnabled = v)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SectionHeader(title: 'Schedule Slots'),
          const SizedBox(height: AppSpacing.sm),
          ..._slots.asMap().entries.map((entry) {
            final i = entry.key;
            final slot = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${slot.startTime} – ${slot.endTime}',
                            style: monoStyle(fontSize: 16, color: c.textPrimary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        Switch(
                          value: slot.enabled,
                          onChanged: (v) => setState(() {
                            _slots[i] = ScheduleSlot(
                              startTime: slot.startTime,
                              endTime: slot.endTime,
                              days: slot.days,
                              enabled: v,
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: slot.days.map((day) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: slot.enabled ? c.accentMuted : c.surfaceRaised,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: Text(
                          day,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: slot.enabled ? c.accent : c.textTertiary),
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Add Schedule'),
                  content: const Text('Schedule editor coming soon.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
                  ],
                ),
              );
            },
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Add Schedule'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          ),
        ],
      ),
    );
  }
}
