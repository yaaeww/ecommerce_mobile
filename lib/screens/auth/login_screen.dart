import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../constants/colors.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    if (kIsWeb) {
      _showWebCaptchaDialog();
    } else {
      _showCaptchaModal();
    }
  }

  void _showWebCaptchaDialog() {
    bool isChecking = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.emerald.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.shield_outlined, color: AppColors.emerald, size: 22),
              ),
              const SizedBox(width: 10),
              const Text('Verifikasi Keamanan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Centang verifikasi berikut untuk melanjutkan masuk ke akun:',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    if (isChecking)
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.emerald),
                      )
                    else
                      Checkbox(
                        value: false,
                        activeColor: AppColors.emerald,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (val) {
                          setDialogState(() => isChecking = true);
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (!mounted) return;
                            if (ctx.mounted) {
                              Navigator.of(ctx).pop();
                            }
                            _performLogin('web_verified');
                          });
                        },
                      ),
                    const SizedBox(width: 10),
                    const Text(
                      'Saya bukan robot',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.verified, color: Colors.blue, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCaptchaModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CaptchaBottomSheet(
        siteKey: ApiService.recaptchaSiteKey,
        onVerified: (String token) {
          Navigator.of(ctx).pop();
          _performLogin(token);
        },
      ),
    );
  }

  Future<void> _performLogin(String captchaToken) async {
    setState(() => _isLoading = true);

    try {
      final response = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
        captchaToken: captchaToken,
      );

      if (!mounted) return;

      final dynamic rawData = response['data'] ?? response;
      if (rawData is Map<String, dynamic> && rawData['user'] != null) {
        final userData = rawData['user'] as Map<String, dynamic>;
        final User user = User.fromJson(userData);
        
        final provider = Provider.of<AppProvider>(context, listen: false);
        provider.setUser(user);
        
        // Reload data for authenticated user
        provider.loadKeranjang();
        provider.loadOrders();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(response['message']?.toString() ?? 'Selamat datang kembali!'),
              ],
            ),
            backgroundColor: AppColors.emerald,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        // Navigate to BottomNavShell root, which automatically shows 5 tabs for logged in user
        Navigator.pushNamedAndRemoveUntil(context, '/app', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        final errorMsg = e.toString().replaceAll('Exception: ', '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMsg)),
              ],
            ),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _quickFill(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.textDark),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/app');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Branding
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0), width: 1.5),
                        ),
                        child: const Center(
                          child: Icon(
                            FontAwesomeIcons.lemon,
                            color: AppColors.emerald,
                            size: 36,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Masuk Akun',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Nikmati belanja mangga segar & olahan UMKM Indramayu',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Email Field
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'nama@email.com',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.email_outlined, size: 20, color: Color(0xFF64748B)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Email wajib diisi';
                          if (!val.contains('@')) return 'Format email tidak valid';
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Password Field
                      const Text(
                        'Password',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Minimal 6 karakter',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                          prefixIcon: const Icon(Icons.lock_outline, size: 20, color: Color(0xFF64748B)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              size: 20,
                              color: const Color(0xFF64748B),
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.emerald, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Password wajib diisi';
                          if (val.length < 6) return 'Password minimal 6 karakter';
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text(
                                  'Masuk Sekarang',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Register Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Belum punya akun? ',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/register'),
                        child: const Text(
                          'Daftar Sekarang',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emerald,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Demo Account Helpers for seamless testing
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: Color(0xFFD97706)),
                          SizedBox(width: 6),
                          Text(
                            'Akun Uji Coba Cepat',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _quickFill('pembeli@example.com', 'password'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF92400E),
                                side: const BorderSide(color: Color(0xFFD97706)),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Akun Pembeli', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _quickFill('penjual@example.com', 'password'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF92400E),
                                side: const BorderSide(color: Color(0xFFD97706)),
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Akun Penjual', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Browse as Guest
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/app', (r) => false),
                    child: Text(
                      'Lanjut sebagai Tamu (Guest)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptchaBottomSheet extends StatefulWidget {
  final String siteKey;
  final Function(String token) onVerified;

  const _CaptchaBottomSheet({
    required this.siteKey,
    required this.onVerified,
  });

  @override
  State<_CaptchaBottomSheet> createState() => _CaptchaBottomSheetState();
}

class _CaptchaBottomSheetState extends State<_CaptchaBottomSheet> {
  WebViewController? _webController;
  bool _isLoading = true;

  String get _htmlContent => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <script src="https://www.google.com/recaptcha/api.js" async defer></script>
  <style>
    * { box-sizing: border-box; }
    body {
      margin: 0;
      padding: 24px 12px;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      background: #FFFFFF;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    }
  </style>
</head>
<body>
  <div class="g-recaptcha" data-sitekey="${widget.siteKey}" data-callback="onCaptchaToken"></div>
  <script>
    function onCaptchaToken(token) {
      if (typeof CaptchaBridge !== 'undefined' && CaptchaBridge.postMessage) {
        CaptchaBridge.postMessage(token);
      } else if (window.CaptchaBridge && window.CaptchaBridge.postMessage) {
        window.CaptchaBridge.postMessage(token);
      }
    }
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _webController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'CaptchaBridge',
          onMessageReceived: (JavaScriptMessage msg) {
            if (msg.message.isNotEmpty) {
              widget.onVerified(msg.message);
            }
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) setState(() => _isLoading = false);
            },
          ),
        )
        ..loadHtmlString(_htmlContent, baseUrl: 'http://localhost');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 480,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.emerald.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.security, color: AppColors.emerald, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verifikasi Keamanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        'Centang kotak di bawah untuk melanjutkan',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Stack(
              children: [
                if (!kIsWeb && _webController != null)
                  WebViewWidget(controller: _webController!)
                else
                  const Center(
                    child: Text('Verifikasi khusus aplikasi mobile (Android/iOS).'),
                  ),
                if (_isLoading && !kIsWeb)
                  const Center(
                    child: CircularProgressIndicator(color: AppColors.emerald),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
