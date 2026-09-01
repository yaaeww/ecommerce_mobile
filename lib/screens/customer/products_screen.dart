import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/colors.dart';
import '../../providers/app_provider.dart';
import '../../models/models.dart';
import '../../widgets/product_card.dart';
import 'product_detail_screen.dart';

/// Tab 2: Eksplor / Katalog Produk
/// Modern, clean, responsive catalog screen with search, category filtering & sorting
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int? _selectedCategoryId; // null = Semua Kategori
  String _sortBy = 'terbaru'; // terbaru, termurah, termahal, diskon

  final List<Map<String, String>> _sortOptions = [
    {'key': 'terbaru', 'label': 'Terbaru'},
    {'key': 'termurah', 'label': 'Harga Terendah'},
    {'key': 'termahal', 'label': 'Harga Tertinggi'},
    {'key': 'diskon', 'label': 'Diskon Spesial'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (provider.produks.isEmpty) {
        provider.loadAllProduks();
      }
      if (provider.kategoris.isEmpty) {
        provider.loadKategoris();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Produk> _filterAndSortProducts(List<Produk> allProducts) {
    var list = List<Produk>.from(allProducts);

    // 1. Filter by Search Query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      list = list.where((p) {
        final nameMatch = p.nama.toLowerCase().contains(query);
        final descMatch = p.deskripsi?.toLowerCase().contains(query) ?? false;
        return nameMatch || descMatch;
      }).toList();
    }

    // 2. Filter by Category
    if (_selectedCategoryId != null) {
      list = list.where((p) => p.kategoriId == _selectedCategoryId).toList();
    }

    // 3. Sort
    switch (_sortBy) {
      case 'termurah':
        list.sort((a, b) => a.hargaSetelahDiskon.compareTo(b.hargaSetelahDiskon));
        break;
      case 'termahal':
        list.sort((a, b) => b.hargaSetelahDiskon.compareTo(a.hargaSetelahDiskon));
        break;
      case 'diskon':
        list = list.where((p) => p.adaDiskon).toList();
        list.sort((a, b) => (b.diskon?.persenDiskon ?? 0).compareTo(a.diskon?.persenDiskon ?? 0));
        break;
      case 'terbaru':
      default:
        list.sort((a, b) => b.id.compareTo(a.id));
        break;
    }

    return list;
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
                Expanded(child: Text('${produk.nama} ditambahkan ke keranjang!')),
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
            content: Text('Gagal: $e'),
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
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Search Input Field
                  Expanded(
                    child: Container(
                      height: 42,
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
                          hintText: 'Cari produk, mangga, olahan...',
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                          prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
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
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Sort Filter Button
                  GestureDetector(
                    onTap: _showSortBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Icon(
                        FontAwesomeIcons.sliders,
                        size: 16,
                        color: AppColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Consumer<AppProvider>(
        builder: (context, provider, _) {
          final allProducts = provider.produks.isNotEmpty ? provider.produks : provider.produksTerbaru;
          final filteredProducts = _filterAndSortProducts(allProducts);

          return RefreshIndicator(
            color: AppColors.emerald,
            onRefresh: () async {
              await provider.loadAllProduks();
              await provider.loadKategoris();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                // Category Pills Toolbar
                SliverToBoxAdapter(
                  child: _buildCategoryPills(provider.kategoris),
                ),

                // Active Filter & Results Count Info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filteredProducts.length} Produk Ditemukan',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Urut: ${_getSortLabel()}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Products Grid
                if (filteredProducts.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.60,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final produk = filteredProducts[index];
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
                        childCount: filteredProducts.length,
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: provider.isLoading
                        ? _buildShimmerGrid()
                        : _buildEmptyState(),
                  ),

                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryPills(List<Kategori> kategoris) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(top: 12, bottom: 4),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: kategoris.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = _selectedCategoryId == null;
            return ChoiceChip(
              label: const Text('Semua'),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedCategoryId = null),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            );
          }

          final kategori = kategoris[index - 1];
          final isSelected = _selectedCategoryId == kategori.id;
          return ChoiceChip(
            label: Text(kategori.nama),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedCategoryId = kategori.id),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Urutkan Produk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              ..._sortOptions.map((opt) {
                final isSelected = _sortBy == opt['key'];
                return ListTile(
                  title: Text(
                    opt['label']!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.emerald : AppColors.textDark,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check, color: AppColors.emerald)
                      : null,
                  onTap: () {
                    setState(() => _sortBy = opt['key']!);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  String _getSortLabel() {
    final found = _sortOptions.firstWhere(
      (opt) => opt['key'] == _sortBy,
      orElse: () => {'key': 'terbaru', 'label': 'Terbaru'},
    );
    return found['label']!;
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada produk ditemukan',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Coba atur ulang kata kunci pencarian atau filter kategori Anda',
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedCategoryId = null;
                _sortBy = 'terbaru';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emerald,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Reset Filter'),
          ),
        ],
      ),
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
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
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
                  children: [
                    Container(height: 12, width: double.infinity, color: const Color(0xFFF1F5F9)),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 80, color: const Color(0xFFF1F5F9)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}