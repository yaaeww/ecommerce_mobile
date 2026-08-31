// screens/midtrans_payment_screen.dart (versi final)
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';

class MidtransPaymentScreen extends StatefulWidget {
  final String snapToken;
  final int orderId;

  const MidtransPaymentScreen({
    Key? key,
    required this.snapToken,
    required this.orderId,
  }) : super(key: key);

  @override
  State<MidtransPaymentScreen> createState() => _MidtransPaymentScreenState();
}

class _MidtransPaymentScreenState extends State<MidtransPaymentScreen> {
  late WebViewController _controller;
  bool _isLoading = true;

  String get _paymentUrl {
    // Create HTML for Midtrans payment
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <style>
        body {
          margin: 0;
          padding: 0;
          font-family: Arial, sans-serif;
          background: #0a1628;
          color: white;
        }
        .container {
          max-width: 600px;
          margin: 0 auto;
          padding: 20px;
        }
        .loading {
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          height: 100vh;
        }
        .loading-spinner {
          border: 4px solid #f3f3f3;
          border-top: 4px solid #ffd700;
          border-radius: 50%;
          width: 40px;
          height: 40px;
          animation: spin 1s linear infinite;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      </style>
    </head>
    <body>
      <div class="container">
        <div id="snap-container"></div>
      </div>
      
      <script src="https://app.sandbox.midtrans.com/snap/snap.js" 
              data-client-key="SB-Mid-client-YourClientKey"></script>
      <script>
        // Your Midtrans Snap configuration
        window.snap.pay('${widget.snapToken}', {
          onSuccess: function(result) {
            window.flutter_inappwebview.callHandler('paymentSuccess', result);
          },
          onPending: function(result) {
            window.flutter_inappwebview.callHandler('paymentPending', result);
          },
          onError: function(result) {
            window.flutter_inappwebview.callHandler('paymentError', result);
          },
          onClose: function() {
            window.flutter_inappwebview.callHandler('paymentClosed');
          }
        });
      </script>
    </body>
    </html>
    ''';
  }

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('PaymentHandler',
          onMessageReceived: (JavaScriptMessage message) {
        _handlePaymentMessage(message.message);
      })
      ..setBackgroundColor(const Color(0xFF0a1628))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadHtmlString(_paymentUrl);
  }

  void _handlePaymentMessage(String message) {
    // Handle payment callbacks from JavaScript
    switch (message) {
      case 'paymentSuccess':
        _showPaymentResult('Pembayaran Berhasil', true);
        break;
      case 'paymentPending':
        _showPaymentResult('Menunggu Pembayaran', false);
        break;
      case 'paymentError':
        _showPaymentResult('Pembayaran Gagal', false);
        break;
      case 'paymentClosed':
        Navigator.pop(context);
        break;
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
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Text(
              isSuccess ? 'Berhasil' : 'Perhatian',
              style: TextStyle(
                color: isSuccess ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess) {
                // Navigate to invoice/order history
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/customer-dashboard',
                  (route) => false,
                );
              }
            },
            child: Text(
              'OK',
              style: TextStyle(color: AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(FontAwesomeIcons.arrowLeft, color: AppColors.gold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pembayaran',
          style: TextStyle(color: AppColors.gold),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AppColors.gold),
                    const SizedBox(height: 20),
                    Text(
                      'Memuat halaman pembayaran...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
