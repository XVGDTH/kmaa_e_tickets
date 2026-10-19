import 'package:flutter/material.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/assets-constantes.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/color.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/app-string-constantes.dart';
import 'package:kmaa_e_tickets/mon-app/constantes/routes-menu.dart';
import 'package:kmaa_e_tickets/mon-app/profil-user/profil_user.dart';
import 'package:video_player/video_player.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final VideoPlayerController _videoController;
  late final AnimationController _chevronController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();

    _chevronController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _initVideo();
  }

  Future<void> _initVideo() async {
    _videoController = AppAssets.welcomeVideoUrl.isNotEmpty
        ? VideoPlayerController.networkUrl(Uri.parse(AppAssets.welcomeVideoUrl))
        : VideoPlayerController.asset(AppAssets.welcomeVideo);

    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.setVolume(0);
      await _videoController.play();
      if (mounted) setState(() => _videoReady = true);
    } catch (e) {
      debugPrint('Erreur de chargement de la vidéo : $e');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chevronController.dispose();
    super.dispose();
  }

  // void _onGetStarted() {
  //   Navigator.of(context).pushReplacementNamed(AppRoutes.signup);
  // }
  void _onGetStarted() {
    // Déjà inscrit sur cet appareil : on reprend par la connexion.
    final dejaInscrit =
        (UserStore.instance.profile.value?.telephone ?? '').isNotEmpty;
    Navigator.of(
      context,
    ).pushReplacementNamed(dejaInscrit ? '/login' : AppRoutes.signup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildVideoBackground(),
          _buildGradientOverlay(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  _buildTexts(),
                  const SizedBox(height: 32),
                  _buildGetStartedButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoBackground() {
    if (!_videoReady) return const ColoredBox(color: AppColors.black);
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: _videoController.value.size.width,
        height: _videoController.value.size.height,
        child: VideoPlayer(_videoController),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.overlayTop, AppColors.overlayBottom],
          stops: [0.3, 1.0],
        ),
      ),
    );
  }

  Widget _buildTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          AppStrings.welcomeTitle,
          style: TextStyle(
            color: AppColors.textOnDark,
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        SizedBox(height: 12),
        Text(
          AppStrings.welcomeSubtitle,
          style: TextStyle(
            color: AppColors.textOnDarkMuted,
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildGetStartedButton() {
    final radius = BorderRadius.circular(40);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: AppColors.buttonGradient,
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: radius,
          onTap: _onGetStarted,
          splashColor: AppColors.white.withOpacity(0.25),
          highlightColor: AppColors.white.withOpacity(0.10),
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                const SizedBox(width: 6),
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: AppColors
                        .secondary, // rouge : meilleur contraste sur blanc
                    size: 22,
                  ),
                ),
                const Spacer(),
                const Text(
                  AppStrings.getStarted,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                        color: Color(0x59000000),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _buildAnimatedChevrons(),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Trois chevrons ">" qui s'illuminent l'un après l'autre.
  Widget _buildAnimatedChevrons() {
    return AnimatedBuilder(
      animation: _chevronController,
      builder: (context, _) {
        return Row(
          children: List.generate(3, (i) {
            final phase = (_chevronController.value - i * 0.2) % 1.0;
            final opacity = (1 - (phase - 0.2).abs() * 2.5).clamp(0.25, 1.0);
            return Opacity(
              opacity: opacity,
              child: const Icon(
                Icons.chevron_right,
                color: AppColors.white,
                size: 18,
              ),
            );
          }),
        );
      },
    );
  }
}
