// lib/layouts/customer_layout.dart
import 'package:flutter/material.dart';
import 'customer_navbar.dart';

class CustomerLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final bool withNavBar;
  final int dalamPengirimanCount;

  const CustomerLayout({
    super.key,
    required this.child,
    this.title = 'UMKM Indramayu',
    this.withNavBar = true,
    this.dalamPengirimanCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Navbar
          if (withNavBar)
            CustomerNavBar(
              dalamPengirimanCount: dalamPengirimanCount,
            ),
          
          // Main Content
          Expanded(
            child: child,
          ),
        ],
      ),
    );
  }
}