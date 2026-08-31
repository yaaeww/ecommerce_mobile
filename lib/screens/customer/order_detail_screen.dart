// screens/customer/order_detail_screen.dart (versi final)
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/colors.dart';
import '../../models/models.dart';
import '../../layouts/customer_navbar.dart';
import '../midtrans_payment_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isProcessingPayment = false;

  void _processPayment() {
    // TODO: Integrate with Midtrans SDK
    setState(() {
      _isProcessingPayment = true;
    });

    // Simulate payment process
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessingPayment = false;
      });

      // Navigate to payment screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MidtransPaymentScreen(
            snapToken: widget.order.snapToken ?? '',
            orderId: widget.order.id,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final produk = widget.order.produk;
    final hasDiscount = produk?.adaDiskon ?? false;
    final hargaAsli = produk?.harga ?? 0;
    final hargaSetelahDiskon = produk?.hargaSetelahDiskon ?? hargaAsli;
    final subtotalPerItem = hasDiscount ? hargaSetelahDiskon : hargaAsli;
    final totalHarga = subtotalPerItem * widget.order.jumlah;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Stack(
        children: [
          // Background gradient
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0a1628),
                  Color(0xFF1a3a5f),
                ],
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Navbar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                floating: true,
                pinned: false,
                expandedHeight: 0,
                toolbarHeight: 80,
                flexibleSpace: CustomerNavBar(
                  dalamPengirimanCount: 0,
                  currentRoute: '/customer-order-detail',
                ),
              ),

              // Page Header
              SliverToBoxAdapter(
                child: _buildPageHeader(),
              ),

              // Order Detail Card
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: _buildOrderCard(
                    produk: produk,
                    hasDiscount: hasDiscount,
                    hargaAsli: hargaAsli,
                    hargaSetelahDiskon: hargaSetelahDiskon,
                    totalHarga: totalHarga,
                  ),
                ),
              ),
            ],
          ),

          // Loading Overlay
          if (_isProcessingPayment)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(FontAwesomeIcons.receipt, color: AppColors.gold, size: 24),
              const SizedBox(width: 12),
              Text(
                'Detail Pesanan Anda',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [AppColors.gold, Color(0xFFffed4e)],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard({
    required Produk? produk,
    required bool hasDiscount,
    required double hargaAsli,
    required double hargaSetelahDiskon,
    required double totalHarga,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E).withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Title
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(FontAwesomeIcons.infoCircle,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Informasi Pemesanan',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Order Info Table
          Padding(
            padding: const EdgeInsets.all(24),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow('Nama', widget.order.name),
                _buildTableRow('Nomor HP', widget.order.phone),
                _buildTableRow('Alamat', widget.order.alamat),
                _buildTableRow('Jumlah Barang', '${widget.order.jumlah}'),
                _buildTableRow('Produk', produk?.nama ?? '-'),
                _buildTableRow(
                  'Harga Satuan',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasDiscount)
                        Text(
                          'Rp ${hargaAsli.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      Text(
                        'Rp ${hargaSetelahDiskon.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: hasDiscount
                              ? const Color(0xFF28a745)
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                TableRow(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Total Harga',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        'Rp ${totalHarga.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: const Color(0xFFffed4e),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Payment Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Column(
              children: [
                // Payment Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Langkah selanjutnya:',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Klik tombol di bawah untuk melanjutkan pembayaran',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(FontAwesomeIcons.shieldAlt,
                              color: AppColors.gold, size: 12),
                          const SizedBox(width: 8),
                          Text(
                            'Pembayaran diproses dengan aman oleh Midtrans',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Pay Button
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, Color(0xFFffed4e)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: _isProcessingPayment ? null : _processPayment,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(FontAwesomeIcons.creditCard,
                                color: AppColors.darkBlue, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _isProcessingPayment
                                  ? 'Memproses...'
                                  : 'Bayar Sekarang',
                              style: TextStyle(
                                color: AppColors.darkBlue,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, dynamic value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: value is Widget
              ? value
              : Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
        ),
      ],
    );
  }
}