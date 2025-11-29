import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:umkm_indramayu_mobile/constants/colors.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

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
                FontAwesomeIcons.infoCircle,
                color: AppColors.gold,
                size: 28,
              ),
              const SizedBox(width: 12),
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.gold, AppColors.goldLight],
                ).createShader(bounds),
                child: const Text(
                  'Tentang Platform',
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

          // Description
          const Column(
            children: [
              _AboutPoint(
                icon: FontAwesomeIcons.checkCircle,
                text: 'Platform ini dibuat untuk memajukan UMKM di Indramayu '
                    'melalui digitalisasi penjualan produk lokal.',
              ),
              SizedBox(height: 16),
              _AboutPoint(
                icon: FontAwesomeIcons.checkCircle,
                text: 'Dengan fitur katalog online, pembeli dan penjual dapat '
                    'terhubung dengan mudah, efisien, dan aman.',
              ),
              SizedBox(height: 16),
              _AboutPoint(
                icon: FontAwesomeIcons.checkCircle,
                text: 'Kami berkomitmen untuk mengembangkan ekonomi lokal dan '
                    'memberdayakan UMKM Indramayu.',
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Map Placeholder
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: AppColors.gold, width: 2),
              color: AppColors.darkBlue,
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.mapLocationDot,
                  color: AppColors.gold,
                  size: 50,
                ),
                SizedBox(height: 12),
                Text(
                  'Indramayu, Jawa Barat',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutPoint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _AboutPoint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColors.gold,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textGrey,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
