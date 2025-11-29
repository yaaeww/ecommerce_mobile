import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        title: Text('Seller Dashboard'),
        backgroundColor: AppColors.darkBlue,
        foregroundColor: AppColors.gold,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Provider.of<AppProvider>(context, listen: false).logout();
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store,
              size: 100,
              color: AppColors.gold,
            ),
            SizedBox(height: 20),
            Text(
              'Halaman Penjual',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Consumer<AppProvider>(
              builder: (context, provider, child) {
                return Text(
                  'Selamat datang, ${provider.user?.name ?? 'Penjual'}!',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
