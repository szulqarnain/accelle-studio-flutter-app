import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class ProvisioningScreen extends StatefulWidget {
  const ProvisioningScreen({super.key});

  @override
  State<ProvisioningScreen> createState() => _ProvisioningScreenState();
}

class _ProvisioningScreenState extends State<ProvisioningScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  bool _passwordVisible = false;

  final _ssidController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final _pulseCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);

  late final _spinCtrl = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _spinCtrl.dispose();
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 3) {
      if (!_formKey.currentState!.validate()) return;
      _startConnecting();
      return;
    }
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      context.go('/connectivity');
    } else {
      setState(() => _step--);
    }
  }

  Future<void> _startConnecting() async {
    setState(() => _step = 4);
    await Future.delayed(const Duration(seconds: 6));
    if (mounted) setState(() => _step = 5);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF080808),
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              _buildStepIndicator(),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  transitionBuilder: (child, anim) => SlideTransition(
                    position: Tween(
                      begin: const Offset(0.08, 0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: anim,
                      curve: Curves.easeOutCubic,
                    )),
                    child: FadeTransition(opacity: anim, child: child),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(),
                  ),
                ),
              ),
              if (_step < 4) _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          if (_step < 5)
            GestureDetector(
              onTap: _back,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF888888),
                  size: 16,
                ),
              ),
            )
          else
            const SizedBox(width: 36),
          const Spacer(),
          const Text(
            'Device Setup',
            style: TextStyle(
              color: Color(0xFFD4A256),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    if (_step >= 5) return const SizedBox(height: 8);
    const total = 4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      child: Row(
        children: List.generate(total, (i) {
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: done
                    ? const Color(0xFFD4A256)
                    : active
                        ? const Color(0xFFD4A256).withValues(alpha: 0.5)
                        : const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _StepWelcome(pulseCtrl: _pulseCtrl);
      case 1:
        return _StepPowerOn(pulseCtrl: _pulseCtrl);
      case 2:
        return _StepHotspot(pulseCtrl: _pulseCtrl);
      case 3:
        return _StepWifiForm(
          formKey: _formKey,
          ssidController: _ssidController,
          passwordController: _passwordController,
          passwordVisible: _passwordVisible,
          onTogglePassword: () =>
              setState(() => _passwordVisible = !_passwordVisible),
        );
      case 4:
        return _StepConnecting(
          spinCtrl: _spinCtrl,
          ssid: _ssidController.text,
        );
      case 5:
        return _StepSuccess(onDone: () => context.go('/dashboard'));
      default:
        return const SizedBox();
    }
  }

  Widget _buildBottomBar() {
    final labels = ['Get Started', 'Next', 'I\'m Connected', 'Connect Table'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _next,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD4A256),
            foregroundColor: const Color(0xFF080808),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 0,
          ),
          child: Text(
            labels[_step.clamp(0, 3)],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step 0: Welcome ────────────────────────────────────────────────────────

class _StepWelcome extends StatelessWidget {
  const _StepWelcome({required this.pulseCtrl});
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, child) {
              final glow = 0.3 + 0.2 * pulseCtrl.value;
              return Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4A256).withValues(alpha: glow),
                      blurRadius: 60,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: CustomPaint(painter: _TableLogoPainter()),
              );
            },
          ).animate().fadeIn(duration: 600.ms).scale(
                begin: const Offset(0.8, 0.8),
                duration: 700.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: 40),
          const Text(
            "Let's set up\nyour table",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFF5F1EA),
              fontSize: 30,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(
                begin: 0.15,
                curve: Curves.easeOut,
              ),
          const SizedBox(height: 16),
          const Text(
            'This takes about 2 minutes. You\'ll connect your\nAccelle table to your Wi-Fi network.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7A7570),
              fontSize: 15,
              height: 1.6,
            ),
          ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── Step 1: Power On ───────────────────────────────────────────────────────

class _StepPowerOn extends StatelessWidget {
  const _StepPowerOn({required this.pulseCtrl});
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, child) {
              final pulse = 0.4 + 0.6 * pulseCtrl.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 120 + 20 * pulse,
                    height: 120 + 20 * pulse,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF4CAF50)
                          .withValues(alpha: 0.06 * pulse),
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF1A1A1A),
                      border: Border.all(
                        color: Color.lerp(
                          const Color(0xFF2A2A2A),
                          const Color(0xFF4CAF50),
                          pulse,
                        )!,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50)
                              .withValues(alpha: 0.15 * pulse),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.power_settings_new_rounded,
                      color: Color.lerp(
                        const Color(0xFF3A3A3A),
                        const Color(0xFF4CAF50),
                        pulse,
                      ),
                      size: 40,
                    ),
                  ),
                ],
              );
            },
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 44),
          const Text(
            'Power on your table',
            style: TextStyle(
              color: Color(0xFFF5F1EA),
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.wb_sunny_rounded,
            iconColor: const Color(0xFFD4A256),
            text:
                'Plug in the power cable. The LED on the table will glow amber while it starts up.',
          ).animate(delay: 250.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 12),
          _InfoCard(
            icon: Icons.wifi_tethering_rounded,
            iconColor: const Color(0xFF5B9BD5),
            text:
                'After about 30 seconds, the table creates a Wi-Fi hotspot called "Accelle-Setup".',
          ).animate(delay: 350.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── Step 2: Connect to Hotspot ─────────────────────────────────────────────

class _StepHotspot extends StatelessWidget {
  const _StepHotspot({required this.pulseCtrl});
  final AnimationController pulseCtrl;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, child) {
              return CustomPaint(
                size: const Size(100, 100),
                painter: _WifiSignalPainter(strength: pulseCtrl.value),
              );
            },
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 36),
          const Text(
            'Connect to table hotspot',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFF5F1EA),
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A2A2A)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B9BD5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.wifi_rounded,
                    color: Color(0xFF5B9BD5),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accelle-Setup',
                      style: TextStyle(
                        color: Color(0xFFF5F1EA),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Table setup network',
                      style: TextStyle(
                        color: Color(0xFF5A5550),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const Icon(
                  Icons.lock_open_rounded,
                  color: Color(0xFF4CAF50),
                  size: 18,
                ),
              ],
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 16),
          _InfoCard(
            icon: Icons.settings_rounded,
            iconColor: const Color(0xFF7A7570),
            text:
                'Go to iOS Settings → Wi-Fi → select "Accelle-Setup", then come back here.',
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── Step 3: Wi-Fi Form ─────────────────────────────────────────────────────

class _StepWifiForm extends StatelessWidget {
  const _StepWifiForm({
    required this.formKey,
    required this.ssidController,
    required this.passwordController,
    required this.passwordVisible,
    required this.onTogglePassword,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController ssidController;
  final TextEditingController passwordController;
  final bool passwordVisible;
  final VoidCallback onTogglePassword;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Enter your Wi-Fi',
              style: TextStyle(
                color: Color(0xFFF5F1EA),
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            const Text(
              'Your table will connect to this network permanently.',
              style: TextStyle(
                color: Color(0xFF7A7570),
                fontSize: 14,
                height: 1.5,
              ),
            ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 32),
            _fieldLabel('Network name (SSID)'),
            const SizedBox(height: 8),
            TextFormField(
              controller: ssidController,
              style: const TextStyle(color: Color(0xFFF5F1EA)),
              decoration: _inputDecoration(
                hint: 'e.g. Home Wi-Fi',
                icon: Icons.wifi_rounded,
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Enter network name' : null,
            ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 20),
            _fieldLabel('Password'),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              obscureText: !passwordVisible,
              style: const TextStyle(color: Color(0xFFF5F1EA)),
              decoration: _inputDecoration(
                hint: 'Wi-Fi password',
                icon: Icons.lock_outline_rounded,
                suffix: IconButton(
                  onPressed: onTogglePassword,
                  icon: Icon(
                    passwordVisible
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: const Color(0xFF5A5550),
                    size: 20,
                  ),
                ),
              ),
              validator: (v) =>
                  v == null || v.length < 8 ? 'Minimum 8 characters' : null,
            ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A256).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFFD4A256).withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFFD4A256), size: 16),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Credentials are sent directly to your table over the local setup network.',
                      style: TextStyle(
                        color: Color(0xFFD4A256),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: Color(0xFF9A9590),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) =>
      InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF3A3530)),
        prefixIcon: Icon(icon, color: const Color(0xFF5A5550), size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF141414),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4A256), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE05252)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE05252)),
        ),
        errorStyle: const TextStyle(color: Color(0xFFE05252)),
      );
}

// ─── Step 4: Connecting ─────────────────────────────────────────────────────

class _StepConnecting extends StatefulWidget {
  const _StepConnecting({required this.spinCtrl, required this.ssid});
  final AnimationController spinCtrl;
  final String ssid;

  @override
  State<_StepConnecting> createState() => _StepConnectingState();
}

class _StepConnectingState extends State<_StepConnecting> {
  int _phase = 0;

  @override
  void initState() {
    super.initState();
    _runPhases();
  }

  Future<void> _runPhases() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _phase = 1);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _phase = 2);
  }

  @override
  Widget build(BuildContext context) {
    final phases = [
      'Sending credentials to table…',
      'Table connecting to ${widget.ssid.isEmpty ? 'Wi-Fi' : widget.ssid}…',
      'Discovering table on network…',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: widget.spinCtrl,
            builder: (_, child) => Transform.rotate(
              angle: widget.spinCtrl.value * 2 * pi,
              child: CustomPaint(
                size: const Size(100, 100),
                painter: _SpinnerPainter(),
              ),
            ),
          ),
          const SizedBox(height: 44),
          const Text(
            'Setting up your table',
            style: TextStyle(
              color: Color(0xFFF5F1EA),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 28),
          ...List.generate(phases.length, (i) {
            final done = i < _phase;
            final active = i == _phase;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: AnimatedOpacity(
                opacity: i <= _phase ? 1.0 : 0.3,
                duration: const Duration(milliseconds: 400),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: done
                          ? const Icon(Icons.check_circle_rounded,
                              color: Color(0xFF4CAF50), size: 20)
                          : active
                              ? _MiniSpinner()
                              : const Icon(Icons.radio_button_unchecked,
                                  color: Color(0xFF2A2A2A), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      phases[i],
                      style: TextStyle(
                        color: done
                            ? const Color(0xFF4CAF50)
                            : active
                                ? const Color(0xFFF5F1EA)
                                : const Color(0xFF3A3A3A),
                        fontSize: 14,
                        fontWeight: active
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

// ─── Step 5: Success ────────────────────────────────────────────────────────

class _StepSuccess extends StatelessWidget {
  const _StepSuccess({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
              border: Border.all(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF4CAF50),
              size: 52,
            ),
          )
              .animate()
              .scale(
                begin: const Offset(0.6, 0.6),
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(duration: 400.ms),
          const SizedBox(height: 36),
          const Text(
            'Table is ready!',
            style: TextStyle(
              color: Color(0xFFF5F1EA),
              fontSize: 30,
              fontWeight: FontWeight.w700,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 12),
          const Text(
            'Your Accelle table is connected to your\nnetwork and ready to create.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7A7570),
              fontSize: 15,
              height: 1.6,
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4A256),
                foregroundColor: const Color(0xFF080808),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                'Start Creating',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(
                begin: 0.2,
                curve: Curves.easeOut,
              ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.text,
  });
  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF9A9590),
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniSpinner extends StatefulWidget {
  @override
  State<_MiniSpinner> createState() => _MiniSpinnerState();
}

class _MiniSpinnerState extends State<_MiniSpinner>
    with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Transform.rotate(
        angle: _ctrl.value * 2 * pi,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFFD4A256),
          ),
        ),
      ),
    );
  }
}

// ─── Custom Painters ────────────────────────────────────────────────────────

class _TableLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = size.width / 2 - 2;
    final stroke = Paint()
      ..color = const Color(0xFFD4A256)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final dim = Paint()
      ..color = const Color(0xFFD4A256).withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final fill = Paint()
      ..color = const Color(0xFFD4A256)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxR, stroke);
    canvas.drawCircle(center, maxR * 0.68, stroke);
    canvas.drawCircle(center, maxR * 0.38, dim);
    for (int i = 0; i < 8; i++) {
      final a = (i / 8) * 2 * pi - pi / 2;
      canvas.drawLine(
        Offset(center.dx + cos(a) * maxR * 0.38,
            center.dy + sin(a) * maxR * 0.38),
        Offset(center.dx + cos(a) * maxR * 0.68,
            center.dy + sin(a) * maxR * 0.68),
        stroke,
      );
    }
    canvas.drawCircle(center, 4.5, fill);
    canvas.drawCircle(center, 8, dim);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _WifiSignalPainter extends CustomPainter {
  const _WifiSignalPainter({required this.strength});
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.7);
    for (int i = 0; i < 4; i++) {
      final r = 14.0 + i * 18.0;
      final active = i / 3 <= strength;
      final paint = Paint()
        ..color = active
            ? const Color(0xFF5B9BD5).withValues(alpha: 0.6 + 0.4 * strength)
            : const Color(0xFF2A2A2A)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        -pi * 0.85,
        pi * 0.7,
        false,
        paint,
      );
    }
    canvas.drawCircle(
      center,
      5,
      Paint()..color = const Color(0xFF5B9BD5),
    );
  }

  @override
  bool shouldRepaint(_WifiSignalPainter old) => old.strength != strength;
}

class _SpinnerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 4;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      0,
      pi * 1.5,
      false,
      Paint()
        ..color = const Color(0xFFD4A256)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r),
      pi * 1.5,
      pi * 0.5,
      false,
      Paint()
        ..color = const Color(0xFFD4A256).withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}
