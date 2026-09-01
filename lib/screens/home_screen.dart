import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../widgets/product_card.dart';
import '../widgets/category_section.dart';
import '../widgets/hero_section.dart';
import 'customer/product_detail_screen.dart';

/// Modern HomeScreen (Tab 1: Beranda)
/// Professional Agricultural E-Commerce — Clean, Synchronized & Ergonomic
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterIndex = 0;
  final List<String> _filterOptions = ['Semua', 'Terbaru', 'Diskon', 'Stok Tersedia'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<AppProvider>(context, listen: false).loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Produk> _getFilteredProducts(List<Produk> allProducts) {
    var list = allProducts;
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) => p.nama.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    switch (_selectedFilterIndex) {
      case 1: // Terbaru
        return list;
      case 2: // Diskon
        return list.where((p) => p.adaDiskon).toList();
      case 3: // Stok Tersedia
        return list.where((p) => p.stok > 0).toList();
      default:
        return list;
    }
  }

  void _handleAddToCart(BuildContext context, Produk produk) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Silakan login untuk belanja'),
            ],
          ),
          backgroundColor: AppColors.textDark,
          action: SnackBarAction(
            label: 'Login',
            textColor: AppColors.mango,
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      await provider.tambahKeKeranjang(produk.id, 1);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('${produk.nama} ditambahkan ke keranjang!'),
                ),
              ],
            ),
            backgroundColor: AppColors.emerald,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambah ke keranjang: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(108),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Top Row: Location & Cart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand & Location
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.lemon,
                              color: AppColors.emerald,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Juragan Pelem Indramayu',
                                style: TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 11, color: AppColors.emerald),
                                  const SizedBox(width: 2),
                                  Text(
                                    'Indramayu, Jawa Barat',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Action Icons
                      Row(
                        children: [
                          // Cart Icon with Dynamic Badge
                          Consumer<AppProvider>(
                            builder: (context, provider, _) {
                              final total = provider.totalCartItems;
                              return Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      FontAwesomeIcons.bagShopping,
                                      size: 18,
                                      color: AppColors.textDark,
                                    ),
                                    onPressed: () => Navigator.pushNamed(context, '/customer-cart'),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                                  ),
                                  if (total > 0)
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDC2626),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.white, width: 1.5),
                                        ),
                                        child: Text(
                                          total > 99 ? '99+' : '$total',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    ],
                  ),
                  // Search Input Box
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(fontSize: 13, color: AppColors.textDark),
                      decoration: InputDecoration(
                        hintText: 'Cari mangga segar, olahan UMKM...',
                        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF64748B)),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.emerald,
        onRefresh: () async {
          await Provider.of<AppProvider>(context, listen: false).loadInitialData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promo Banner Carousel
              const HeroSection(),

              // Category Section (Horizontal Scrollable Chips)
              Consumer<AppProvider>(
                builder: (context, provider, _) {
                  return CategorySection(
                    kategoris: provider.kategoris,
                    onCategoryTap: (kategori) {
                      setState(() {
                        _searchController.text = kategori.nama;
                        _searchQuery = kategori.nama;
                      });
                    },
                  );
                },
              ),

              // Flash Sale / Penawaran Panen Section
              _buildSpecialHarvestSection(context),

              // Filter Chips Toolbar
              _buildFilterChipsToolbar(),

              // Product Grid Section
              _buildProductGridSection(context),

              // Bottom Spacing
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialHarvestSection(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final promoProducts = provider.produksTerbaru.where((p) => p.adaDiskon || p.stok > 0).take(4).toList();
        if (promoProducts.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFEF3C7), Color(0xFFFFFBEB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt, color: Color(0xFFD97706), size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Spesial Panen Pekan Ini',
                        style: TextStyle(
                          color: Color(0xFF92400E),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PILIHAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: promoProducts.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final produk = promoProducts[index];
                    return ProductCard(
                      produk: produk,
                      compact: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(produk: produk),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChipsToolbar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.emerald,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Semua Produk UMKM',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(_filterOptions.length, (index) {
                final isSelected = _selectedFilterIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_filterOptions[index]),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedFilterIndex = index);
                    },
                    selectedColor: AppColors.emerald,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.emerald : const Color(0xFFE2E8F0),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGridSection(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final products = _getFilteredProducts(provider.produksTerbaru);

        if (products.isEmpty) {
          return provider.isLoading ? _buildShimmerGrid() : _buildEmptyState();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.60,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final produk = products[index];
              return ProductCard(
                produk: produk,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(produk: produk),
                    ),
                  );
                },
                onAddToCart: () => _handleAddToCart(context, produk),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildShimmerGrid() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.60,
        ),
        itemCount: 4,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 10, width: 60, color: const Color(0xFFF1F5F9)),
                    const SizedBox(height: 6),
                    Container(height: 14, width: double.infinity, color: const Color(0xFFF1F5F9)),
                    const SizedBox(height: 8),
                    Container(height: 14, width: 80, color: const Color(0xFFF1F5F9)),
                  ],
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
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 40, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tidak ada produk ditemukan',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Coba ubah kata kunci atau filter pencarian Anda',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
