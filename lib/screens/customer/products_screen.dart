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

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _starController;
  final List<Star> _stars = [];
  List<Produk> _allProduk = [];
  List<Produk> _filteredProduk = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 8;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _initializeStars();
    _loadProductsData();
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

  Future<void> _loadProductsData() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      await provider.loadAllProduks();

      // Simulasi data produk (dalam real app, ini dari API)
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _allProduk = provider.produks;
        _filteredProduk = _allProduk;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterProducts(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredProduk = _allProduk;
      } else {
        _filteredProduk = _allProduk
            .where((produk) =>
                produk.nama.toLowerCase().contains(query.toLowerCase()) ||
                (produk.deskripsi
                        ?.toLowerCase()
                        .contains(query.toLowerCase()) ??
                    false))
            .toList();
      }
      _currentPage = 1; // Reset ke halaman pertama saat filter
    });
  }

  List<Produk> get _paginatedProduk {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _filteredProduk.length > endIndex
        ? _filteredProduk.sublist(startIndex, endIndex)
        : _filteredProduk.sublist(startIndex);
  }

  int get _totalPages => (_filteredProduk.length / _itemsPerPage).ceil();

  @override
  void dispose() {
    _starController.dispose();
    _scrollController.dispose();
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
                  controller: _scrollController,
                  slivers: [
                    // Navbar sebagai SliverAppBar - MENGGUNAKAN CUSTOM NAVBAR
                    SliverAppBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      automaticallyImplyLeading: false,
                      floating: true,
                      pinned: false,
                      expandedHeight: 0,
                      toolbarHeight: 80,
                      flexibleSpace: CustomerNavBar(
                        dalamPengirimanCount: 0,
                        currentRoute: '/customer-products', // TAMBAHKAN INI
                      ),
                    ),

                    // Page Header
                    SliverToBoxAdapter(
                      child: _buildPageHeader(),
                    ),

                    // Search Bar Section
                    SliverToBoxAdapter(
                      child: _buildEnhancedSearchSection(),
                    ),

                    // Products Grid
                    if (_filteredProduk.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.7,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) =>
                                _buildProductCard(_paginatedProduk[index]),
                            childCount: _paginatedProduk.length,
                          ),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      ),

                    // Pagination
                    if (_filteredProduk.isNotEmpty && _totalPages > 1)
                      SliverToBoxAdapter(
                        child: _buildPagination(),
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
              'Memuat Produk...',
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

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.boxes, color: AppColors.gold, size: 24),
              const SizedBox(width: 12),
              Text(
                'Semua Produk',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [AppColors.gold, Color(0xFFffed4e)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Temukan produk terbaik dari UMKM Indramayu',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSearchSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cari Produk',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              onChanged: _filterProducts,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Ketik nama produk atau deskripsi...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                prefixIcon: Icon(Icons.search,
                    color: Colors.white.withOpacity(0.7), size: 24),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_filteredProduk.length} produk ditemukan',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Produk produk) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween(begin: 1.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          color: const Color(0xFF1E1E2E).withOpacity(0.7),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              _showProductDetail(produk);
            },
            onHover: (hovered) {
              // Efek hover bisa ditambahkan di sini
            },
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Product Image
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
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
                            ? const Center(
                                child: Icon(Icons.image,
                                    color: Colors.grey, size: 40),
                              )
                            : null,
                      ),
                    ),

                    // Product Content
                    Expanded(
                      flex: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              produk.nama,
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),

                            // Product Description
                            if (produk.deskripsi != null)
                              Text(
                                produk.deskripsi!,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 11,
                                  height: 1.5,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),

                            const Spacer(),

                            // Product Price
                            _buildProductPrice(produk),

                            const SizedBox(height: 8),

                            // Add to Cart Button
                            _buildAddToCartButton(produk),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Discount Badge
                if (produk.adaDiskon)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFdc3545), Color(0xFFc82333)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${produk.diskon!.persenDiskon}% OFF',
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
          ),
        ),
      ),
    );
  }

  Widget _buildProductPrice(Produk produk) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (produk.adaDiskon)
          Row(
            children: [
              Text(
                'Rp ${produk.harga.toStringAsFixed(0)}',
                style: TextStyle(
                  color: const Color(0xFFf8d7da),
                  fontSize: 11,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ),
        Text(
          'Rp ${produk.hargaSetelahDiskon.toStringAsFixed(0)}',
          style: TextStyle(
            color: produk.adaDiskon ? const Color(0xFFffed4e) : AppColors.gold,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(Produk produk) {
    return Container(
      width: double.infinity,
      height: 36,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gold, Color(0xFFffed4e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            _addToCart(produk);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(FontAwesomeIcons.cartPlus,
                  color: AppColors.darkBlue, size: 12),
              const SizedBox(width: 6),
              Text(
                'Tambah ke Keranjang',
                style: TextStyle(
                  color: AppColors.darkBlue,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(FontAwesomeIcons.search, color: AppColors.gold, size: 48),
          const SizedBox(height: 16),
          Text(
            'Tidak ada produk ditemukan',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Silakan coba dengan kata kunci lain atau lihat kategori yang berbeda.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Pagination Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Previous Button
              _buildPaginationButton(
                icon: FontAwesomeIcons.chevronLeft,
                isEnabled: _currentPage > 1,
                onTap:
                    _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
              ),

              const SizedBox(width: 8),

              // Page Numbers
              ..._buildPageNumbers(),

              const SizedBox(width: 8),

              // Next Button
              _buildPaginationButton(
                icon: FontAwesomeIcons.chevronRight,
                isEnabled: _currentPage < _totalPages,
                onTap: _currentPage < _totalPages
                    ? () => _goToPage(_currentPage + 1)
                    : null,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Pagination Info
          Text(
            'Menampilkan ${_getStartIndex()} - ${_getEndIndex()} dari ${_filteredProduk.length} produk',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isEnabled
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.02),
        border: Border.all(
          color: isEnabled
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Center(
            child: Icon(
              icon,
              color: isEnabled
                  ? Colors.white.withOpacity(0.7)
                  : Colors.white.withOpacity(0.3),
              size: 12,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    final List<Widget> pages = [];
    final int current = _currentPage;
    final int last = _totalPages;
    final int start = math.max(1, current - 2);
    final int end = math.min(last, current + 2);

    // First page
    if (start > 1) {
      pages.add(_buildPageNumber(1));
      if (start > 2) {
        pages.add(const Text('...', style: TextStyle(color: Colors.white70)));
      }
    }

    // Page numbers
    for (int i = start; i <= end; i++) {
      pages.add(_buildPageNumber(i));
    }

    // Last page
    if (end < last) {
      if (end < last - 1) {
        pages.add(const Text('...', style: TextStyle(color: Colors.white70)));
      }
      pages.add(_buildPageNumber(last));
    }

    return pages;
  }

  Widget _buildPageNumber(int page) {
    final isActive = page == _currentPage;
    return Container(
      width: 36,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        gradient: isActive
            ? const LinearGradient(
                colors: [AppColors.gold, Color(0xFFffed4e)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isActive ? null : Colors.white.withOpacity(0.05),
        border: Border.all(
          color: isActive ? AppColors.gold : Colors.white.withOpacity(0.1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _goToPage(page),
          child: Center(
            child: Text(
              page.toString(),
              style: TextStyle(
                color: isActive
                    ? AppColors.darkBlue
                    : Colors.white.withOpacity(0.7),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
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

  void _goToPage(int page) {
    setState(() {
      _currentPage = page;
    });
    // Scroll ke atas ketika pindah halaman
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  int _getStartIndex() {
    return ((_currentPage - 1) * _itemsPerPage) + 1;
  }

  int _getEndIndex() {
    final end = _currentPage * _itemsPerPage;
    return end > _filteredProduk.length ? _filteredProduk.length : end;
  }

  void _showProductDetail(Produk produk) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              produk.nama,
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (produk.deskripsi != null)
              Text(
                produk.deskripsi!,
                style: const TextStyle(color: Colors.white70),
              ),
            const SizedBox(height: 12),
            Text(
              'Rp ${produk.hargaSetelahDiskon.toStringAsFixed(0)}',
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.darkBlue,
            ),
            onPressed: () {
              _addToCart(produk);
              Navigator.of(context).pop();
            },
            child: const Text('Tambah ke Keranjang'),
          ),
        ],
      ),
    );
  }

  void _addToCart(Produk produk) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.addToKeranjang(produk, 1).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${produk.nama} ditambahkan ke keranjang'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan ke keranjang: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
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