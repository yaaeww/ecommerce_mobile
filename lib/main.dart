import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:umkm_indramayu_mobile/screens/auth/login_screen.dart';
import 'package:umkm_indramayu_mobile/screens/auth/register_screen.dart';
import 'package:umkm_indramayu_mobile/providers/app_provider.dart';
import 'package:umkm_indramayu_mobile/screens/splash_screen.dart';
import 'package:umkm_indramayu_mobile/services/api_service.dart';
import 'package:umkm_indramayu_mobile/navigation/bottom_nav_shell.dart';

import 'package:umkm_indramayu_mobile/screens/customer/cart_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isApiConnected = await ApiService.testConnection();
  runApp(MyApp(isApiConnected: isApiConnected));
}

class MyApp extends StatelessWidget {
  final bool isApiConnected;

  const MyApp({super.key, required this.isApiConnected});

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
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF059669), // emerald
            secondary: const Color(0xFFF59E0B), // mango
            surface: Colors.white,
            background: const Color(0xFFFAFAFA),
            onSurface: const Color(0xFF111827),
            onPrimary: Colors.white,
          ),
          useMaterial3: true,
          fontFamily: 'Inter',
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(isApiConnected: isApiConnected),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/app': (_) => const BottomNavShell(),
          '/customer-dashboard': (_) => const BottomNavShell(),
          '/customer-cart': (_) => const CartScreen(),
        },
      ),
    );
  }
}
