import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../auth/welcome_screen.dart';
import '../main/main_navigation.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  Timer? _pollTimer;
  bool _resendCooldown = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    // Poll Firebase every 4 seconds to auto-detect when user verifies
    _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    await ref.read(authProvider.notifier).refreshEmailVerified();
    final verified = ref.read(authProvider).emailVerified;
    if (verified && mounted) {
      _pollTimer?.cancel();
      _navigateToApp();
    }
  }

  Future<void> _checkNow() async {
    setState(() => _checking = true);
    await ref.read(authProvider.notifier).refreshEmailVerified();
    setState(() => _checking = false);

    final verified = ref.read(authProvider).emailVerified;
    if (verified && mounted) {
      _navigateToApp();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Email not verified yet. Please check your inbox and click the link.',
            style: GoogleFonts.inter(fontSize: 13),
          ),
          backgroundColor: AppColors.nearBlack,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _resend() async {
    if (_resendCooldown) return;
    await ref.read(authProvider.notifier).sendVerificationEmail();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Verification email sent!',
          style: GoogleFonts.inter(fontSize: 13),
        ),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );

    // 30-second cooldown to prevent spam
    setState(() {
      _resendCooldown = true;
      _cooldownSeconds = 30;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _cooldownSeconds--);
      if (_cooldownSeconds <= 0) {
        t.cancel();
        setState(() => _resendCooldown = false);
      }
    });
  }

  Future<void> _logout() async {
    _pollTimer?.cancel();
    await ref.read(authProvider.notifier).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  void _navigateToApp() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigation(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = ref.watch(authProvider).user?.email ?? '';

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 60),

              // Icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 44,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'Verify your email',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.nearBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),

              // Body
              Text(
                'We sent a verification link to',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.mediumGrey,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                email,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.nearBlack,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Open the link in the email to activate your account. Then tap the button below.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.mediumGrey,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // I've verified button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _checking ? null : _checkNow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    disabledBackgroundColor: AppColors.borderGrey,
                    foregroundColor: AppColors.nearBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: _checking
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.gold,
                          ),
                        )
                      : Text(
                          'I\'ve verified my email',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 14),

              // Resend button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _resendCooldown ? null : _resend,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gold,
                    disabledForegroundColor: AppColors.mediumGrey,
                    side: BorderSide(
                      color: _resendCooldown
                          ? AppColors.borderGrey
                          : AppColors.gold,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    _resendCooldown
                        ? 'Resend in ${_cooldownSeconds}s'
                        : 'Resend verification email',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Log out link
              GestureDetector(
                onTap: _logout,
                child: Text(
                  'Use a different account',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.mediumGrey,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).padding.bottom + 24),
            ],
          ),
        ),
      ),
    );
  }
}
