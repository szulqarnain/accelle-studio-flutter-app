import 'dart:math';
import 'package:flutter/foundation.dart';
import 'api_client.dart';

enum PlaybackStatus { stopped, playing, paused, homing }

class PatternFile {
  final String filename;
  final String displayName;
  final int playCount;
  final double? durationSeconds;
  final String? durationFormatted;
  final String? lastPlayed;

  const PatternFile({
    required this.filename,
    required this.displayName,
    this.playCount = 0,
    this.durationSeconds,
    this.durationFormatted,
    this.lastPlayed,
  });

  static String nameFromFilename(String filename) {
    return filename
        .replaceAll('.thr', '')
        .replaceAll(RegExp(r'[-_]'), ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ')
        .trim();
  }
}

class AppState extends ChangeNotifier {
  static final AppState instance = AppState._();
  AppState._();

  TableInfo? tableInfo;
  SerialStatus? serialStatus;
  bool deviceOnline = false;

  List<PatternFile> patterns = [];
  bool patternsLoaded = false;

  List<String> playlistNames = [];
  bool playlistsLoaded = false;

  AutoPlayMode? autoPlay;

  PlaybackStatus playbackStatus = PlaybackStatus.stopped;
  String? currentFilename;

  String get currentDisplayName =>
      currentFilename != null ? PatternFile.nameFromFilename(currentFilename!) : 'Nothing playing';

  bool get isPlaying => playbackStatus == PlaybackStatus.playing;
  bool get isPaused => playbackStatus == PlaybackStatus.paused;
  bool get isHoming => playbackStatus == PlaybackStatus.homing;
  bool get isStopped => playbackStatus == PlaybackStatus.stopped;

  Future<void> initialize() async {
    try {
      deviceOnline = await ApiClient.instance.ping();
      if (!deviceOnline) { notifyListeners(); return; }
      final results = await Future.wait([
        ApiClient.instance.getTableInfo(),
        ApiClient.instance.getSerialStatus(),
        ApiClient.instance.getAutoPlayMode(),
      ]);
      tableInfo = results[0] as TableInfo;
      serialStatus = results[1] as SerialStatus;
      autoPlay = results[2] as AutoPlayMode;
      notifyListeners();
    } catch (_) {
      deviceOnline = false;
      notifyListeners();
    }
  }

  Future<void> loadPatterns() async {
    final results = await Future.wait([
      ApiClient.instance.listPatterns(),
      ApiClient.instance.getPatternHistory(),
    ]);
    final filenames = results[0] as List<String>;
    final history = results[1] as Map<String, PatternHistory>;
    patterns = filenames.map((f) {
      final h = history[f];
      return PatternFile(
        filename: f,
        displayName: PatternFile.nameFromFilename(f),
        playCount: h?.playCount ?? 0,
        durationSeconds: h?.durationSeconds,
        durationFormatted: h?.durationFormatted,
        lastPlayed: h?.lastPlayed,
      );
    }).toList();
    patternsLoaded = true;
    notifyListeners();
  }

  Future<void> loadPlaylists() async {
    playlistNames = await ApiClient.instance.listPlaylists();
    playlistsLoaded = true;
    notifyListeners();
  }

  Future<void> playPattern(String filename) async {
    currentFilename = filename;
    playbackStatus = PlaybackStatus.playing;
    notifyListeners();
    await ApiClient.instance.runPattern(filename);
  }

  Future<void> playRandom() async {
    if (patterns.isEmpty) await loadPatterns();
    if (patterns.isEmpty) return;
    final p = patterns[Random().nextInt(patterns.length)];
    await playPattern(p.filename);
  }

  Future<void> stop() async {
    playbackStatus = PlaybackStatus.stopped;
    currentFilename = null;
    notifyListeners();
    await ApiClient.instance.stopExecution();
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      playbackStatus = PlaybackStatus.paused;
      notifyListeners();
      await ApiClient.instance.pauseExecution();
    } else if (isPaused) {
      playbackStatus = PlaybackStatus.playing;
      notifyListeners();
      await ApiClient.instance.resumeExecution();
    }
  }

  Future<void> skip() async {
    await ApiClient.instance.skipPattern();
  }

  Future<void> home() async {
    playbackStatus = PlaybackStatus.homing;
    notifyListeners();
    try {
      await ApiClient.instance.sendHome();
    } finally {
      playbackStatus = PlaybackStatus.stopped;
      notifyListeners();
    }
  }

  Future<void> runPlaylist(String name, {bool shuffle = false}) async {
    playbackStatus = PlaybackStatus.playing;
    notifyListeners();
    await ApiClient.instance.runPlaylist(name, shuffle: shuffle);
  }
}
