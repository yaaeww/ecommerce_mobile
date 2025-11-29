import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../models/models.dart';

class CustomerNavBar extends StatelessWidget {
  final int dalamPengirimanCount;
  final String currentRoute;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onLogoutPressed;

  const CustomerNavBar({
    super.key,
    this.dalamPengirimanCount = 0,
    this.currentRoute = '',
    this.onProfilePressed,
    this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final user = provider.user;
        final totalCartItems = provider.totalCartItems;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0a1628).withOpacity(0.95),
            border: const Border(
                bottom: BorderSide(color: AppColors.gold, width: 2)),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Logo dan Brand
              _buildLogoBrand(),

              const Spacer(),

              // Navigation Menu
              _buildNavMenu(context),

              const Spacer(),

              // Right Side Items - PERBAIKAN: Teruskan context ke method ini
              _buildRightSideItems(context, user, totalCartItems),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogoBrand() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.gold,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.store,
            color: AppColors.darkBlue,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'UMKM Indramayu',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 10,
                color: AppColors.gold.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavMenu(BuildContext context) {
    final isHomeActive = currentRoute == '/customer-dashboard';
    final isProductsActive = currentRoute == '/customer-products';
    
    return Row(
      children: [
        _buildNavItem(context, 'Home', Icons.home, isHomeActive, () {
          Navigator.pushNamedAndRemoveUntil(
            context, 
            '/customer-dashboard', 
            (route) => false
          );
        }),
        const SizedBox(width: 20),
        _buildNavItem(context, 'Produk', FontAwesomeIcons.box, isProductsActive, () {
          Navigator.pushNamed(context, '/customer-products');
        }),
        const SizedBox(width: 20),
        _buildNavItem(context, 'Pesanan', FontAwesomeIcons.shoppingBag, false, () {
          // Add navigation for orders if needed
        }),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String title, IconData icon, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive ? Border.all(color: AppColors.gold, width: 1) : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.gold : Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive ? AppColors.gold : Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRightSideItems(BuildContext context, User? user, int totalCartItems) {
    return Row(
      children: [
        // Search Bar
        _buildSearchBar(),
        const SizedBox(width: 16),

        // Cart with Badge - PERBAIKAN: Teruskan context ke method ini
        _buildCartWithBadge(context, totalCartItems),
        const SizedBox(width: 16),

        // Notifications
        _buildNotifications(),
        const SizedBox(width: 16),

        // Chatbot Button
        _buildChatbotButton(),
        const SizedBox(width: 16),

        // Profile Dropdown
        _buildProfileDropdown(context, user),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 200,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Cari produk...',
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search,
              color: Colors.white.withOpacity(0.7), size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  // PERBAIKAN: Tambahkan parameter BuildContext
  Widget _buildCartWithBadge(BuildContext context, int totalCartItems) {
    return GestureDetector(
      onTap: () {
        // Navigate to cart screen
        Navigator.pushNamed(context, '/customer-cart');
      },
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              FontAwesomeIcons.shoppingCart,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (totalCartItems > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  totalCartItems.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            FontAwesomeIcons.truck,
            color: Colors.white,
            size: 20,
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.gold,
              shape: BoxShape.circle,
            ),
            child: Text(
              dalamPengirimanCount.toString(),
              style: const TextStyle(
                color: AppColors.darkBlue,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatbotButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, Color(0xFFffed4e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            FontAwesomeIcons.robot,
            color: AppColors.darkBlue,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Chatbot',
            style: TextStyle(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDropdown(BuildContext context, User? user) {
    return PopupMenuButton<String>(
      icon: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.gold,
            child: Text(
              user?.name.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            user?.name ?? 'User',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
      onSelected: (value) {
        if (value == 'profile') {
          _showProfileDialog(context, user);
        } else if (value == 'logout') {
          _showLogoutConfirmation(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              const Icon(Icons.person, size: 16),
              const SizedBox(width: 8),
              const Text('Profil'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              const Icon(Icons.logout, size: 16, color: Colors.red),
              const SizedBox(width: 8),
              const Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  void _showProfileDialog(BuildContext context, User? user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          'Profil Pengguna',
          style: TextStyle(color: AppColors.gold),
        ),
        content: user != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileInfo('Nama', user.name),
                  _buildProfileInfo('Email', user.email),
                  _buildProfileInfo('Role', user.role),
                  if (user.avatar != null)
                    _buildProfileInfo('Avatar', user.avatar!),
                ],
              )
            : const Text('Data user tidak tersedia'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E2E),
          title: Text(
            'Konfirmasi Logout',
            style: TextStyle(color: AppColors.gold),
          ),
          content: Text(
            'Apakah Anda yakin ingin logout?',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      await AuthService.logout();
      final provider = Provider.of<AppProvider>(context, listen: false);
      provider.logout();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Logout error: $e');
    }
  }
}