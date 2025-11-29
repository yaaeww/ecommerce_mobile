import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../providers/app_provider.dart';

class CategorySection extends StatelessWidget {
  final List<Kategori> kategoris;
  final Function(Kategori) onCategoryTap;

  const CategorySection({
    super.key,
    required this.kategoris,
    required this.onCategoryTap,
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
              const Icon(
                FontAwesomeIcons.layerGroup,
                color: AppColors.gold,
                size: 28,
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight],
                ).createShader(bounds),
                child: const Text(
                  'Kategori Produk',
                  style: TextStyle(
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

          // Categories List
          kategoris.isEmpty
              ? _buildLoadingState()
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: kategoris.length,
                  itemBuilder: (context, index) {
                    return _buildCategoryItem(kategoris[index]);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Kategori kategori) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.mediumBlue.withOpacity(0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gold.withOpacity(0.2)),
      ),
      child: ExpansionTile(
        leading: const Icon(
          FontAwesomeIcons.folderOpen,
          color: AppColors.gold,
        ),
        title: Text(
          kategori.nama,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Image
                if (kategori.gambar != null)
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.darkBlue,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: ApiService.getImageUrl(kategori.gambar),
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.darkBlue,
                          child: const Icon(
                            FontAwesomeIcons.image,
                            color: AppColors.gold,
                            size: 50,
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppColors.darkBlue,
                          child: const Icon(
                            FontAwesomeIcons.image,
                            color: AppColors.gold,
                            size: 50,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Subcategories
                if (kategori.subkategoris != null &&
                    kategori.subkategoris!.isNotEmpty) ...[
                  const Text(
                    'Subkategori:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: kategori.subkategoris!.map((sub) {
                      return Chip(
                        label: Text(
                          sub.nama,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: AppColors.gold.withOpacity(0.2),
                        labelStyle: const TextStyle(color: AppColors.goldLight),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Products
                if (kategori.produks != null &&
                    kategori.produks!.isNotEmpty) ...[
                  const Text(
                    'Produk Terkait:',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: kategori.produks!.take(3).length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(kategori.produks![index]);
                      },
                    ),
                  ),
                ] else
                  const Center(
                    child: Text(
                      'Tidak ada produk pada kategori ini.',
                      style: TextStyle(color: AppColors.textGrey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Produk product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: AppColors.mediumBlue.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: AppColors.gold.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            // Product Image
            Container(
              height: 100,
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
                  const SizedBox(height: 4),

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

                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // View product details
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
                        Icon(FontAwesomeIcons.eye, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Lihat Detail',
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
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.gold),
          SizedBox(height: 16),
          Text(
            'Memuat kategori...',
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
