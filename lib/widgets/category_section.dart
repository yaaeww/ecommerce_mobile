import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/colors.dart';
import '../models/models.dart';

/// Category section for HomeScreen — modern circular category cards with rich iconography
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
    if (kategoris.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
                    'Kategori Pilihan',
                    style: TextStyle(
                      color: AppColors.textDark,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '${kategoris.length} Kategori',
                style: const TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: kategoris.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final kategori = kategoris[index];
                return _buildCategoryItem(context, kategori, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Kategori kategori, int index) {
    // Curated color palettes & fallback icons for categories
    final colorPresets = [
      {'bg': const Color(0xFFFEF3C7), 'iconColor': const Color(0xFFD97706), 'icon': FontAwesomeIcons.lemon},
      {'bg': const Color(0xFFD1FAE5), 'iconColor': const Color(0xFF059669), 'icon': FontAwesomeIcons.bottleWater},
      {'bg': const Color(0xFFE0E7FF), 'iconColor': const Color(0xFF4F46E5), 'icon': FontAwesomeIcons.seedling},
      {'bg': const Color(0xFFFCE7F3), 'iconColor': const Color(0xFFDB2777), 'icon': FontAwesomeIcons.boxOpen},
      {'bg': const Color(0xFFCFFAFE), 'iconColor': const Color(0xFF0891B2), 'icon': FontAwesomeIcons.shop},
    ];

    final preset = colorPresets[index % colorPresets.length];
    final bg = preset['bg'] as Color;
    final iconColor = preset['iconColor'] as Color;
    final fallbackIcon = preset['icon'] as IconData;

    return GestureDetector(
      onTap: () => onCategoryTap(kategori),
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withOpacity(0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: kategori.gambar != null && kategori.gambar!.isNotEmpty
                    ? Image.network(
                        kategori.gambar!,
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          fallbackIcon,
                          color: iconColor,
                          size: 20,
                        ),
                      )
                    : Icon(
                        fallbackIcon,
                        color: iconColor,
                        size: 20,
                      ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              kategori.nama,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textDark,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
