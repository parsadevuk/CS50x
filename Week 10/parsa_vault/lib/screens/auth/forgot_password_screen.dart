import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../utils/validators.dart';
import '../../widgets/buttons/gold_button.dart';
import '../../widgets/inputs/gold_input_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _isLoading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await ref
        .read(authProvider.notifier)
        .sendPasswordResetEmail(_emailCtrl.text.trim());

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (error != null) {
        _error = error;
      } else {
        _sent = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _sent ? _buildSentView() : _buildFormView(),
          ),
        ),
      ),
    );
  }

  // ── Form view ────────────────────────────────────────────────────────────────

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),

          // Back button
          GestureDetector(
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
          ),
          const SizedBox(height: 20),

          // Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.goldLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 40,
                color: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(height: 28),

          Center(
            child: Text('Forgot password?', style: AppTextStyles.screenTitle),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Enter your email and we\'ll send you a link to reset your password.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.mediumGrey),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 36),

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
            const SizedBox(height: 16),
          ],

          GoldInputField(
            label: 'Email address',
            hint: 'you@example.com',
            controller: _emailCtrl,
            validator: AppValidators.email,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onEditingComplete: _submit,
          ),
          const SizedBox(height: 28),

          GoldButton(
            label: 'Send reset link',
            onPressed: _submit,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 24),

          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              child: Text(
                'Back to Log In',
                style: AppTextStyles.label.copyWith(color: AppColors.gold),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Success view ─────────────────────────────────────────────────────────────

  Widget _buildSentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 80),

        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            color: AppColors.goldLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            size: 44,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'Check your inbox',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.nearBlack,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),

        Text(
          'We sent a password reset link to',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: AppColors.mediumGrey,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          _emailCtrl.text.trim(),
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.nearBlack,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Click the link in the email to create a new password. The link expires after 1 hour.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.mediumGrey,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.nearBlack,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            child: Text(
              'Back to Log In',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        GestureDetector(
          onTap: () => setState(() {
            _sent = false;
            _error = null;
          }),
          child: Text(
            'Didn\'t receive it? Try again',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.mediumGrey,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: MediaQuery.of(context).padding.bottom + 40),
      ],
    );
  }
}
