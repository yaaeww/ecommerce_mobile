import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:umkm_indramayu_mobile/constants/colors.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.darkBlue,
            AppColors.mediumBlue,
            AppColors.lightBlue
          ],
        ),
      ),
      child: Stack(
        children: [
          // Animated Background
          Positioned.fill(
            child: CustomPaint(
              painter: _HeroBackgroundPainter(),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.gold, AppColors.goldLight],
                        ).createShader(bounds),
                        child: const Text(
                          'Digitalisasi UMKM\nIndramayu',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Description
                      const Text(
                        'Platform modern untuk memajukan produk lokal UMKM Indramayu melalui katalog online yang mudah, efisien, dan terpercaya.',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textGrey,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Buttons
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              // Scroll to products
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: AppColors.darkBlue,
                              elevation: 6,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FontAwesomeIcons.rocket, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Jelajahi Produk',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          TextButton(
                            onPressed: () {
                              // Show about dialog
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.gold,
                            ),
                            child: const Row(
                              children: [
                                Icon(FontAwesomeIcons.playCircle, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Pelajari Lebih Lanjut',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Illustration (hidden on small screens)
                if (MediaQuery.of(context).size.width > 800)
                  Expanded(
                    child: Center(
                      child: _buildCartoonIllustration(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartoonIllustration() {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.gold.withOpacity(0.1),
      ),
      child: Stack(
        children: [
          // Seller Avatar
          Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                FontAwesomeIcons.store,
                color: AppColors.darkBlue,
                size: 50,
              ),
            ),
          ),

          // Floating Products
          Positioned(
            top: 50,
            left: 50,
            child: _buildFloatingProduct(Icons.shopping_bag, Colors.red),
          ),
          Positioned(
            top: 50,
            right: 50,
            child: _buildFloatingProduct(Icons.eco, Colors.green),
          ),
          Positioned(
            bottom: 50,
            left: 80,
            child:
                _buildFloatingProduct(Icons.emoji_food_beverage, Colors.yellow),
          ),
          Positioned(
            bottom: 50,
            right: 80,
            child: _buildFloatingProduct(Icons.handyman, Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingProduct(IconData icon, Color color) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}

class _HeroBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Draw circles for background effect
    canvas.drawCircle(
      Offset(size.width * 0.2, size.height * 0.5),
      size.width * 0.3,
      paint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.8),
      size.width * 0.2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
