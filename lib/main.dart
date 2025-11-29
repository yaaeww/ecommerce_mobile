import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umkm_indramayu_mobile/screens/admin/admin_dashboard.dart';
import 'package:umkm_indramayu_mobile/screens/auth/login_screen.dart';
import 'package:umkm_indramayu_mobile/screens/customer/cart_screen.dart';
import 'package:umkm_indramayu_mobile/screens/customer/customer_dashboard.dart';
import 'package:umkm_indramayu_mobile/screens/customer/products_screen.dart';
import 'package:umkm_indramayu_mobile/screens/home_screen.dart';
import 'package:umkm_indramayu_mobile/screens/seller/seller_dashboard.dart';
import 'providers/app_provider.dart';
import 'screens/splash_screen.dart';
import 'services/api_service.dart';

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
        },
      ),
    );
  }
}
