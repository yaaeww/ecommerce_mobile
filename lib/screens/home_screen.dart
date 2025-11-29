import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../services/auth_service.dart';
import '../widgets/category_section.dart';
import '../widgets/product_section.dart';
import '../widgets/about_section.dart';
import '../widgets/footer_section.dart';
import '../widgets/hero_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.loadInitialData();
  }

  void _scrollToSection(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    final sections = [0.0, 600.0, 1200.0, 1800.0];
    if (index < sections.length) {
      _scrollController.animateTo(
        sections[index],
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Consumer<AppProvider>(
        builder: (context, provider, child) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: AppColors.darkBlue.withOpacity(0.98),
                elevation: 0,
                floating: true,
                pinned: true,
                expandedHeight: 100,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildNavBar(provider),
                ),
              ),

              // Hero Section
              const SliverToBoxAdapter(
                child: HeroSection(),
              ),

              // Kategori Section
              SliverToBoxAdapter(
                child: CategorySection(
                  kategoris: provider.kategoris,
                  onCategoryTap: (kategori) {
                    // Navigate to category products
                  },
                ),
              ),

              // Produk Terbaru Section
              SliverToBoxAdapter(
                child: ProductSection(
                  produks: provider.produksTerbaru,
                  title: 'Produk Terbaru',
                  onAddToCart: () {
                    // Arahkan ke login ketika klik tambah keranjang
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ),

              // About Section
              const SliverToBoxAdapter(
                child: AboutSection(),
              ),

              // Footer
              const SliverToBoxAdapter(
                child: FooterSection(),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildNavBar(AppProvider provider) {
    final isLoggedIn = provider.user != null;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkBlue, AppColors.mediumBlue],
        ),
        border: Border(bottom: BorderSide(color: AppColors.gold, width: 2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Logo
            CircleAvatar(
              backgroundColor: AppColors.gold,
              radius: 20,
              child: const Text(
                'UI',
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'UMKM Indramayu',
              style: TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 18,
                shadows: [
                  Shadow(
                    blurRadius: 10,
                    color: AppColors.gold,
                  ),
                ],
              ),
            ),
            const Spacer(),

            // Auth Buttons - Tampilkan berbeda jika sudah login
            if (isLoggedIn)
              _buildUserMenu(provider)
            else
              _buildGuestAuthButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestAuthButtons() {
    return Row(
      children: [
        OutlinedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.gold,
            side: const BorderSide(color: AppColors.gold, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          child: const Text(
            'Login',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () {
            // Navigate to register
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.darkBlue,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          ),
          child: const Text(
            'Sign Up',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildUserMenu(AppProvider provider) {
    return Row(
      children: [
        Text(
          'Halo, ${provider.user?.name ?? 'User'}',
          style: TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<String>(
          icon: Icon(Icons.account_circle, color: AppColors.gold),
          onSelected: (value) {
            if (value == 'dashboard') {
              // Navigate ke dashboard berdasarkan role
              if (provider.user?.role == 'admin') {
                Navigator.pushReplacementNamed(context, '/admin-dashboard');
              } else if (provider.user?.role == 'penjual') {
                Navigator.pushReplacementNamed(context, '/seller-dashboard');
              } else {
                Navigator.pushReplacementNamed(context, '/customer-dashboard');
              }
            } else if (value == 'logout') {
              _handleLogout(provider);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'dashboard',
              child: Text('Dashboard'),
            ),
            PopupMenuItem(
              value: 'logout',
              child: Text('Logout'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleLogout(AppProvider provider) async {
    try {
      await AuthService.logout();
      provider.logout();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      print('Logout error: $e');
    }
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkBlue, AppColors.mediumBlue],
        ),
        border: Border(top: BorderSide(color: AppColors.gold, width: 1)),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentNavIndex,
        onTap: _scrollToSection,
        backgroundColor: Colors.transparent,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.gold,
        unselectedItemColor: AppColors.textLight,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.layerGroup),
            label: 'Kategori',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.box),
            label: 'Produk',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.infoCircle),
            label: 'Tentang',
          ),
        ],
      ),
    );
  }
}
