// screens/midtrans_payment_screen.dart (fixed v2 — corrected JS channel mismatch)
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';

class MidtransPaymentScreen extends StatefulWidget {
  final String snapToken;
  final int orderId;

  const MidtransPaymentScreen({
    super.key,
    required this.snapToken,
    required this.orderId,
  });

  @override
  State<MidtransPaymentScreen> createState() => _MidtransPaymentScreenState();
}

class _MidtransPaymentScreenState extends State<MidtransPaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  /// Fixed: JS channel name must match what the injected JS calls.
  /// Previously used `flutter_inappwebview.callHandler()` (wrong package)
  /// with a `webview_flutter` JavaScriptChannel named 'PaymentHandler' (no bridge).
  /// Now JS calls `Flutter.postMessage()` which webview_flutter routes to
  /// the registered 'PaymentHandler' JavaScriptChannel.
  String get _paymentHtml => '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { margin: 0; padding: 0; font-family: Arial, sans-serif; background: #0a1628; color: white; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .loading { display: flex; flex-direction: column; align-items: center; justify-content: center; height: 100vh; }
    .loading-spinner { border: 4px solid #f3f3f3; border-top: 4px solid #f59e0b; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; }
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
  </style>
</head>
<body>
  <div class="container">
    <div id="snap-container"></div>
  </div>
  <script src="https://app.sandbox.midtrans.com/snap/snap.js" data-client-key="SB-Mid-client-YourClientKey"></script>
  <script>
    // Fixed: use Flutter.postMessage (webview_flutter bridge) not flutter_inappwebview
    window.snap.pay('\${widget.snapToken}', {
      onSuccess: function(result) { Flutter.postMessage('paymentSuccess:' + JSON.stringify(result)); },
      onPending: function(result) { Flutter.postMessage('paymentPending:' + JSON.stringify(result)); },
      onError: function(result) { Flutter.postMessage('paymentError:' + JSON.stringify(result)); },
      onClose: function() { Flutter.postMessage('paymentClosed'); }
    });
  </script>
</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('PaymentHandler',
          onMessageReceived: _onJsMessage)
      ..setBackgroundColor(AppColors.darkBlue)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadHtmlString(_paymentHtml);
  }

  void _onJsMessage(JavaScriptMessage message) {
    final msg = message.message;
    if (msg.startsWith('paymentSuccess:')) {
      _showPaymentResult('Pembayaran Berhasil', true);
    } else if (msg.startsWith('paymentPending:')) {
      _showPaymentResult('Menunggu Pembayaran', false);
    } else if (msg.startsWith('paymentError:')) {
      _showPaymentResult('Pembayaran Gagal', false);
    } else if (msg == 'paymentClosed') {
      Navigator.pop(context);
    }
  }

  void _showPaymentResult(String message, bool isSuccess) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Row(
          children: [
            Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red),
            const SizedBox(width: 12),
            Text(
              isSuccess ? 'Berhasil' : 'Perhatian',
              style: TextStyle(color: isSuccess ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess) {
                Navigator.pushNamedAndRemoveUntil(context, '/customer-dashboard', (route) => false);
              }
            },
            child: Text('OK', style: TextStyle(color: AppColors.mango)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: AppColors.emerald),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Pembayaran', style: TextStyle(color: AppColors.textDark)),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const CircularProgressIndicator(color: AppColors.mango),
                  const SizedBox(height: 20),
                  Text('Memuat halaman pembayaran...', style: TextStyle(color: Colors.white, fontSize: 16)),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
