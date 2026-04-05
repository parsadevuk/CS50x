import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/formatters.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/gold_button.dart';
import '../../widgets/buttons/sso_buttons.dart';
import '../../widgets/common/level_badge.dart';
import '../../widgets/inputs/gold_input_field.dart';
import '../main/main_navigation.dart';
import 'email_verification_screen.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';
import 'sso_complete_profile_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

// ── Guest merge sheet ─────────────────────────────────────────────────────────

class _GuestMergeSheet extends StatelessWidget {
  final User guestUser;
  final User existingUser;

  const _GuestMergeSheet({
    required this.guestUser,
    required this.existingUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppColors.goldLight, shape: BoxShape.circle),
            child: const Icon(Icons.compare_arrows_rounded,
                size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),

          Text(
            'Two saves found',
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.nearBlack,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your guest session and this account both\nhave game data. Which do you want to keep?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.mediumGrey, height: 1.5),
          ),
          const SizedBox(height: 24),

          // Guest option
          _GuestDataOption(
            icon: Icons.person_rounded,
            iconColor: AppColors.gold,
            title: 'Keep guest progress',
            subtitle: 'Replaces the existing account\'s data.',
            user: guestUser,
            onTap: () => Navigator.of(context).pop(true),
          ),
          const SizedBox(height: 12),

          // Existing account option
          _GuestDataOption(
            icon: Icons.cloud_done_rounded,
            iconColor: const Color(0xFF1E88E5),
            title: 'Keep existing account',
            subtitle: 'Guest progress will be discarded.',
            user: existingUser,
            onTap: () => Navigator.of(context).pop(false),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _GuestDataOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final User user;
  final VoidCallback onTap;

  const _GuestDataOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final levelLabel = LevelBadge.labelForLevel(user.level);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.softWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.borderGrey),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.nearBlack)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.mediumGrey,
                          height: 1.3)),
                  const SizedBox(height: 6),
                  // Data stats row
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _DataChip(
                          label: 'XP',
                          value: '${user.xp}',
                          color: AppColors.gold),
                      _DataChip(
                          label: 'Level',
                          value: levelLabel,
                          color: iconColor),
                      _DataChip(
                          label: 'Cash',
                          value: AppFormatters.currency(user.cashBalance),
                          color: AppColors.successGreen),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.mediumGrey),
          ],
        ),
      ),
    );
  }
}

class _DataChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DataChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// ── Back button ───────────────────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderGrey, width: 1.5),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: AppColors.nearBlack,
        ),
      ),
    );
  }
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _loginCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _loginCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // If the user is currently a guest, intercept and show merge dialog
    final authState = ref.read(authProvider);
    if (authState.isGuest && authState.user != null) {
      await _guestLoginFlow(authState.user!);
      return;
    }

    final success = await ref.read(authProvider.notifier).login(
          emailOrUsername: _loginCtrl.text,
          password: _passCtrl.text,
        );
    if (success && mounted) _goHome();
  }

  /// Called when a guest submits the login form.
  /// Step 1: signs in to the existing account (guaranteed to work via Firebase Auth).
  /// Step 2: shows comparison sheet using data from BOTH accounts.
  /// Step 3: finalises — copies game data or discards guest data.
  Future<void> _guestLoginFlow(User guestUser) async {
    // Sign in first so we can read both accounts' Firestore data
    final result = await ref.read(authProvider.notifier).beginGuestLogin(
      emailOrUsername: _loginCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;
    if (result.preview == null) return; // error shown via authState.error banner

    final preview = result.preview!;

    // Now show comparison — user is already signed in so they must choose
    final keepGuest = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => _GuestMergeSheet(
        guestUser: preview.guestUser,
        existingUser: preview.existingUser,
      ),
    );

    if (!mounted) return;

    // keepGuest null shouldn't happen (sheet is non-dismissible) but default to false
    final error = await ref.read(authProvider.notifier).finalizeMerge(
      guestUid: preview.guestUid,
      keepGuestData: keepGuest ?? false,
    );

    if (!mounted) return;
    if (error != null) return;
    _goHome();
  }

  Future<void> _ssoSignIn(Future<bool> Function() ssoCall) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final success = await ssoCall();
    if (!success || !mounted) return;

    final authState = ref.read(authProvider);

    // Guest signed into an existing SSO account — show merge dialog
    if (authState.pendingGuestMerge != null) {
      final preview = authState.pendingGuestMerge!;
      final keepGuest = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        enableDrag: false,
        builder: (_) => _GuestMergeSheet(
          guestUser: preview.guestUser,
          existingUser: preview.existingUser,
        ),
      );
      if (!mounted) return;
      await ref.read(authProvider.notifier).finalizeMerge(
        guestUid: preview.guestUid,
        keepGuestData: keepGuest ?? false,
      );
      if (!mounted) return;
      _goHome();
      return;
    }

    // Normal SSO flow
    if (authState.isNewSsoUser) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
            builder: (_) => const SsoCompleteProfileScreen()),
        (_) => false,
      );
    } else {
      _goHome();
    }
  }

  void _goHome() {
    final authState = ref.read(authProvider);
    final needsVerification =
        !authState.emailVerified && !authState.isSsoUser;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => needsVerification
            ? const EmailVerificationScreen()
            : const MainNavigation(),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Back button
                  _BackButton(),
                  const SizedBox(height: 20),

                  // Logo
                  Center(
                    child: Image.asset(
                      'assets/images/logo_transparent_full.png',
                      width: 72,
                      height: 72,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child:
                        Text('Welcome Back', style: AppTextStyles.screenTitle),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Log in to your vault.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.mediumGrey),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Error banner
                  if (authState.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.dangerRed.withValues(alpha: 0.3)),
                      ),
                      child: Text(authState.error!,
                          style: AppTextStyles.errorText),
                    ),
                    const SizedBox(height: 16),
                  ],

                  GoldInputField(
                    label: 'Email or Username',
                    hint: 'you@example.com',
                    controller: _loginCtrl,
                    validator: AppValidators.loginField,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  GoldInputField(
                    label: 'Password',
                    hint: 'Your password',
                    controller: _passCtrl,
                    validator: AppValidators.password,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _submit,
                  ),
                  const SizedBox(height: 12),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      ),
                      child: Text(
                        'Forgot password?',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.gold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  GoldButton(
                    label: 'Log In',
                    onPressed: _submit,
                    isLoading: authState.isLoading,
                  ),
                  const SizedBox(height: 16),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pushReplacement(
                        PageRouteBuilder(
                          pageBuilder: (_, __, ___) => const RegisterScreen(),
                          transitionsBuilder: (_, anim, __, child) =>
                              FadeTransition(opacity: anim, child: child),
                          transitionDuration: const Duration(milliseconds: 250),
                        ),
                      ),
                      child: RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.mediumGrey),
                          children: [
                            const TextSpan(text: "Don't have an account? "),
                            TextSpan(
                              text: 'Register',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.gold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // SSO divider + buttons
                  const SsoDivider(),
                  SsoIconRow(
                    onApple: () => _ssoSignIn(
                        () => ref.read(authProvider.notifier).signInWithApple()),
                    onGoogle: () => _ssoSignIn(
                        () => ref.read(authProvider.notifier).signInWithGoogle()),
                    onMicrosoft: () => _ssoSignIn(
                        () => ref.read(authProvider.notifier).signInWithMicrosoft()),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
