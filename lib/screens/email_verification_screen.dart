import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:convert';
import '../theme/theme_manager.dart';
import '../widgets/theme_toggle_button.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String email;
  final ThemeManager themeManager;

  const EmailVerificationScreen({
    required this.email,
    required this.themeManager,
    super.key,
  });

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController codeController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> _verifyEmail() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      _showErrorSnackBar('Lütfen doğrulama kodunu girin');
      return;
    }

    if (code.length != 6) {
      _showErrorSnackBar('Doğrulama kodu 6 haneli olmalıdır');
      return;
    }

    // Debug için log
    print('Email: ${widget.email}');
    print('Code: $code');
    print('Code length: ${code.length}');

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await ApiService.instance.verifyCode(
        email: widget.email,
        code: code,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (response.statusCode == 200) {
        // Başarılı doğrulama
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email doğrulandı! Giriş yapabilirsiniz.'),
              backgroundColor: Colors.green,
            ),
          );

          // Login ekranına yönlendir
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  LoginScreen(themeManager: widget.themeManager),
            ),
          );
        }
      } else {
        // Hata durumu - detaylı log
        print('❌ Hata Response Status: ${response.statusCode}');
        print('❌ Hata Response Body: ${response.body}');
        
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['error'] ?? errorData['message'] ?? 'Doğrulama başarısız oldu';
          _showErrorSnackBar(errorMessage);
        } catch (e) {
          print('❌ JSON parse hatası: $e');
          _showErrorSnackBar('Doğrulama başarısız oldu: ${response.body}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Bağlantı hatası: ${e.toString()}');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
    });

    try {
      final response = await ApiService.instance.resendVerificationCode(
        widget.email,
      );

      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Doğrulama kodu email adresinize gönderildi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? 'Kod gönderilemedi';
        _showErrorSnackBar(errorMessage);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        _showErrorSnackBar('Bağlantı hatası: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Email Doğrulama'),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Title
                      Text(
                        'Doğrulama Kodu',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Subtitle
                      Text(
                        'Email adresinize gönderilen 6 haneli kodu girin',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email display
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.email_outlined,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Verification Code TextField
                      TextField(
                        controller: codeController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 6,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 8,
                          color: colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Doğrulama Kodu',
                          hintText: '000000',
                          counterText: '',
                          prefixIcon: Icon(
                            Icons.security,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Verify Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: _isLoading ? null : _verifyEmail,
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            disabledBackgroundColor:
                                colorScheme.surfaceContainerHighest,
                          ),
                          child: _isLoading
                              ? SpinKitThreeBounce(
                                  color: colorScheme.onPrimary,
                                  size: 24.0,
                                )
                              : Text(
                                  'Doğrula',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Resend Code
                      Center(
                        child: TextButton(
                          onPressed: (_isLoading || _isResending)
                              ? null
                              : _resendCode,
                          child: _isResending
                              ? Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                colorScheme.primary),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Gönderiliyor...',
                                      style:
                                          theme.textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  'Kodu tekrar gönder',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Theme Toggle Button
          ThemeToggleButton(themeManager: widget.themeManager),
        ],
      ),
    );
  }
}
