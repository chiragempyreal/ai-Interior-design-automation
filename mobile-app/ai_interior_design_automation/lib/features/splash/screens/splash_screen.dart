import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/brand_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToDashboard();
  }

  Future<void> _navigateToDashboard() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

      if (isLoggedIn) {
        context.go('/dashboard');
      } else {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BrandColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              BrandColors.background,
              BrandColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo Container
              Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: BrandColors.primary,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: BrandColors.primary.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.architecture,
                      size: 60,
                      color: Colors.white,
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.elasticOut)
                  .fadeIn(duration: 600.ms),

              const SizedBox(height: 40),

              // Brand Name
              Text(
                    BrandConstants.brandName,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: BrandColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  )
                  .animate(delay: 400.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 12),

              // Tagline
              Text(
                    BrandConstants.tagline,
                    style: TextStyle(
                      fontSize: 16,
                      color: BrandColors.textBody,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate(delay: 800.ms)
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 60),

              // Loading Indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    BrandColors.primary,
                  ),
                ),
              ).animate(delay: 1200.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
