import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../models/models.dart';

/// Enterprise-grade ProductCard for Grid and Horizontal Feeds
class ProductCard extends StatelessWidget {
  final Produk produk;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool compact;

  const ProductCard({
    super.key,
    required this.produk,
    this.onTap,
    this.onAddToCart,
    this.compact = false,
  });

  String _formatRupiah(num number) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  @override
  Widget build(BuildContext context) {
    final hasDiscount = produk.adaDiskon;
    final hargaDiskon = hasDiscount ? produk.hargaSetelahDiskon : produk.harga;
    final isLowStock = produk.stok <= 5 && produk.stok > 0;

    if (compact) return _buildCompact(context, hasDiscount, hargaDiskon, isLowStock);
    return _buildGrid(context, hasDiscount, hargaDiskon, isLowStock);
  }

  Widget _buildGrid(BuildContext context, bool hasDiscount, double hargaDiskon, bool isLowStock) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with Overlays
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      color: const Color(0xFFF1F5F9),
                      child: produk.gambar != null && produk.gambar!.isNotEmpty
                          ? Image.network(
                              produk.gambar!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildImageFallback(),
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.emerald),
                                  ),
                                );
                              },
                            )
                          : _buildImageFallback(),
                    ),
                  ),
                  // Discount Badge
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626),
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Text(
                          '-${produk.diskon!.persenDiskon}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  // Fresh / Best Seller Badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),

              // Product Info Body
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Toko UMKM Tag
                    Row(
                      children: [
                        const Icon(Icons.verified, size: 12, color: AppColors.emerald),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'UMKM Indramayu',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      produk.nama,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Price Section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatRupiah(hargaDiskon),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.emerald,
                          ),
                        ),
                      ],
                    ),
                    if (hasDiscount)
                      Text(
                        _formatRupiah(produk.harga),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade400,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Rating & Add to Cart Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 2),
                            Text(
                              produk.rating != null ? produk.rating!.toStringAsFixed(1) : '4.9',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              ' (20+)',
                              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                        // Add Button
                        GestureDetector(
                          onTap: onAddToCart,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.emerald,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.add_shopping_cart,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context, bool hasDiscount, double hargaDiskon, bool isLowStock) {
    return Container(
      width: 155,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.8)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  height: 100,
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: produk.gambar != null && produk.gambar!.isNotEmpty
                      ? Image.network(
                          produk.gambar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImageFallback(),
                        )
                      : _buildImageFallback(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produk.nama,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatRupiah(hargaDiskon),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: const Color(0xFFECFDF5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.lemon,
              color: Color(0xFF059669),
              size: 32,
            ),
            SizedBox(height: 4),
            Text(
              'Pelem Indramayu',
              style: TextStyle(
                color: Color(0xFF059669),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
