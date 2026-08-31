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
import 'checkout_screen.dart'; // Import halaman checkout

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _starController;
  final List<Star> _stars = [];
  List<Keranjang> _keranjangItems = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _initializeStars();
    _loadCartData();
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

  Future<void> _loadCartData() async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      await provider.loadKeranjang();

      setState(() {
        _keranjangItems = provider.keranjang;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading cart data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  double _calculateSubtotal(Keranjang item) {
    final produk = item.produk;
    if (produk == null) return 0.0;

    if (produk.adaDiskon) {
      return produk.hargaSetelahDiskon * item.jumlah;
    } else {
      return produk.harga * item.jumlah;
    }
  }

  double _getTotalPrice() {
    return _keranjangItems.fold(
        0, (total, item) => total + _calculateSubtotal(item));
  }

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
                    // Navbar sebagai SliverAppBar
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
                        currentRoute: '/customer-cart',
                      ),
                    ),

                    // Page Header
                    SliverToBoxAdapter(
                      child: _buildPageHeader(),
                    ),

                    // Error Message (jika ada)
                    if (_errorMessage != null)
                      SliverToBoxAdapter(
                        child: _buildErrorMessage(),
                      ),

                    // Cart Items
                    if (_keranjangItems.isNotEmpty)
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              _buildCartItem(_keranjangItems[index]),
                          childCount: _keranjangItems.length,
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: _buildEmptyState(),
                      ),

                    // Checkout Section (jika ada items)
                    if (_keranjangItems.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildCheckoutSection(),
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
              'Memuat Keranjang...',
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
              Icon(FontAwesomeIcons.shoppingCart,
                  color: AppColors.gold, size: 24),
              const SizedBox(width: 12),
              Text(
                'Keranjang Belanja',
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
            'Kelola produk dalam keranjang belanja Anda',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFdc3545).withOpacity(0.2),
        border: Border.all(color: const Color(0xFFdc3545).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.exclamationTriangle,
              color: Colors.white, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(Keranjang item) {
    final produk = item.produk;

    if (produk == null) {
      return _buildInvalidCartItem(item);
    }

    final hasDiscount = produk.adaDiskon;
    final isOutOfStock = item.jumlah > produk.stok;
    final hargaSetelahDiskon =
        hasDiscount ? produk.hargaSetelahDiskon : produk.harga;
    final subtotal = _calculateSubtotal(item);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
                    ? const Icon(Icons.image, color: Colors.grey, size: 24)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produk.nama,
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Discount Badge
                    if (hasDiscount && produk.diskon != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFdc3545), Color(0xFFc82333)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.tag,
                                color: Colors.white, size: 10),
                            const SizedBox(width: 4),
                            Text(
                              'Diskon ${produk.diskon!.persenDiskon}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Stock Warning
                    if (isOutOfStock)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFffc107).withOpacity(0.2),
                          border: Border.all(color: const Color(0xFFffc107)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(FontAwesomeIcons.exclamationTriangle,
                                color: const Color(0xFFffc107), size: 10),
                            const SizedBox(width: 4),
                            Text(
                              'Stok kurang! (Tersedia: ${produk.stok})',
                              style: TextStyle(
                                color: const Color(0xFFffc107),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Price and Quantity Section
          Row(
            children: [
              // Price Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Original Price (if discounted)
                    if (hasDiscount)
                      Text(
                        'Rp ${produk.harga.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    // Current Price
                    Text(
                      'Rp ${hargaSetelahDiskon.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: hasDiscount
                            ? const Color(0xFF28a745)
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Quantity Controls
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Decrease Button
                    IconButton(
                      icon: Icon(Icons.remove, color: Colors.white, size: 16),
                      onPressed: () {
                        _updateQuantity(item, item.jumlah - 1);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    // Quantity Display
                    Text(
                      item.jumlah.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 8),
                    // Increase Button
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.white, size: 16),
                      onPressed: () {
                        _updateQuantity(item, item.jumlah + 1);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Subtotal
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasDiscount)
                    Text(
                      'Rp ${(produk.harga * item.jumlah).toStringAsFixed(0)}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  Text(
                    'Rp ${subtotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Action Buttons
          Row(
            children: [
              // Remove Button
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFdc3545), Color(0xFFc82333)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        _showDeleteConfirmation(item);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.trash,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 6),
                          Text(
                            'Hapus',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Checkout Button
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: isOutOfStock
                        ? null
                        : const LinearGradient(
                            colors: [Color(0xFF28a745), Color(0xFF1e7e34)],
                          ),
                    color: isOutOfStock ? Colors.white.withOpacity(0.1) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: isOutOfStock
                          ? () {
                              _showStockWarning(produk.stok);
                            }
                          : () {
                              _checkoutItem(item);
                            },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(FontAwesomeIcons.creditCard,
                              color: isOutOfStock
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white,
                              size: 12),
                          const SizedBox(width: 6),
                          Text(
                            'Checkout',
                            style: TextStyle(
                              color: isOutOfStock
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidCartItem(Keranjang item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.exclamationTriangle,
              color: Colors.red, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Produk tidak tersedia',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID Produk: ${item.produkId}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.trash, color: Colors.red, size: 16),
            onPressed: () {
              _showDeleteConfirmation(item);
            },
          ),
        ],
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
          Icon(FontAwesomeIcons.shoppingCart, color: AppColors.gold, size: 48),
          const SizedBox(height: 16),
          Text(
            'Keranjang kamu kosong',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yuk, tambahkan produk favoritmu ke keranjang!',
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

  Widget _buildCheckoutSection() {
    final totalPrice = _getTotalPrice();
    final hasOutOfStockItems = _keranjangItems.any((item) {
      final produk = item.produk;
      return produk != null && item.jumlah > produk.stok;
    });

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          // Total Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Belanja:',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 16,
                ),
              ),
              Text(
                'Rp ${totalPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Checkout All Button
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: hasOutOfStockItems
                  ? null
                  : const LinearGradient(
                      colors: [AppColors.gold, Color(0xFFffed4e)],
                    ),
              color: hasOutOfStockItems ? Colors.white.withOpacity(0.1) : null,
              borderRadius: BorderRadius.circular(12),
              boxShadow: hasOutOfStockItems
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: hasOutOfStockItems
                    ? () {
                        _showGeneralStockWarning();
                      }
                    : () {
                        _checkoutAll();
                      },
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.creditCard,
                          color: hasOutOfStockItems
                              ? Colors.white.withOpacity(0.5)
                              : AppColors.darkBlue,
                          size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Checkout Semua',
                        style: TextStyle(
                          color: hasOutOfStockItems
                              ? Colors.white.withOpacity(0.5)
                              : AppColors.darkBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
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

  // PERBAIKAN: Update quantity dengan API
  void _updateQuantity(Keranjang item, int newQuantity) {
    if (newQuantity < 1) {
      _deleteItem(item);
      return;
    }

    if (item.produk != null && newQuantity > item.produk!.stok) {
      _showStockWarning(item.produk!.stok);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    ApiService.updateCart(item.id, newQuantity).then((_) {
      // Reload cart data
      _loadCartData();
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal mengupdate jumlah: $error';
      });
    });
  }

  void _showDeleteConfirmation(Keranjang item) {
    final produkName = item.produk?.nama ?? 'Produk';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          'Hapus Produk',
          style: TextStyle(color: AppColors.gold),
        ),
        content: Text(
          'Hapus $produkName dari keranjang?',
          style: const TextStyle(color: Colors.white70),
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
            onPressed: () {
              Navigator.of(context).pop();
              _deleteItem(item);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteItem(Keranjang item) {
    setState(() {
      _isLoading = true;
    });

    ApiService.removeFromCart(item.id).then((_) {
      // Reload cart data
      _loadCartData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('${item.produk?.nama ?? 'Produk'} dihapus dari keranjang'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal menghapus produk: $error';
      });
    });
  }

  void _showStockWarning(int availableStock) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          'Stok Tidak Mencukupi',
          style: TextStyle(color: AppColors.gold),
        ),
        content: Text(
          'Stok tidak mencukupi untuk checkout. Stok tersedia: $availableStock',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showGeneralStockWarning() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        title: Text(
          'Stok Tidak Mencukupi',
          style: TextStyle(color: AppColors.gold),
        ),
        content: const Text(
          'Beberapa produk dalam keranjang memiliki stok yang tidak mencukupi. Silakan periksa jumlah pesanan atau hapus produk dari keranjang.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ========== PERUBAHAN PENTING ==========
  // Method untuk navigasi ke CheckoutScreen
  void _checkoutItem(Keranjang item) {
    final produk = item.produk;
    if (produk == null) return;

    // Navigate menggunakan Navigator.push bukan pushNamed
    // karena kita perlu mengirim data langsung ke constructor
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(
          produk: produk,
          quantity: item.jumlah,
        ),
      ),
    );
  }

  void _checkoutAll() {
    // Filter hanya produk yang stoknya mencukupi
    final validItems = _keranjangItems.where((item) {
      final produk = item.produk;
      return produk != null && item.jumlah <= produk.stok;
    }).toList();

    if (validItems.isEmpty) {
      _showGeneralStockWarning();
      return;
    }

    // NOTE: Untuk sekarang, checkout satu produk dulu
    // Nanti bisa dikembangkan untuk multi-checkout
    if (validItems.isNotEmpty) {
      _checkoutItem(validItems.first);
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });

    // Clear error after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
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
