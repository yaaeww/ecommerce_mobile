import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;
import '../../constants/colors.dart';
import '../../providers/app_provider.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../layouts/customer_navbar.dart';

class CustomerDashboardScreen extends StatefulWidget {
  const CustomerDashboardScreen({super.key});

  @override
  State<CustomerDashboardScreen> createState() =>
      _CustomerDashboardScreenState();
}

class _CustomerDashboardScreenState extends State<CustomerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _starController;
  final List<Star> _stars = [];
  List<Keranjang> _keranjangItems = [];
  List<Produk> _produkTerbaru = [];
  int _pesananAktifCount = 0;
  int _dalamPengirimanCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _initializeStars();
    _loadDashboardData();
  }

  void _initializeStars() {
    final random = math.Random();
    for (int i = 0; i < 100; i++) {
      _stars.add(Star(
        left: random.nextDouble(),
        top: random.nextDouble(),
        size: random.nextInt(3) + 1,
        duration: random.nextInt(3) + 2,
      ));
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);

      // Load data dari provider yang sudah ada
      await provider.loadKeranjang();
      await provider.loadProduksTerbaru();

      // Update state dengan data real
      setState(() {
        _keranjangItems = provider.keranjang;
        _produkTerbaru = provider.produksTerbaru;
        _pesananAktifCount = _calculatePesananAktif();
        _dalamPengirimanCount = _calculateDalamPengiriman();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _calculatePesananAktif() => 2;
  int _calculateDalamPengiriman() => 1;

  @override
  void dispose() {
    _starController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: _isLoading
          ? _buildLoadingScreen()
          : Stack(
              children: [
                // Background dengan bintang animasi
                _buildAnimatedBackground(),

                // Content utama dengan CustomScrollView
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Navbar sebagai SliverAppBar - MENGGUNAKAN CUSTOM NAVBAR
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      floating: true,
                      pinned: false,
                      snap: false,
                      expandedHeight: 0,
                      toolbarHeight: 80,
                      flexibleSpace: CustomerNavBar(
                        dalamPengirimanCount: _dalamPengirimanCount,
                        currentRoute: '/customer-dashboard', // TAMBAHKAN INI
                      ),
                    ),

                    // Hero Banner
                    SliverToBoxAdapter(
                      child: _buildHeroBanner(),
                    ),

                    // Main Content
                    SliverToBoxAdapter(
                      child: _buildMainContent(),
                    ),

                    // Footer
                    SliverToBoxAdapter(
                      child: _buildFooter(),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.gold),
            const SizedBox(height: 20),
            Text(
              'Memuat Dashboard...',
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

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _starController,
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0a1628),
                const Color(0xFF1a3a5f),
              ],
            ),
          ),
          child: Stack(
            children: _stars.map((star) {
              return Positioned(
                left: star.left * size.width,
                top: star.top * size.height,
                child: Opacity(
                  opacity: _starController.value * 0.8,
                  child: Container(
                    width: star.size.toDouble(),
                    height: star.size.toDouble(),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(star.size / 2),
                      boxShadow: star.size > 2
                          ? [
                              BoxShadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 2,
                              )
                            ]
                          : null,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildHeroBanner() {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final user = provider.user;

        return Container(
          height: 200,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0a1628),
                Color(0xFF1a3a5f),
                Color(0xFF2a4a7f),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            children: [
              _buildBackgroundPattern(),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Selamat Datang, ${user?.name ?? 'Pembeli'}!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        foreground: Paint()
                          ..shader = const LinearGradient(
                            colors: [AppColors.gold, Color(0xFFffed4e)],
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Belanja Produk UMKM Lokal Lebih Mudah dan Menyenangkan!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundPattern() {
    return Positioned(
      right: -50,
      bottom: -50,
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              AppColors.gold.withOpacity(0.1),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 40,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Pembeli',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildStatsCards(),
            const SizedBox(height: 30),
            _buildQuickActions(),
            const SizedBox(height: 30),
            _buildProdukTerbaruSection(),
            const SizedBox(height: 30),
            _buildRecentActivity(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard('Pesanan Aktif', _pesananAktifCount.toString(),
              FontAwesomeIcons.shoppingBag, Colors.blue),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
              'Dalam Pengiriman',
              _dalamPengirimanCount.toString(),
              FontAwesomeIcons.truck,
              Colors.orange),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard('Keranjang', _keranjangItems.length.toString(),
              FontAwesomeIcons.shoppingCart, Colors.green),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildQuickActionCard(
                'Belanja', FontAwesomeIcons.shoppingBag, Colors.blue, () {
              Navigator.pushNamed(context, '/customer-products');
            }),
            _buildQuickActionCard('Keranjang', FontAwesomeIcons.shoppingCart,
                Colors.orange, () {}),
            _buildQuickActionCard(
                'Pesanan', FontAwesomeIcons.listAlt, Colors.green, () {}),
            _buildQuickActionCard(
                'Profil', FontAwesomeIcons.user, Colors.purple, () {
              // Profile dialog sudah ditangani di navbar
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProdukTerbaruSection() {
    if (_produkTerbaru.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Produk Terbaru',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _produkTerbaru.length,
            itemBuilder: (context, index) {
              final produk = _produkTerbaru[index];
              return _buildProdukItem(produk);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProdukItem(Produk produk) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/customer-products');
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: produk.gambar != null
                    ? DecorationImage(
                        image: NetworkImage(
                            ApiService.getImageUrl(produk.gambar!)),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[800],
              ),
              child: produk.gambar == null
                  ? const Icon(Icons.image, color: Colors.grey)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    produk.nama,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rp ${produk.hargaSetelahDiskon.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas Terbaru',
          style: TextStyle(
            color: AppColors.gold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            if (_keranjangItems.isNotEmpty)
              _buildActivityItem(
                  'Keranjang',
                  '${_keranjangItems.length} item di keranjang',
                  FontAwesomeIcons.shoppingCart),
            if (_produkTerbaru.isNotEmpty)
              _buildActivityItem(
                  'Produk Baru',
                  '${_produkTerbaru.length} produk baru tersedia',
                  FontAwesomeIcons.newspaper),
            _buildActivityItem('Pesanan Aktif',
                '$_pesananAktifCount pesanan aktif', FontAwesomeIcons.clock),
            _buildActivityItem(
                'Pengiriman',
                '$_dalamPengirimanCount dalam pengiriman',
                FontAwesomeIcons.truck),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0a1628),
            Color(0xFF1a3a5f),
          ],
        ),
        border: const Border(top: BorderSide(color: AppColors.gold, width: 2)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FontAwesomeIcons.store,
                  color: AppColors.gold, size: 16),
              const SizedBox(width: 8),
              Text(
                'UMKM Indramayu',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '© ${DateTime.now().year} UMKM Indramayu - Kelompok 7',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Powered by Flutter & Dart | Designed by Belanjain',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class Star {
  final double left;
  final double top;
  final int size;
  final int duration;

  Star({
    required this.left,
    required this.top,
    required this.size,
    required this.duration,
  });
}
