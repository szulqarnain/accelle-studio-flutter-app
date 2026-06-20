// Legacy model stubs kept for schedule_screen.dart

enum PlaybackState { playing, paused, stopped, homing }

class TableStatusMock {
  final String tableName;
  final bool online;
  final PlaybackState playbackState;
  final String? currentPatternName;
  final double progress; // 0.0–1.0
  final Duration? estimatedRemaining;
  final String? currentPlaylistName;
  final int? playlistIndex;
  final int? playlistLength;

  const TableStatusMock({
    required this.tableName,
    required this.online,
    required this.playbackState,
    this.currentPatternName,
    this.progress = 0,
    this.estimatedRemaining,
    this.currentPlaylistName,
    this.playlistIndex,
    this.playlistLength,
  });
}

class PatternItem {
  final String path;
  final String name;
  final String category;
  final DateTime dateModified;
  final int coordinatesCount;
  final bool recentlyPlayed;

  const PatternItem({
    required this.path,
    required this.name,
    required this.category,
    required this.dateModified,
    required this.coordinatesCount,
    this.recentlyPlayed = false,
  });
}

class PlaylistItem {
  final String name;
  final List<String> patternNames;
  final bool shuffle;
  final bool loop;
  final Duration pauseBetween;

  const PlaylistItem({
    required this.name,
    required this.patternNames,
    this.shuffle = false,
    this.loop = true,
    this.pauseBetween = const Duration(seconds: 5),
  });
}

class LedEffectItem {
  final String name;
  final bool selected;

  const LedEffectItem({required this.name, this.selected = false});
}

class ScheduleSlot {
  final String startTime;
  final String endTime;
  final List<String> days;
  final bool enabled;

  const ScheduleSlot({
    required this.startTime,
    required this.endTime,
    required this.days,
    this.enabled = true,
  });
}

class KnownTableItem {
  final String id;
  final String name;
  final String ip;
  final bool online;
  final bool active;
  final String? version;
  final String? lastSeen;

  const KnownTableItem({
    required this.id,
    required this.name,
    required this.ip,
    required this.online,
    this.active = false,
    this.version,
    this.lastSeen,
  });

  KnownTableItem copyWith({
    String? id,
    String? name,
    String? ip,
    bool? online,
    bool? active,
    String? version,
    String? lastSeen,
  }) => KnownTableItem(
    id: id ?? this.id,
    name: name ?? this.name,
    ip: ip ?? this.ip,
    online: online ?? this.online,
    active: active ?? this.active,
    version: version ?? this.version,
    lastSeen: lastSeen ?? this.lastSeen,
  );
}

/// A device found during mDNS / network scan — not yet paired.
class DiscoveredDevice {
  final String name;
  final String ip;
  final int port;
  final int signalStrength; // 0–3

  const DiscoveredDevice({
    required this.name,
    required this.ip,
    required this.port,
    this.signalStrength = 2,
  });
}
