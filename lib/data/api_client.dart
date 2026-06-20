import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static final ApiClient instance = ApiClient._();
  ApiClient._();

  String baseUrl = 'http://raspberrypi.local:8080';
  Duration get _timeout => const Duration(seconds: 12);

  Uri _uri(String path) => Uri.parse('$baseUrl$path');

  Future<dynamic> _get(String path) async {
    final res = await http.get(_uri(path)).timeout(_timeout);
    if (res.statusCode != 200) throw ApiException(res.statusCode, res.body);
    return jsonDecode(res.body);
  }

  Future<dynamic> _post(String path, [Map<String, dynamic>? body]) async {
    final res = await http
        .post(
          _uri(path),
          headers: {'Content-Type': 'application/json'},
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    if (res.statusCode != 200) throw ApiException(res.statusCode, res.body);
    return jsonDecode(res.body);
  }

  Future<dynamic> _delete(String path, [Map<String, dynamic>? body]) async {
    final res = await http
        .delete(
          _uri(path),
          headers: {'Content-Type': 'application/json'},
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(_timeout);
    if (res.statusCode != 200) throw ApiException(res.statusCode, res.body);
    return jsonDecode(res.body);
  }

  // ── Device ───────────────────────────────────────────────────────────────

  Future<TableInfo> getTableInfo() async {
    final d = await _get('/api/table-info');
    return TableInfo.fromJson(d);
  }

  Future<SerialStatus> getSerialStatus() async {
    final d = await _get('/serial_status');
    return SerialStatus.fromJson(d);
  }

  Future<bool> ping() async {
    try {
      await http.get(_uri('/api/table-info')).timeout(const Duration(seconds: 4));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Wi-Fi ─────────────────────────────────────────────────────────────────

  Future<WifiStatus> getWifiStatus() async {
    final d = await _get('/api/wifi/status');
    return WifiStatus.fromJson(d);
  }

  Future<List<SavedNetwork>> getSavedNetworks() async {
    final d = await _get('/api/wifi/saved') as List;
    return d.map((e) => SavedNetwork.fromJson(e)).toList();
  }

  Future<List<ScannedNetwork>> scanNetworks() async {
    final d = await _get('/api/wifi/networks') as List;
    return d.map((e) => ScannedNetwork.fromJson(e)).toList();
  }

  Future<void> connectToWifi(String ssid, String password) async {
    await _post('/api/wifi/connect', {'ssid': ssid, 'password': password});
  }

  Future<void> forgetNetwork(String ssid) async {
    await _post('/api/wifi/forget', {'ssid': ssid});
  }

  Future<String> getHotspotPassword() async {
    final d = await _get('/api/wifi/hotspot/password');
    return (d['password'] ?? '') as String;
  }

  Future<void> setHotspotPassword(String password) async {
    await _post('/api/wifi/hotspot/password', {'password': password});
  }

  Future<String> getHotspotSsid() async {
    final d = await _get('/api/wifi/hotspot/ssid');
    return (d['ssid'] ?? '') as String;
  }

  Future<void> setHotspotSsid(String ssid) async {
    await _post('/api/wifi/hotspot/ssid', {'ssid': ssid});
  }

  Future<String> getHostname() async {
    final d = await _get('/api/wifi/hostname');
    return (d['hostname'] ?? '') as String;
  }

  Future<void> setHostname(String hostname) async {
    await _post('/api/wifi/hostname', {'hostname': hostname});
  }

  // ── Patterns ─────────────────────────────────────────────────────────────

  Future<List<String>> listPatterns() async {
    final d = await _get('/list_theta_rho_files') as List;
    return d.cast<String>();
  }

  Future<Map<String, PatternHistory>> getPatternHistory() async {
    final d = await _get('/api/pattern_history_all') as Map<String, dynamic>;
    return d.map((k, v) => MapEntry(k, PatternHistory.fromJson(v)));
  }

  // ── Playback ─────────────────────────────────────────────────────────────

  Future<void> runPattern(String filename) async {
    await _post('/run_theta_rho_file/${Uri.encodeComponent(filename)}');
  }

  Future<void> stopExecution() async {
    await _post('/stop_execution');
  }

  Future<void> pauseExecution() async {
    await _post('/pause_execution');
  }

  Future<void> resumeExecution() async {
    await _post('/resume_execution');
  }

  Future<void> sendHome() async {
    await _post('/send_home');
  }

  Future<void> moveToCenter() async {
    await _post('/move_to_center');
  }

  Future<void> moveToPerimeter() async {
    await _post('/move_to_perimeter');
  }

  Future<void> skipPattern() async {
    await _post('/skip_pattern');
  }

  Future<void> setSpeed(double speed) async {
    await _post('/set_speed', {'speed': speed});
  }

  // ── Playlists ─────────────────────────────────────────────────────────────

  Future<List<String>> listPlaylists() async {
    final d = await _get('/list_all_playlists') as List;
    return d.cast<String>();
  }

  Future<PlaylistDetail> getPlaylist(String name) async {
    final d = await _get('/get_playlist?name=${Uri.encodeComponent(name)}');
    return PlaylistDetail.fromJson(d);
  }

  Future<void> createPlaylist(String name, {List<String> files = const []}) async {
    await _post('/create_playlist', {'playlist_name': name, 'files': files});
  }

  Future<void> deletePlaylist(String name) async {
    await _delete('/delete_playlist', {'playlist_name': name});
  }

  Future<void> runPlaylist(String name, {bool shuffle = false, String runMode = 'loop'}) async {
    await _post('/run_playlist', {
      'playlist_name': name,
      'shuffle': shuffle,
      'run_mode': runMode,
    });
  }

  Future<void> addToPlaylist(String playlistName, String pattern) async {
    await _post('/add_to_playlist', {
      'playlist_name': playlistName,
      'pattern': pattern,
    });
  }

  // ── Auto-play ─────────────────────────────────────────────────────────────

  Future<AutoPlayMode> getAutoPlayMode() async {
    final d = await _get('/api/auto_play-mode');
    return AutoPlayMode.fromJson(d);
  }

  Future<void> setAutoPlayMode(AutoPlayMode mode) async {
    await _post('/api/auto_play-mode', mode.toJson());
  }

  // ── LED ───────────────────────────────────────────────────────────────────

  Future<LedStatus> getLedStatus() async {
    final d = await _get('/api/dw_leds/status');
    return LedStatus.fromJson(d);
  }

  Future<void> setLedPower(bool on) async {
    await _post('/api/dw_leds/power', {'on': on});
  }

  Future<void> setLedBrightness(int brightness) async {
    await _post('/api/dw_leds/brightness', {'brightness': brightness});
  }

  Future<void> setLedColor(int r, int g, int b) async {
    await _post('/api/dw_leds/color', {'r': r, 'g': g, 'b': b});
  }

  Future<List<String>> getLedEffects() async {
    final d = await _get('/api/dw_leds/effects') as List;
    return d.cast<String>();
  }

  Future<void> setLedEffect(String effect) async {
    await _post('/api/dw_leds/effect', {'effect': effect});
  }

  Future<void> setLedSpeed(int speed) async {
    await _post('/api/dw_leds/speed', {'speed': speed});
  }

  Future<void> setLedIntensity(int intensity) async {
    await _post('/api/dw_leds/intensity', {'intensity': intensity});
  }

  Future<void> setWledIp(String ip) async {
    await _post('/set_wled_ip', {'ip': ip});
  }

  Future<String?> getWledIp() async {
    final d = await _get('/get_wled_ip');
    return d['ip'] as String?;
  }

  // ── System ────────────────────────────────────────────────────────────────

  Future<void> restartSystem() async {
    await _post('/api/system/restart');
  }

  Future<void> shutdownSystem() async {
    await _post('/api/system/shutdown');
  }

  Future<UpdateResult> checkForUpdates() async {
    final d = await _post('/api/update') as Map<String, dynamic>;
    return UpdateResult.fromJson(d);
  }
}

class UpdateResult {
  final String status;
  final String message;
  final String? commit;
  final String? fromCommit;
  final String? toCommit;

  const UpdateResult({
    required this.status,
    required this.message,
    this.commit,
    this.fromCommit,
    this.toCommit,
  });

  bool get isUpToDate => status == 'up_to_date';
  bool get isUpdated => status == 'updated';
  bool get isError => status == 'error';

  factory UpdateResult.fromJson(Map<String, dynamic> j) => UpdateResult(
        status: j['status'] ?? 'error',
        message: j['message'] ?? 'Unknown error',
        commit: j['commit'],
        fromCommit: j['from_commit'],
        toCommit: j['to_commit'],
      );
}

class ApiException implements Exception {
  final int statusCode;
  final String body;
  ApiException(this.statusCode, this.body);

  @override
  String toString() => 'ApiException($statusCode): $body';
}

// ── Models ────────────────────────────────────────────────────────────────────

class TableInfo {
  final String id;
  final String name;
  final String version;

  const TableInfo({required this.id, required this.name, required this.version});

  factory TableInfo.fromJson(Map<String, dynamic> j) => TableInfo(
        id: j['id'] ?? '',
        name: j['name'] ?? 'Accelle Table',
        version: j['version'] ?? '',
      );
}

class SerialStatus {
  final bool connected;
  final String? port;

  const SerialStatus({required this.connected, this.port});

  factory SerialStatus.fromJson(Map<String, dynamic> j) => SerialStatus(
        connected: j['connected'] ?? false,
        port: j['port'],
      );
}

class WifiStatus {
  final String mode;
  final String? ssid;
  final String? ip;
  final String? hostname;

  const WifiStatus({required this.mode, this.ssid, this.ip, this.hostname});

  bool get isConnected => mode == 'client';

  factory WifiStatus.fromJson(Map<String, dynamic> j) => WifiStatus(
        mode: j['mode'] ?? 'unknown',
        ssid: j['ssid'],
        ip: j['ip'],
        hostname: j['hostname'],
      );
}

class SavedNetwork {
  final String name;
  final String ssid;

  const SavedNetwork({required this.name, required this.ssid});

  factory SavedNetwork.fromJson(Map<String, dynamic> j) =>
      SavedNetwork(name: j['name'] ?? j['ssid'] ?? '', ssid: j['ssid'] ?? '');
}

class ScannedNetwork {
  final String ssid;
  final int signal;
  final String security;
  final bool saved;
  final bool active;

  const ScannedNetwork({
    required this.ssid,
    required this.signal,
    required this.security,
    required this.saved,
    required this.active,
  });

  factory ScannedNetwork.fromJson(Map<String, dynamic> j) => ScannedNetwork(
        ssid: j['ssid'] ?? '',
        signal: (j['signal'] ?? 0) as int,
        security: j['security'] ?? '',
        saved: j['saved'] ?? false,
        active: j['active'] ?? false,
      );
}

class PatternHistory {
  final int playCount;
  final double? durationSeconds;
  final String? durationFormatted;
  final String? lastPlayed;

  const PatternHistory({
    required this.playCount,
    this.durationSeconds,
    this.durationFormatted,
    this.lastPlayed,
  });

  factory PatternHistory.fromJson(Map<String, dynamic> j) => PatternHistory(
        playCount: (j['play_count'] ?? 0) as int,
        durationSeconds: (j['actual_time_seconds'] as num?)?.toDouble(),
        durationFormatted: j['actual_time_formatted'],
        lastPlayed: j['last_played'],
      );
}

class PlaylistDetail {
  final String name;
  final List<String> files;

  const PlaylistDetail({required this.name, required this.files});

  factory PlaylistDetail.fromJson(Map<String, dynamic> j) => PlaylistDetail(
        name: j['name'] ?? '',
        files: (j['files'] as List?)?.cast<String>() ?? [],
      );
}

class AutoPlayMode {
  final bool enabled;
  final String? playlist;
  final String runMode;
  final double pauseTime;
  final bool shuffle;

  const AutoPlayMode({
    required this.enabled,
    this.playlist,
    this.runMode = 'loop',
    this.pauseTime = 5.0,
    this.shuffle = false,
  });

  factory AutoPlayMode.fromJson(Map<String, dynamic> j) => AutoPlayMode(
        enabled: j['enabled'] ?? false,
        playlist: j['playlist'],
        runMode: j['run_mode'] ?? 'loop',
        pauseTime: (j['pause_time'] as num?)?.toDouble() ?? 5.0,
        shuffle: j['shuffle'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'playlist': playlist,
        'run_mode': runMode,
        'pause_time': pauseTime,
        'shuffle': shuffle,
      };
}

class LedStatus {
  final bool connected;
  final String? message;
  final bool? power;
  final int? brightness;

  const LedStatus({
    required this.connected,
    this.message,
    this.power,
    this.brightness,
  });

  factory LedStatus.fromJson(Map<String, dynamic> j) => LedStatus(
        connected: j['connected'] ?? false,
        message: j['message'],
        power: j['power'],
        brightness: j['brightness'],
      );
}
