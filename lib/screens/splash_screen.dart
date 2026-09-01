import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../navigation/bottom_nav_shell.dart';
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
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!widget.isApiConnected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ConnectionErrorScreen()),
      );
      return;
    }

    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        final userData = await AuthService.getUserData();
        if (userData != null) {
          final provider = Provider.of<AppProvider>(context, listen: false);
          provider.setUserFromMap(userData);
          // Role-based: all roles go to BottomNavShell, which handles per-tab routing
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const BottomNavShell()),
          );
          return;
        }
      }

      // Not logged in — show home (first tab: Beranda)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavShell()),
      );
    } catch (e) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BottomNavShell()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(color: AppColors.emerald, borderRadius: BorderRadius.circular(24)),
            child: const Icon(Icons.store, color: Colors.white, size: 60),
          ),
          const SizedBox(height: 30),
          Text('UMKM Indramayu', style: TextStyle(color: AppColors.emerald, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: AppColors.emerald),
          const SizedBox(height: 20),
          Text('Memuat...', style: TextStyle(color: AppColors.textGrey, fontSize: 16)),
        ]),
      ),
    );
  }
}
