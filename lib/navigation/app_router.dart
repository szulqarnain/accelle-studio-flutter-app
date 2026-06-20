import 'package:go_router/go_router.dart';
import '../features/connectivity/connectivity_screen.dart';
import '../features/home/home_screen.dart';
import '../features/led/led_screen.dart';
import '../features/patterns/patterns_screen.dart';
import '../features/playlists/playlists_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/motor_screen.dart';
import '../features/settings/wifi_screen.dart';
import '../features/settings/mqtt_screen.dart';
import '../features/settings/homing_screen.dart';
import '../features/settings/speed_screen.dart';
import '../features/settings/schedule_screen.dart';
import '../features/settings/developer_screen.dart';
import '../features/provisioning/provisioning_screen.dart';
import '../features/splash/splash_screen.dart';
import 'app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (_, s) => const NoTransitionPage(child: SplashScreen()),
    ),
    GoRoute(
      path: '/connectivity',
      builder: (_, s) => const ConnectivityScreen(),
    ),
    GoRoute(
      path: '/setup',
      builder: (_, s) => const ProvisioningScreen(),
    ),
    GoRoute(path: '/settings/motor', builder: (_, s) => const MotorScreen()),
    GoRoute(path: '/settings/wifi', builder: (_, s) => const WifiScreen()),
    GoRoute(path: '/settings/mqtt', builder: (_, s) => const MqttScreen()),
    GoRoute(path: '/settings/homing', builder: (_, s) => const HomingScreen()),
    GoRoute(path: '/settings/speed', builder: (_, s) => const SpeedScreen()),
    GoRoute(path: '/settings/schedule', builder: (_, s) => const ScheduleScreen()),
    GoRoute(path: '/settings/developer', builder: (_, s) => const DeveloperScreen()),
    StatefulShellRoute.indexedStack(
      pageBuilder: (_, s, shell) => NoTransitionPage(
        child: AppShell(navigationShell: shell),
      ),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/dashboard', builder: (_, s) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/patterns', builder: (_, s) => const PatternsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/playlists', builder: (_, s) => const PlaylistsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/led', builder: (_, s) => const LedScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/settings', builder: (_, s) => const SettingsScreen()),
        ]),
      ],
    ),
  ],
);
