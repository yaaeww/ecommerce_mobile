import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Modern Hero Banner with gradient, badges, and seasonal mango promotion
class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _banners = [
    {
      'badge': '🥭 PANEN RAYA 2026',
      'title': 'Mangga Gedong Gincu Asli Indramayu',
      'subtitle': 'Dipetik langsung dari perkebunan pilihan • Manis & Segar',
      'tag': 'Diskon s/d 30%',
      'bgGradient': [const Color(0xFF047857), const Color(0xFF059669), const Color(0xFF10B981)],
      'accentColor': const Color(0xFFFCD34D),
      'icon': FontAwesomeIcons.certificate,
    },
    {
      'badge': '⭐ PRODUK UMKM LOKAL',
      'title': 'Aneka Olahan Mangga Gurih & Legit',
      'subtitle': 'Dodol, Keripik, Sirup & Sambal khas Dermayu',
      'tag': '100% Organik',
      'bgGradient': [const Color(0xFFB45309), const Color(0xFFD97706), const Color(0xFFF59E0B)],
      'accentColor': const Color(0xFFFEF3C7),
      'icon': FontAwesomeIcons.shieldHeart,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      height: 155,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: banner['bgGradient'] as List<Color>,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: (banner['bgGradient'] as List<Color>).first.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative Background Circle
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 15,
                      top: 15,
                      child: Icon(
                        banner['icon'] as IconData,
                        size: 64,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withOpacity(0.3)),
                              ),
                              child: Text(
                                banner['badge'] as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: banner['accentColor'] as Color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                banner['tag'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF1F2937),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              banner['title'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtitle'] as String,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Beli Sekarang',
                                    style: TextStyle(
                                      color: Color(0xFF047857),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 12,
                                    color: Color(0xFF047857),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          // Page Indicator Dots
          Positioned(
            bottom: 10,
            right: 18,
            child: Row(
              children: List.generate(
                _banners.length,
                (i) => Container(
                  width: _currentPage == i ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: _currentPage == i ? Colors.white : Colors.white.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
