import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../providers/app_provider.dart';

class ProductSection extends StatelessWidget {
  final List<Produk> produks;
  final String title;
  final VoidCallback? onAddToCart; // Tambahkan parameter ini

  const ProductSection({
    super.key,
    required this.produks,
    required this.title,
    this.onAddToCart, // Tambahkan parameter ini di constructor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBlue.withOpacity(0.7),
            AppColors.mediumBlue.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                title == 'Produk Terbaru'
                    ? FontAwesomeIcons.star
                    : FontAwesomeIcons.box,
                color: AppColors.gold,
                size: 28,
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight],
                ).createShader(bounds),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: 100,
            height: 4,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.gold, AppColors.goldLight],
              ),
              borderRadius: BorderRadius.circular(2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Products Grid
          produks.isEmpty
              ? _buildEmptyState()
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: produks.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(produks[index], context);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Produk product, BuildContext context) {
    return Card(
      color: AppColors.mediumBlue.withOpacity(0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          // Product Image dengan badge diskon
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: AppColors.darkBlue,
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: product.gambar != null
                      ? CachedNetworkImage(
                          imageUrl: ApiService.getImageUrl(product.gambar),
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.darkBlue,
                            child: const Icon(
                              FontAwesomeIcons.box,
                              color: AppColors.gold,
                              size: 40,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.darkBlue,
                            child: const Icon(
                              FontAwesomeIcons.box,
                              color: AppColors.gold,
                              size: 40,
                            ),
                          ),
                        )
                      : Container(
                          color: AppColors.darkBlue,
                          child: const Icon(
                            FontAwesomeIcons.box,
                            color: AppColors.gold,
                            size: 40,
                          ),
                        ),
                ),
              ),
              if (product.adaDiskon)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${product.diskon!.persenDiskon}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (product.rating != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          FontAwesomeIcons.solidStar,
                          color: AppColors.darkBlue,
                          size: 10,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          product.rating!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: AppColors.darkBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          // Product Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nama,
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                // Harga dengan diskon
                if (product.adaDiskon)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rp${product.harga.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.textGrey,
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        'Rp${product.hargaSetelahDiskon.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'Rp${product.harga.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),

                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Panggil onAddToCart jika tersedia, jika tidak arahkan ke login
                    if (onAddToCart != null) {
                      onAddToCart!();
                    } else {
                      Navigator.pushNamed(context, '/login');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: AppColors.darkBlue,
                    minimumSize: const Size(double.infinity, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.shoppingCart, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'Beli Sekarang',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
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
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.boxOpen,
            color: AppColors.textGrey.withOpacity(0.5),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada produk tersedia saat ini.',
            style: TextStyle(
              color: AppColors.textGrey,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}