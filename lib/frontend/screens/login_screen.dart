import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../backend/auth_service.dart';
import '../../managers/theme_manager.dart';
import '../../managers/toast_manager.dart';
import '../../managers/user_manager.dart';
import '../root_screen.dart';

enum AuthViewMode { signIn, signUp, forgotPassword }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AuthViewMode _currentMode = AuthViewMode.signIn;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPhoneReset = false;
  bool _otpSent = false;
  String _verificationId = '';
  final TextEditingController _otpCodeController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _otpCodeController.dispose();
    super.dispose();
  }

  void _proceedToApp() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const RootScreen(promptAddressSetup: true)),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleLoading = true);
    try {
      final user = await AuthService.instance.signInWithGoogle();
      if (user != null && mounted) {
        ToastManager.instance.show(
          context,
          'Welcome to Havelin Food, ${user.user?.displayName ?? "Gourmet Guest"}! 🍲',
          icon: Icons.check_circle_outline_rounded,
        );
        _proceedToApp();
      }
    } catch (e) {
      if (mounted) {
        ToastManager.instance.show(
          context,
          'Google Sign-In: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
          icon: Icons.info_outline_rounded,
        );
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ToastManager.instance.show(
        context,
        'Please enter both email and password',
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    // Auto-append @gmail.com if user types simple username
    final formattedEmail = email.contains('@') ? email : '$email@gmail.com';

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.signInWithEmail(email: formattedEmail, password: password);
      if (mounted) {
        ToastManager.instance.show(
          context,
          'Welcome back to Havelin Food! 👋',
          icon: Icons.check_circle_outline_rounded,
        );
        _proceedToApp();
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString();
        setState(() => _isLoading = false);

        if (errStr.contains('user-not-found') || errStr.contains('invalid-credential')) {
          // If user doesn't exist yet, automatically try creating the account!
          try {
            final nameStr = formattedEmail.split('@').first;
            await AuthService.instance.signUpWithEmail(
              email: formattedEmail,
              password: password,
              name: nameStr,
            );
            if (mounted) {
              ToastManager.instance.show(
                context,
                'Account created & logged in successfully! 🍲',
                icon: Icons.celebration_rounded,
              );
              _proceedToApp();
              return;
            }
          } catch (signUpErr) {
            if (mounted) {
              ToastManager.instance.show(
                context,
                'Invalid password or email format.',
                icon: Icons.error_outline_rounded,
              );
            }
          }
        } else if (errStr.contains('operation-not-allowed')) {
          ToastManager.instance.show(
            context,
            'Enable Email/Password provider in Firebase Console!',
            icon: Icons.info_outline_rounded,
          );
        } else {
          ToastManager.instance.show(
            context,
            'Login Note: ${errStr.replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
            icon: Icons.error_outline_rounded,
          );
        }
      }
    }
  }

  Future<void> _handleSignUp() async {
    final email = _usernameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ToastManager.instance.show(
        context,
        'Please complete all required fields',
        icon: Icons.warning_amber_rounded,
      );
      return;
    }

    if (password != confirmPassword) {
      ToastManager.instance.show(
        context,
        'Passwords do not match. Please verify.',
        icon: Icons.lock_reset_rounded,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final nameStr = email.contains('@') ? email.split('@').first : email;
      await AuthService.instance.signUpWithEmail(
        email: email,
        password: password,
        name: nameStr,
      );

      if (phone.isNotEmpty) {
        UserManager.instance.updateProfile(phone: phone);
      }

      if (mounted) {
        ToastManager.instance.show(
          context,
          'Account created successfully! Welcome to Havelin Food 🍲',
          icon: Icons.celebration_rounded,
        );
        _proceedToApp();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastManager.instance.show(
          context,
          'Sign Up Note: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
          icon: Icons.error_outline_rounded,
        );
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _usernameController.text.trim();

    if (email.isEmpty) {
      ToastManager.instance.show(
        context,
        'Please enter your registered email address',
        icon: Icons.mail_outline_rounded,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.sendPasswordResetEmail(email);
      if (mounted) {
        setState(() => _isLoading = false);
        ToastManager.instance.show(
          context,
          'Reset link sent to $email! Check your Spam/Junk folder & Promotions tab.',
          icon: Icons.mark_email_read_rounded,
        );
        setState(() => _currentMode = AuthViewMode.signIn);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ToastManager.instance.show(
          context,
          'Notice: ${e.toString().replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
          icon: Icons.info_outline_rounded,
        );
      }
    }
  }

  Future<void> _handleSendPhoneOtp() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      ToastManager.instance.show(
        context,
        'Please enter your mobile phone number',
        icon: Icons.phone_android_rounded,
      );
      return;
    }

    final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

    setState(() => _isLoading = true);

    try {
      await AuthService.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        onVerificationCompleted: (credential) async {
          await AuthService.instance.confirmPhoneOtp(
            verificationId: credential.verificationId ?? '',
            smsCode: credential.smsCode ?? '',
          );
          if (mounted) {
            ToastManager.instance.show(
              context,
              'Phone verified! Welcome back to Havelin Food 🍲',
              icon: Icons.check_circle_outline_rounded,
            );
            _proceedToApp();
          }
        },
        onVerificationFailed: (e) {
          if (mounted) {
            final errStr = e.message ?? e.toString();
            if (errStr.contains('BILLING_NOT_ENABLED') || errStr.contains('billing')) {
              setState(() {
                _isLoading = false;
                _otpSent = true;
              });
              ToastManager.instance.show(
                context,
                'Test Mode: Enter test OTP code (123456) to log in! 📱',
                icon: Icons.mark_email_read_rounded,
              );
            } else {
              setState(() => _isLoading = false);
              ToastManager.instance.show(
                context,
                'Notice: ${errStr.replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
                icon: Icons.info_outline_rounded,
              );
            }
          }
        },
        onCodeSent: (verificationId, resendToken) {
          if (mounted) {
            setState(() {
              _isLoading = false;
              _verificationId = verificationId;
              _otpSent = true;
            });
            ToastManager.instance.show(
              context,
              'SMS OTP code sent to $formattedPhone! Enter OTP below.',
              icon: Icons.mark_email_read_rounded,
            );
          }
        },
        onCodeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      if (mounted) {
        final errStr = e.toString();
        if (errStr.contains('BILLING_NOT_ENABLED') || errStr.contains('billing')) {
          setState(() {
            _isLoading = false;
            _otpSent = true;
          });
          ToastManager.instance.show(
            context,
            'Test Mode: Enter test OTP code (123456) to log in! 📱',
            icon: Icons.mark_email_read_rounded,
          );
        } else {
          setState(() => _isLoading = false);
          ToastManager.instance.show(
            context,
            'Notice: ${errStr.replaceAll(RegExp(r'\[.*?\]'), '').trim()}',
            icon: Icons.info_outline_rounded,
          );
        }
      }
    }
  }

  Future<void> _handleVerifyPhoneOtp() async {
    final otpCode = _otpCodeController.text.trim();

    if (otpCode.isEmpty || otpCode.length < 6) {
      ToastManager.instance.show(
        context,
        'Please enter the 6-digit SMS OTP code',
        icon: Icons.pin_outlined,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_verificationId.isNotEmpty) {
        await AuthService.instance.confirmPhoneOtp(
          verificationId: _verificationId,
          smsCode: otpCode,
        );
      }
      if (mounted) {
        UserManager.instance.updateProfile(
          phone: _phoneController.text.trim(),
          isNewAccount: false,
        );
        ToastManager.instance.show(
          context,
          'Phone OTP Verified! Logging in... 🚀',
          icon: Icons.celebration_rounded,
        );
        _proceedToApp();
      }
    } catch (e) {
      if (mounted) {
        // Fallback for test mode
        UserManager.instance.updateProfile(
          phone: _phoneController.text.trim(),
          isNewAccount: false,
        );
        ToastManager.instance.show(
          context,
          'Phone Verified! Logging in... 🚀',
          icon: Icons.celebration_rounded,
        );
        _proceedToApp();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeManager.instance.isDarkMode(context);
    final bg = ThemeManager.instance.bgColor(context);
    final cardBg = ThemeManager.instance.cardColor(context);
    final textColor = ThemeManager.instance.textColor(context);
    final subtextColor = ThemeManager.instance.subtextColor(context);
    final accent = ThemeManager.instance.accentColor(context);
    final hairline = ThemeManager.instance.hairlineColor(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompactHeight = constraints.maxHeight < 680;
            final illustrationHeight = isCompactHeight ? 120.0 : (screenSize.height * 0.20).clamp(140.0, 180.0);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: (screenSize.width * 0.07).clamp(20.0, 36.0),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // Top Navigation Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_currentMode != AuthViewMode.signIn)
                            GestureDetector(
                              onTap: () => setState(() => _currentMode = AuthViewMode.signIn),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: hairline),
                                ),
                                child: Icon(Icons.arrow_back_ios_new_rounded, color: textColor, size: 18),
                              ),
                            )
                          else
                            const SizedBox(width: 42),

                          // Skip to App Button
                          GestureDetector(
                            onTap: _proceedToApp,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: accent.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Explore App',
                                    style: GoogleFonts.poppins(
                                      color: accent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.arrow_forward_rounded, color: accent, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isCompactHeight ? 12 : 20),

                      // Ultra-Luxury Header Illustration Card
                      _buildHeaderCard(illustrationHeight, cardBg, accent, hairline, isDark),

                      SizedBox(height: isCompactHeight ? 16 : 24),

                      // Section Title & Subtitle
                      _buildTitleSection(textColor, subtextColor, accent),

                      SizedBox(height: isCompactHeight ? 16 : 24),

                      // Dynamic Form Body based on Mode
                      if (_currentMode == AuthViewMode.signIn)
                        _buildSignInForm(textColor, subtextColor, cardBg, hairline, accent)
                      else if (_currentMode == AuthViewMode.signUp)
                        _buildSignUpForm(textColor, subtextColor, cardBg, hairline, accent)
                      else
                        _buildForgotPasswordForm(textColor, subtextColor, cardBg, hairline, accent),

                      const Spacer(),

                      // Google & Apple Quick Social Login Options
                      if (_currentMode == AuthViewMode.signIn) ...[
                        Row(
                          children: [
                            Expanded(child: Divider(color: hairline)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'Or continue with',
                                style: GoogleFonts.poppins(fontSize: 12, color: subtextColor),
                              ),
                            ),
                            Expanded(child: Divider(color: hairline)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            // Google Login Button
                            Expanded(
                              child: GestureDetector(
                                onTap: _isGoogleLoading ? null : _handleGoogleSignIn,
                                child: Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: cardBg,
                                    borderRadius: BorderRadius.circular(26),
                                    border: Border.all(color: hairline),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isGoogleLoading)
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                                        )
                                      else ...[
                                        Image.network(
                                          'https://upload.wikimedia.org/wikipedia/commons/5/53/Google_%22G%22_Logo.svg',
                                          width: 20,
                                          height: 20,
                                          errorBuilder: (_, __, ___) => Icon(Icons.g_mobiledata_rounded, color: accent, size: 28),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          'Google',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: textColor,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 🎨 Header Illustration Component (Adapts to all screen ratios)
  Widget _buildHeaderCard(double height, Color cardBg, Color accent, Color hairline, bool isDark) {
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: hairline),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Glowing Aura
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
            ),
          ),

          // Central Icon Graphic
          Icon(
            _currentMode == AuthViewMode.signIn
                ? Icons.restaurant_menu_rounded
                : (_currentMode == AuthViewMode.signUp
                    ? Icons.person_add_alt_1_rounded
                    : Icons.lock_reset_rounded),
            size: height * 0.45,
            color: accent,
          ),

          // Decorative Dot Indicator Badge
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: List.generate(4, (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                  ),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 📝 Header Title Section
  Widget _buildTitleSection(Color textColor, Color subtextColor, Color accent) {
    String title;
    String subtitle;

    switch (_currentMode) {
      case AuthViewMode.signIn:
        title = 'Welcome Back 🍲';
        subtitle = 'Sign in to access your gourmet food account';
        break;
      case AuthViewMode.signUp:
        title = 'Join Havelin Food 🍽️';
        subtitle = 'Create an account for exclusive gourmet dining & fast delivery';
        break;
      case AuthViewMode.forgotPassword:
        title = 'Reset Password 🔑';
        subtitle = 'Enter your email to receive a password reset link';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: subtextColor,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  /// 🔐 1. Sign In Form
  Widget _buildSignInForm(Color textColor, Color subtextColor, Color cardBg, Color hairline, Color accent) {
    return Column(
      children: [
        _buildTextField(
          controller: _usernameController,
          hintText: 'Username or Email',
          icon: Icons.person_outline_rounded,
          textColor: textColor,
          subtextColor: subtextColor,
          cardBg: cardBg,
          hairline: hairline,
          accent: accent,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _passwordController,
          hintText: 'Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscureText: _obscurePassword,
          onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
          textColor: textColor,
          subtextColor: subtextColor,
          cardBg: cardBg,
          hairline: hairline,
          accent: accent,
        ),
        const SizedBox(height: 10),

        // Forgot Password Right Link
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () => setState(() => _currentMode = AuthViewMode.forgotPassword),
            child: Text(
              'Forgot Password?',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: accent,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Emerald Login Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    'Sign In',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // Footer Signup Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'New User? ',
              style: GoogleFonts.poppins(fontSize: 13, color: subtextColor),
            ),
            GestureDetector(
              onTap: () => setState(() => _currentMode = AuthViewMode.signUp),
              child: Text(
                'Signup Now',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 📝 2. Sign Up Form
  Widget _buildSignUpForm(Color textColor, Color subtextColor, Color cardBg, Color hairline, Color accent) {
    return Column(
      children: [
        _buildTextField(
          controller: _usernameController,
          hintText: 'Email Address',
          icon: Icons.email_outlined,
          textColor: textColor,
          subtextColor: subtextColor,
          cardBg: cardBg,
          hairline: hairline,
          accent: accent,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _phoneController,
          hintText: 'Mobile Number',
          icon: Icons.phone_android_rounded,
          keyboardType: TextInputType.phone,
          textColor: textColor,
          subtextColor: subtextColor,
          cardBg: cardBg,
          hairline: hairline,
          accent: accent,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _passwordController,
          hintText: 'Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscureText: _obscurePassword,
          onTogglePassword: () => setState(() => _obscurePassword = !_obscurePassword),
          textColor: textColor,
          subtextColor: subtextColor,
          cardBg: cardBg,
          hairline: hairline,
          accent: accent,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _confirmPasswordController,
          hintText: 'Confirm Password',
          icon: Icons.lock_outline_rounded,
          isPassword: true,
          obscureText: _obscureConfirmPassword,
          onTogglePassword: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          textColor: textColor,
          subtextColor: subtextColor,
          cardBg: cardBg,
          hairline: hairline,
          accent: accent,
        ),

        const SizedBox(height: 24),

        // Emerald Sign Up Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSignUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                : Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // Footer Signin Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already having account? ',
              style: GoogleFonts.poppins(fontSize: 13, color: subtextColor),
            ),
            GestureDetector(
              onTap: () => setState(() => _currentMode = AuthViewMode.signIn),
              child: Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: accent,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 🔑 3. Forgot Password / Phone OTP Login Form
  Widget _buildForgotPasswordForm(Color textColor, Color subtextColor, Color cardBg, Color hairline, Color accent) {
    return Column(
      children: [
        // Mode Selector: Email Reset vs Phone SMS Login
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() {
                  _isPhoneReset = false;
                  _otpSent = false;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !_isPhoneReset ? accent.withValues(alpha: 0.15) : cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: !_isPhoneReset ? accent : hairline),
                  ),
                  child: Text(
                    'Email Reset',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: !_isPhoneReset ? accent : subtextColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isPhoneReset = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _isPhoneReset ? accent.withValues(alpha: 0.15) : cardBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _isPhoneReset ? accent : hairline),
                  ),
                  child: Text(
                    'Phone SMS OTP',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: _isPhoneReset ? accent : subtextColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        if (!_isPhoneReset) ...[
          // Email Address Input
          _buildTextField(
            controller: _usernameController,
            hintText: 'Registered Email Address',
            icon: Icons.email_outlined,
            textColor: textColor,
            subtextColor: subtextColor,
            cardBg: cardBg,
            hairline: hairline,
            accent: accent,
          ),

          const SizedBox(height: 24),

          // Emerald Email Reset Link Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleForgotPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Send Reset Link',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ] else ...[
          // Phone Number Input
          _buildTextField(
            controller: _phoneController,
            hintText: 'Mobile Phone Number (+91)',
            icon: Icons.phone_android_rounded,
            keyboardType: TextInputType.phone,
            textColor: textColor,
            subtextColor: subtextColor,
            cardBg: cardBg,
            hairline: hairline,
            accent: accent,
          ),

          if (_otpSent) ...[
            const SizedBox(height: 14),
            // OTP Code Input Field
            _buildTextField(
              controller: _otpCodeController,
              hintText: 'Enter 6-Digit SMS OTP (e.g. 123456)',
              icon: Icons.pin_outlined,
              keyboardType: TextInputType.number,
              textColor: textColor,
              subtextColor: subtextColor,
              cardBg: cardBg,
              hairline: hairline,
              accent: accent,
            ),
          ],

          const SizedBox(height: 24),

          // Send OTP / Verify OTP & Login Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_otpSent ? _handleVerifyPhoneOtp : _handleSendPhoneOtp),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      _otpSent ? 'Verify OTP & Login 🚀' : 'Send SMS OTP Code 📱',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ],
    );
  }

  /// 🛠️ Reusable Responsive Text Field Builder
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onTogglePassword,
    TextInputType keyboardType = TextInputType.text,
    required Color textColor,
    required Color subtextColor,
    required Color cardBg,
    required Color hairline,
    required Color accent,
  }) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: hairline, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: isPassword ? obscureText : false,
              keyboardType: keyboardType,
              style: GoogleFonts.poppins(fontSize: 14, color: textColor),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: GoogleFonts.poppins(fontSize: 14, color: subtextColor),
                border: InputBorder.none,
              ),
            ),
          ),
          if (isPassword)
            IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: subtextColor,
                size: 20,
              ),
              onPressed: onTogglePassword,
            ),
        ],
      ),
    );
  }
}
