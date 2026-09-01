import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../constants/colors.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';
import 'cart_screen.dart';

/// Enterprise-grade Product Detail Screen
/// Includes rich gallery, pricing, store badge, guarantee highlights, reviews & sticky CTA
class ProductDetailScreen extends StatefulWidget {
  final Produk produk;

  const ProductDetailScreen({
    super.key,
    required this.produk,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;

  String _formatRupiah(num number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  void _handleAddToCart(BuildContext context, {bool navigateToCart = false}) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Silakan login terlebih dahulu untuk belanja'),
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
      await provider.tambahKeKeranjang(widget.produk.id, _quantity);
      if (mounted) {
        if (navigateToCart) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CartScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_quantity x ${widget.produk.nama} berhasil dimasukkan ke keranjang!',
                    ),
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

  void _showQuantityBottomSheet(BuildContext context, {required bool isBuyNow}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final hasDiscount = widget.produk.adaDiskon;
            final unitPrice = hasDiscount
                ? widget.produk.hargaSetelahDiskon
                : widget.produk.harga;
            final totalPrice = unitPrice * _quantity;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mini Product Row
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 64,
                          height: 64,
                          color: const Color(0xFFF1F5F9),
                          child: widget.produk.gambar != null &&
                                  widget.produk.gambar!.isNotEmpty
                              ? Image.network(
                                  widget.produk.gambar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _buildImagePlaceholder(),
                                )
                              : _buildImagePlaceholder(),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _formatRupiah(unitPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.emerald,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stok Tersedia: ${widget.produk.stok} unit',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),

                  // Quantity Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jumlah Pesanan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: _quantity > 1
                                  ? () {
                                      setModalState(() => _quantity--);
                                      setState(() {});
                                    }
                                  : null,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            Container(
                              constraints: const BoxConstraints(minWidth: 32),
                              alignment: Alignment.center,
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: _quantity < widget.produk.stok
                                  ? () {
                                      setModalState(() => _quantity++);
                                      setState(() {});
                                    }
                                  : null,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Total & Confirm CTA
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Harga',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            _formatRupiah(totalPrice),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.emerald,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleAddToCart(
                              context,
                              navigateToCart: isBuyNow,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emerald,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            isBuyNow ? 'Lanjut ke Keranjang' : 'Tambah ke Keranjang',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = widget.produk.adaDiskon;
    final hargaDiskon = hasDiscount
        ? widget.produk.hargaSetelahDiskon
        : widget.produk.harga;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Sleek Sliver App Bar with Hero Image
          _buildSliverAppBar(context, hasDiscount),

          // 2. Main Product Details Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price & Title Card
                _buildPriceAndTitleCard(hasDiscount, hargaDiskon),

                // Toko UMKM Card
                _buildStoreCard(),

                // Guarantee Highlights
                _buildGuaranteeSection(),

                // Description Section
                _buildDescriptionSection(),

                // Specifications Section
                _buildSpecificationsSection(),

                // Customer Reviews Section
                _buildReviewsSection(),

                // Spacing for Bottom Bar
                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomBar(context, hargaDiskon),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, bool hasDiscount) {
    return SliverAppBar(
      expandedHeight: 320,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.9),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: AppColors.textDark,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.9),
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : AppColors.textDark,
                size: 20,
              ),
              onPressed: () => setState(() => _isFavorite = !_isFavorite),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Consumer<AppProvider>(
            builder: (context, provider, _) {
              final total = provider.totalCartItems;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    child: IconButton(
                      icon: const Icon(
                        FontAwesomeIcons.bagShopping,
                        size: 16,
                        color: AppColors.textDark,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      ),
                    ),
                  ),
                  if (total > 0)
                    Positioned(
                      top: 2,
                      right: 2,
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
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              color: const Color(0xFFF1F5F9),
              child: widget.produk.gambar != null && widget.produk.gambar!.isNotEmpty
                  ? Image.network(
                      widget.produk.gambar!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
            // Discount Tag Overlay
            if (hasDiscount)
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    'DISKON ${widget.produk.diskon!.persenDiskon}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceAndTitleCard(bool hasDiscount, double hargaDiskon) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _formatRupiah(hargaDiskon),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.emerald,
                ),
              ),
              if (hasDiscount) ...[
                const SizedBox(width: 8),
                Text(
                  _formatRupiah(widget.produk.harga),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            widget.produk.nama,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 12),

          // Rating, Sold, & Stock Pill Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text(
                      widget.produk.rating != null
                          ? widget.produk.rating!.toStringAsFixed(1)
                          : '4.9',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(48 Ulasan)',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '120+ Terjual',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const Spacer(),
              // Stock indicator
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.produk.stok > 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.produk.stok > 0
                        ? 'Stok: ${widget.produk.stok}'
                        : 'Stok Habis',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.produk.stok > 0
                          ? const Color(0xFF047857)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStoreCard() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Icon(
              FontAwesomeIcons.store,
              color: AppColors.emerald,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text(
                      'Toko UMKM Indramayu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.verified, size: 14, color: AppColors.emerald),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '📍 Indramayu, Jawa Barat • Respon Cepat',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil toko UMKM dibuka')),
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.emerald,
              side: const BorderSide(color: AppColors.emerald),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              minimumSize: const Size(60, 32),
            ),
            child: const Text('Kunjungi', style: TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  Widget _buildGuaranteeSection() {
    final guarantees = [
      {'icon': FontAwesomeIcons.shieldHalved, 'title': 'Garansi Buah Segar', 'desc': 'Kualitas terbaik langsung petik'},
      {'icon': FontAwesomeIcons.truckFast, 'title': 'Pengiriman Aman', 'desc': 'Packing kardus buah khusus'},
      {'icon': FontAwesomeIcons.leaf, 'title': '100% Asli Dermayu', 'desc': 'Produk petani lokal terpercaya'},
    ];

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keunggulan Layanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: guarantees.map((item) {
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 18,
                        color: AppColors.emerald,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['title'] as String,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item['desc'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final desc = widget.produk.deskripsi != null && widget.produk.deskripsi!.isNotEmpty
        ? widget.produk.deskripsi!
        : 'Mangga asli Indramayu pilihan kualitas super. Memiliki rasa manis yang khas, aroma harum memikat, serta daging buah tebal berserat halus. Dipetik langsung dari kebun binaan UMKM terpercaya di Indramayu.';

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi Produk',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF334155),
              height: 1.5,
            ),
            maxLines: _isDescriptionExpanded ? null : 4,
            overflow: _isDescriptionExpanded ? null : TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded),
            child: Text(
              _isDescriptionExpanded ? 'Tutup Deskripsi' : 'Lihat Selengkapnya',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.emerald,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecificationsSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spesifikasi Produk',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          _buildSpecRow('Kondisi', 'Baru / Segar'),
          _buildSpecRow('Min. Pemesanan', '1 Unit'),
          _buildSpecRow('Asal Daerah', 'Indramayu, Jawa Barat'),
          _buildSpecRow('Kategori ID', '${widget.produk.kategoriProdukId}'),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ulasan Pembeli',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                'Lihat Semua (48)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSingleReview(
            'Budi Santoso',
            5,
            'Mangga gedong gincunya sangat manis dan aromanya harum sekali! Pengiriman cepat dan packing sangat aman.',
            '2 hari lalu',
          ),
          const Divider(height: 20),
          _buildSingleReview(
            'Siti Rahmawati',
            5,
            'Sangat memuaskan! Buahnya segar-segar tidak ada yang busuk. Terima kasih UMKM Indramayu!',
            '1 minggu lalu',
          ),
        ],
      ),
    );
  }

  Widget _buildSingleReview(String name, int rating, String comment, String date) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFD1FAE5),
              child: Text(
                name.substring(0, 1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.emerald,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            Text(date, style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: List.generate(
            rating,
            (_) => const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          comment,
          style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.3),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(BuildContext context, double hargaDiskon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Chat Icon Button
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(
                  FontAwesomeIcons.commentDots,
                  size: 18,
                  color: Color(0xFF475569),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Membuka chat dengan penjual...')),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),

            // + Keranjang Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showQuantityBottomSheet(context, isBuyNow: false),
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('+ Keranjang'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.emerald,
                  side: const BorderSide(color: AppColors.emerald, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),

            // Beli Sekarang CTA
            Expanded(
              child: ElevatedButton(
                onPressed: () => _showQuantityBottomSheet(context, isBuyNow: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.emerald,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Beli Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: const Color(0xFFECFDF5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.lemon,
              color: Color(0xFF059669),
              size: 48,
            ),
            SizedBox(height: 8),
            Text(
              'Pelem Indramayu',
              style: TextStyle(
                color: Color(0xFF059669),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
