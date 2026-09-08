import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Plays the real splash video asset from Phase 4
/// (`assets/video/splash_animation.mp4`) full-bleed, then advances to
/// onboarding automatically when it finishes — mirroring exactly the
/// behavior wired into the HTML prototype's `.splash-vid` `ended` handler
/// (`design/prototype/thabat_prototype.html`), not a fresh design decision.
/// Tapping the screen skips ahead immediately, same as the prototype.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final VideoPlayerController _controller;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/splash_animation.mp4')
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });
    _controller.addListener(_onVideoProgress);
  }

  void _onVideoProgress() {
    final value = _controller.value;
    final isFinished = value.isInitialized &&
        !value.isPlaying &&
        value.position >= value.duration &&
        value.duration > Duration.zero;
    if (isFinished) {
      _goToOnboarding();
    }
  }

  void _goToOnboarding() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    context.go(AppRoutes.onboarding);
  }

  @override
  void dispose() {
    _controller.removeListener(_onVideoProgress);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: GestureDetector(
        onTap: _goToOnboarding,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_controller.value.isInitialized)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: AppColors.greenDeep)),
            // Bottom scrim + tagline — matches `.splash-scrim` / `.splash-foot`
            // in the prototype: keeps the tagline legible over the video.
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.greenDeep.withOpacity(0.55),
                      Colors.transparent,
                    ],
                  ),
                ),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 36),
                child: Text(
                  'المصدر أولاً... الذكاء مساعد فقط',
                  style: AppTypography.cairo(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cream2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
