import 'models.dart';

final mockStatus = TableStatusMock(
  tableName: "Ahmad's Sand Table",
  online: true,
  playbackState: PlaybackState.playing,
  currentPatternName: 'Spiral Bloom',
  progress: 0.62,
  estimatedRemaining: const Duration(minutes: 14, seconds: 20),
  currentPlaylistName: 'Evening Calm',
  playlistIndex: 2,
  playlistLength: 5,
);

final mockPatterns = <PatternItem>[
  PatternItem(
    path: 'geometric/spiral_bloom.thr',
    name: 'Spiral Bloom',
    category: 'Geometric',
    dateModified: DateTime(2026, 6, 10),
    coordinatesCount: 4820,
    recentlyPlayed: true,
  ),
  PatternItem(
    path: 'organic/dune_waves.thr',
    name: 'Dune Waves',
    category: 'Organic',
    dateModified: DateTime(2026, 6, 12),
    coordinatesCount: 3120,
    recentlyPlayed: true,
  ),
  PatternItem(
    path: 'geometric/hex_lattice.thr',
    name: 'Hex Lattice',
    category: 'Geometric',
    dateModified: DateTime(2026, 5, 28),
    coordinatesCount: 6210,
  ),
  PatternItem(
    path: 'mandala/lotus_field.thr',
    name: 'Lotus Field',
    category: 'Mandala',
    dateModified: DateTime(2026, 6, 1),
    coordinatesCount: 5430,
    recentlyPlayed: true,
  ),
  PatternItem(
    path: 'mandala/eight_fold.thr',
    name: 'Eight Fold',
    category: 'Mandala',
    dateModified: DateTime(2026, 4, 19),
    coordinatesCount: 2890,
  ),
  PatternItem(
    path: 'organic/coastline.thr',
    name: 'Coastline',
    category: 'Organic',
    dateModified: DateTime(2026, 6, 14),
    coordinatesCount: 7340,
  ),
  PatternItem(
    path: 'abstract/fractured.thr',
    name: 'Fractured',
    category: 'Abstract',
    dateModified: DateTime(2026, 3, 2),
    coordinatesCount: 1980,
  ),
  PatternItem(
    path: 'abstract/whisper.thr',
    name: 'Whisper',
    category: 'Abstract',
    dateModified: DateTime(2026, 5, 9),
    coordinatesCount: 4010,
  ),
];

final mockPlaylists = <PlaylistItem>[
  const PlaylistItem(
    name: 'Evening Calm',
    patternNames: ['Spiral Bloom', 'Dune Waves', 'Whisper', 'Lotus Field'],
    shuffle: false,
    loop: true,
    pauseBetween: Duration(seconds: 8),
  ),
  const PlaylistItem(
    name: 'Morning Energy',
    patternNames: ['Hex Lattice', 'Fractured', 'Coastline'],
    shuffle: true,
    loop: true,
  ),
  const PlaylistItem(
    name: 'Guest Mode',
    patternNames: ['Eight Fold', 'Lotus Field'],
    shuffle: false,
    loop: false,
    pauseBetween: Duration(seconds: 3),
  ),
];

final mockLedEffects = <LedEffectItem>[
  const LedEffectItem(name: 'Solid', selected: true),
  const LedEffectItem(name: 'Breathe'),
  const LedEffectItem(name: 'Rainbow'),
  const LedEffectItem(name: 'Theater Chase'),
  const LedEffectItem(name: 'Fire Flicker'),
  const LedEffectItem(name: 'Ocean Fade'),
  const LedEffectItem(name: 'Twinkle'),
];

final mockSchedule = <ScheduleSlot>[
  const ScheduleSlot(
    startTime: '23:00',
    endTime: '07:00',
    days: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  ),
  const ScheduleSlot(
    startTime: '13:00',
    endTime: '14:30',
    days: ['Sat', 'Sun'],
    enabled: false,
  ),
];

final mockKnownTables = <KnownTableItem>[
  const KnownTableItem(
    id: 't1',
    name: "Ahmad's Sand Table",
    ip: '192.168.1.42',
    online: true,
    active: true,
    version: 'v2.4.1',
    lastSeen: 'Now',
  ),
  const KnownTableItem(
    id: 't2',
    name: 'Living Room Table',
    ip: '192.168.1.55',
    online: false,
    version: 'v2.3.0',
    lastSeen: '2 days ago',
  ),
];

final mockDiscoveredDevices = <DiscoveredDevice>[
  const DiscoveredDevice(
    name: 'Accelle-Kitchen',
    ip: '192.168.1.77',
    port: 8080,
    signalStrength: 3,
  ),
  const DiscoveredDevice(
    name: 'Accelle-Office',
    ip: '192.168.1.83',
    port: 8080,
    signalStrength: 1,
  ),
];
