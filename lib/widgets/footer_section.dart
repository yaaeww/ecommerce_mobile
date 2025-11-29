import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:umkm_indramayu_mobile/constants/colors.dart';

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.darkBlue, AppColors.mediumBlue],
        ),
        border: Border(top: BorderSide(color: AppColors.gold, width: 2)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // Store Icon
          Icon(
            FontAwesomeIcons.store,
            color: AppColors.gold,
            size: 40,
          ),
          const SizedBox(height: 16),

          // Copyright
          Text(
            '© ${DateTime.now().year} UMKM Indramayu - Kelompok 7',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Location
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.locationDot,
                color: AppColors.gold,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Indramayu, Jawa Barat, Indonesia',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Social Media
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSocialIcon(FontAwesomeIcons.facebook),
              const SizedBox(width: 16),
              _buildSocialIcon(FontAwesomeIcons.instagram),
              const SizedBox(width: 16),
              _buildSocialIcon(FontAwesomeIcons.whatsapp),
              const SizedBox(width: 16),
              _buildSocialIcon(FontAwesomeIcons.twitter),
            ],
          ),
          const SizedBox(height: 24),

          // Powered By
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.code,
                color: AppColors.textGrey,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Powered by Flutter & Dart',
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle social media tap
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.gold.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          color: AppColors.gold,
          size: 20,
        ),
      ),
    );
  }
}
