import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umkm_indramayu_mobile/screens/admin/admin_dashboard.dart';
import 'package:umkm_indramayu_mobile/screens/auth/login_screen.dart';
import 'package:umkm_indramayu_mobile/screens/customer/cart_screen.dart';
import 'package:umkm_indramayu_mobile/screens/customer/customer_dashboard.dart';
import 'package:umkm_indramayu_mobile/screens/customer/products_screen.dart';
import 'package:umkm_indramayu_mobile/screens/home_screen.dart';
import 'package:umkm_indramayu_mobile/screens/seller/seller_dashboard.dart';
import 'package:umkm_indramayu_mobile/providers/app_provider.dart';
import 'package:umkm_indramayu_mobile/screens/splash_screen.dart';
import 'package:umkm_indramayu_mobile/services/api_service.dart';

// Import halaman baru - tanpa import model langsung di sini
import 'package:umkm_indramayu_mobile/screens/customer/checkout_screen.dart';
import 'package:umkm_indramayu_mobile/screens/customer/order_detail_screen.dart';
import 'package:umkm_indramayu_mobile/screens/midtrans_payment_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check API connection
  final isApiConnected = await ApiService.testConnection();

  runApp(MyApp(
    isApiConnected: isApiConnected,
  ));
}

class MyApp extends StatelessWidget {
  final bool isApiConnected;

  const MyApp({
    super.key,
    required this.isApiConnected,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: MaterialApp(
        title: 'UMKM Indramayu',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: 'Segoe UI',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(isApiConnected: isApiConnected),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/login': (context) => const LoginScreen(),
          '/admin-dashboard': (context) => const AdminDashboardScreen(),
          '/seller-dashboard': (context) => const SellerDashboardScreen(),
          '/customer-dashboard': (context) => const CustomerDashboardScreen(),
          '/customer-products': (context) => const ProductsScreen(),
          '/customer-cart': (context) => const CartScreen(),
          '/customer-checkout': (context) {
            // Handle arguments dari CartScreen
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is Map<String, dynamic>) {
              return CheckoutScreen(
                produk: args['produk'] as dynamic,
                quantity: args['quantity'] as int,
              );
            }
            // Fallback jika tidak ada arguments
            return const Scaffold(
              body: Center(
                child: Text('Data produk tidak ditemukan'),
              ),
            );
          },
          '/customer-order-detail': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            // Gunakan dynamic untuk menghindari error import
            if (args != null) {
              return OrderDetailScreen(
                order: args as dynamic,
              );
            }
            // Fallback jika tidak ada arguments
            return const Scaffold(
              body: Center(
                child: Text('Data order tidak ditemukan'),
              ),
            );
          },
          '/midtrans-payment': (context) {
            final args = ModalRoute.of(context)?.settings.arguments
                as Map<String, dynamic>?;
            if (args != null) {
              return MidtransPaymentScreen(
                snapToken: args['snapToken'] as String? ?? '',
                orderId: args['orderId'] as int? ?? 0,
              );
            }
            return const Scaffold(
              body: Center(
                child: Text('Data pembayaran tidak ditemukan'),
              ),
            );
          },
        },
      ),
    );
  }
}
