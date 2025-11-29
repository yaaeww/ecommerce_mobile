import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';
import 'auth/login_screen.dart';
import 'admin/admin_dashboard.dart';
import 'seller/seller_dashboard.dart';
import 'customer/customer_dashboard.dart';
import 'connection_error_screen.dart';

class SplashScreen extends StatefulWidget {
  final bool isApiConnected;

  const SplashScreen({
    super.key,
    required this.isApiConnected,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Tunggu sebentar untuk animasi splash
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!widget.isApiConnected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ConnectionErrorScreen()),
      );
      return;
    }

    // Check authentication status
    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      
      if (isLoggedIn) {
        final userData = await AuthService.getUserData();
        if (userData != null) {
          final provider = Provider.of<AppProvider>(context, listen: false);
          provider.setUserFromMap(userData);
          
          // Navigate based on role
          _navigateToDashboard(provider.user!.role);
          return;
        }
      }
      
      // If not logged in, go to home screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      print('Error during initialization: $e');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _navigateToDashboard(String role) {
    switch (role) {
      case 'admin':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const AdminDashboardScreen()),
        );
        break;
      case 'penjual':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SellerDashboardScreen()),
        );
        break;
      case 'pembeli':
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CustomerDashboardScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.store,
                color: AppColors.darkBlue,
                size: 60,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'UMKM Indramayu',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            CircularProgressIndicator(color: AppColors.gold),
            const SizedBox(height: 20),
            Text(
              'Memuat...',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}