import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../screens/home_screen.dart';
import '../screens/customer/products_screen.dart';
import '../screens/pesanan_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/akun_screen.dart';
import '../screens/seller/seller_dashboard.dart';

/// Dynamic Bottom Navigation Shell based on user authentication & role
/// - Guest (Belum login): Beranda | Eksplor | Akun (Hanya 3 menu publik)
/// - Pembeli (Sudah login): Beranda | Eksplor | Pesanan | Chat | Akun
/// - Penjual (Sudah login): Beranda | Eksplor | Toko Saya | Chat | Akun
class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final isLoggedIn = provider.user != null;
        final isSeller = provider.user?.role == 'penjual';

        // 1. Definisikan Tab Items dan Pages secara Dinamis
        final List<BottomNavigationBarItem> navItems;
        final List<Widget> pages;

        if (!isLoggedIn) {
          // GUEST (Belum Login) — Hanya 3 Menu
          navItems = const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.house, size: 18),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.magnifyingGlass, size: 18),
              ),
              label: 'Eksplor',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.user, size: 18),
              ),
              label: 'Akun',
            ),
          ];

          pages = const [
            HomeScreen(),
            ProductsScreen(),
            AkunScreen(),
          ];
        } else if (isSeller) {
          // PENJUAL (Sudah Login)
          navItems = const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.house, size: 18),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.magnifyingGlass, size: 18),
              ),
              label: 'Katalog',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.store, size: 18),
              ),
              label: 'Toko Saya',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.comments, size: 18),
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.user, size: 18),
              ),
              label: 'Akun',
            ),
          ];

          pages = const [
            HomeScreen(),
            ProductsScreen(),
            SellerDashboardScreen(),
            ChatScreen(),
            AkunScreen(),
          ];
        } else {
          // PEMBELI (Sudah Login)
          navItems = const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.house, size: 18),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.magnifyingGlass, size: 18),
              ),
              label: 'Eksplor',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.bagShopping, size: 18),
              ),
              label: 'Pesanan',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.comments, size: 18),
              ),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(FontAwesomeIcons.user, size: 18),
              ),
              label: 'Akun',
            ),
          ];

          pages = const [
            HomeScreen(),
            ProductsScreen(),
            PesananScreen(),
            ChatScreen(),
            AkunScreen(),
          ];
        }

        // Pastikan indeks yang dipilih tidak out-of-bounds saat auth state berubah
        final currentIndex = _selectedIndex >= pages.length ? 0 : _selectedIndex;

        return Scaffold(
          body: pages[currentIndex],
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              elevation: 0,
              selectedItemColor: AppColors.emerald,
              unselectedItemColor: AppColors.textGrey,
              selectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              showUnselectedLabels: true,
              items: navItems,
              currentIndex: currentIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            ),
          ),
        );
      },
    );
  }
}
