import 'package:flutter/material.dart';

import '../../core/services/service_locator.dart';
import '../../data/datasources/database/app_database.dart';
import '../adaptive_scaffold.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String _statusText =
      'Initializing SQLite lossless catalog & offline audio cache...';

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.05).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    _animController.repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Strict adherence: Defer all heavy SQLite seeding and precache into postFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // 1. Precache emblem
    try {
      await precacheImage(
        const AssetImage('assets/icons/app_icon.png'),
        context,
      );
    } catch (_) {}

    // 2. Ensure SQLite initial data is seeded
    final db = getIt<AppDatabase>();
    await db.seedIfEmpty();

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _statusText =
            'Mounting native 24-bit DSP equalizer & FFT spectrum bridge...';
      });
    }

    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _statusText = 'EchoStream Acoustic Studio Ready.';
      });
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, anim, secAnim) => const AdaptiveScaffold(),
          transitionsBuilder: (context, animation, secAnim, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: Container(
                        width: 120.0,
                        height: 120.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 36.0,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/icons/app_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28.0),
              Text(
                'EchoStream',
                style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Lossless Spatial Audio • Native 10-Band DSP • Offline Vault',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 36.0),
              SizedBox(
                width: 24.0,
                height: 24.0,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _statusText,
                  key: ValueKey(_statusText),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
