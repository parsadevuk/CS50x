import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../utils/password_helper.dart';
import '../../widgets/buttons/gold_button.dart';
import '../../widgets/inputs/gold_input_field.dart';
import '../main/main_navigation.dart';
import 'email_verification_screen.dart';

class GuestUpgradeScreen extends ConsumerStatefulWidget {
  const GuestUpgradeScreen({super.key});

  @override
  ConsumerState<GuestUpgradeScreen> createState() => _GuestUpgradeScreenState();
}

class _GuestUpgradeScreenState extends ConsumerState<GuestUpgradeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  PasswordStrength _strength = PasswordStrength.weak;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final error = await ref.read(authProvider.notifier).linkGuestWithEmail(
          fullName: _nameCtrl.text,
          username: _usernameCtrl.text,
          email: _emailCtrl.text,
          password: _passCtrl.text,
        );

    if (!mounted) return;

    if (error == 'CONFLICT') {
      _showConflictDialog();
      return;
    }

    if (error != null) {
      setState(() => _error = error);
      return;
    }

    // Go to email verification — progress is already saved
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
      (_) => false,
    );
  }

  Future<void> _showConflictDialog() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConflictSheet(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        onResolved: (keepGuest) => _onConflictResolved(keepGuest),
      ),
    );
  }

  Future<void> _onConflictResolved(bool keepGuest) async {
    Navigator.of(context).pop(); // close sheet

    final error = await ref
        .read(authProvider.notifier)
        .mergeGuestAndSignInToExisting(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
          keepGuestData: keepGuest,
        );

    if (!mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    // Existing account: check if verified
    final authState = ref.read(authProvider);
    if (!authState.emailVerified) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const EmailVerificationScreen()),
        (_) => false,
      );
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigation()),
        (_) => false,
      );
    }
  }

  Color get _strengthColor {
    switch (_strength) {
      case PasswordStrength.weak:
        return AppColors.dangerRed;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.amber;
      case PasswordStrength.strong:
        return AppColors.successGreen;
    }
  }

  String get _strengthLabel {
    switch (_strength) {
      case PasswordStrength.weak:
        return 'Weak';
      case PasswordStrength.fair:
        return 'Fair';
      case PasswordStrength.good:
        return 'Good';
      case PasswordStrength.strong:
        return 'Strong';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authProvider).isLoading;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),

                  // Back
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.borderGrey, width: 1.5),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: AppColors.nearBlack),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Icon + title
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: AppColors.goldLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.save_rounded,
                          size: 40, color: AppColors.gold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: Text('Save your progress',
                        style: AppTextStyles.screenTitle),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Create a free account to keep your portfolio,\nXP, and trade history forever.',
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.mediumGrey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Progress preserved notice
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.successGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color:
                              AppColors.successGreen.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            size: 18, color: AppColors.successGreen),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Your current portfolio & XP will be kept.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.successGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Error banner
                  if (_error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.dangerRed.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.dangerRed.withValues(alpha: 0.3)),
                      ),
                      child: Text(_error!, style: AppTextStyles.errorText),
                    ),
                    const SizedBox(height: 12),
                  ],

                  GoldInputField(
                    label: 'Full Name',
                    hint: 'Your name',
                    controller: _nameCtrl,
                    validator: AppValidators.fullName,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),

                  GoldInputField(
                    label: 'Username',
                    hint: 'e.g. traderpro',
                    controller: _usernameCtrl,
                    validator: AppValidators.username,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),

                  GoldInputField(
                    label: 'Email',
                    hint: 'you@example.com',
                    controller: _emailCtrl,
                    validator: AppValidators.email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 14),

                  GoldInputField(
                    label: 'Password',
                    hint: 'Min 8 characters',
                    controller: _passCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: AppValidators.password,
                    onChanged: (v) => setState(
                        () => _strength = PasswordHelper.strength(v)),
                  ),

                  // Strength indicator
                  if (_passCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: _strength == PasswordStrength.weak
                                  ? 0.25
                                  : _strength == PasswordStrength.fair
                                      ? 0.5
                                      : _strength == PasswordStrength.good
                                          ? 0.75
                                          : 1.0,
                              minHeight: 4,
                              backgroundColor: AppColors.borderGrey,
                              valueColor: AlwaysStoppedAnimation(_strengthColor),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(_strengthLabel,
                            style: AppTextStyles.caption
                                .copyWith(color: _strengthColor)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),

                  GoldInputField(
                    label: 'Confirm Password',
                    hint: 'Repeat password',
                    controller: _confirmCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _submit,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please confirm your password.';
                      if (v != _passCtrl.text) return 'Passwords do not match.';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  GoldButton(
                    label: 'Create Account & Save Progress',
                    onPressed: _submit,
                    isLoading: isLoading,
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

// ── Conflict resolution bottom sheet ─────────────────────────────────────────

class _ConflictSheet extends StatelessWidget {
  final String email;
  final String password;
  final void Function(bool keepGuest) onResolved;

  const _ConflictSheet({
    required this.email,
    required this.password,
    required this.onResolved,
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
          // Handle bar
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.borderGrey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Icon
          Container(
            width: 64, height: 64,
            decoration: const BoxDecoration(
              color: AppColors.goldLight, shape: BoxShape.circle),
            child: const Icon(Icons.compare_arrows_rounded,
                size: 32, color: AppColors.gold),
          ),
          const SizedBox(height: 16),

          Text('Account already exists',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.nearBlack,
              )),
          const SizedBox(height: 10),

          Text(
            'An account with $email already exists.\nWhich data do you want to keep?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
                fontSize: 14, color: AppColors.mediumGrey, height: 1.5),
          ),
          const SizedBox(height: 28),

          // Keep guest progress
          _ConflictOption(
            icon: Icons.person_rounded,
            iconColor: AppColors.gold,
            title: 'Keep guest progress',
            subtitle: 'Your current portfolio, XP and trades replace the existing account\'s data.',
            onTap: () => onResolved(true),
          ),
          const SizedBox(height: 12),

          // Keep existing account
          _ConflictOption(
            icon: Icons.cloud_done_rounded,
            iconColor: const Color(0xFF1E88E5),
            title: 'Keep existing account data',
            subtitle: 'Log in to your old account. Guest progress will be discarded.',
            onTap: () => onResolved(false),
          ),
          const SizedBox(height: 16),

          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: GoogleFonts.inter(
                    fontSize: 14, color: AppColors.mediumGrey)),
          ),
        ],
      ),
    );
  }
}

class _ConflictOption extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ConflictOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              width: 44, height: 44,
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
                          height: 1.4)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 20, color: AppColors.mediumGrey),
          ],
        ),
      ),
    );
  }
}
