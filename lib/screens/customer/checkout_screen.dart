import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../constants/colors.dart';
import '../../providers/app_provider.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../../layouts/customer_navbar.dart';
import 'order_detail_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Produk produk;
  final int quantity;

  const CheckoutScreen({
    Key? key,
    required this.produk,
    required this.quantity,
  }) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _alamatController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Load user data if available
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.user != null) {
      _nameController.text = provider.user!.name;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  double get _hargaSetelahDiskon {
    return widget.produk.hargaSetelahDiskon;
  }

  int get _totalHarga {
    return (_hargaSetelahDiskon * widget.quantity).toInt();
  }

  Future<void> _processOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // PERBAIKAN: Tambahkan parameter harga per item
      final response = await ApiService.createOrder(
        widget.produk.id,
        widget.quantity,
        _nameController.text.trim(),
        _phoneController.text.trim(),
        _alamatController.text.trim(),
        _hargaSetelahDiskon, // Parameter ke-6: harga per item
      );

      final orderData = response['data'];
      final order = Order.fromJson(orderData);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pesanan berhasil dibuat! ID Pesanan: ${order.id}',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );

        // Navigate to order detail screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(
              order: order,
            ),
          ),
        );
      }
    } catch (e) {
      print('Error creating order: $e');

      String errorMessage = 'Gagal membuat pesanan';

      // Parse error message lebih spesifik
      if (e.toString().contains('stok')) {
        errorMessage = 'Stok produk tidak mencukupi';
      } else if (e.toString().contains('validation')) {
        errorMessage = 'Harap periksa kembali data yang Anda masukkan';
      } else if (e.toString().contains('alamat')) {
        errorMessage = 'Alamat harus diisi dengan lengkap';
      } else if (e.toString().contains('phone')) {
        errorMessage = 'Nomor telepon tidak valid';
      } else if (e.toString().contains('authentication')) {
        errorMessage = 'Silakan login terlebih dahulu';
      } else if (e.toString().contains('unexpected number')) {
        errorMessage = 'Jumlah parameter tidak sesuai. Silakan coba lagi.';
      } else {
        errorMessage =
            'Gagal membuat pesanan: ${e.toString().replaceAll('Exception: ', '')}';
      }

      setState(() {
        _errorMessage = errorMessage;
        _isLoading = false;
      });

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Gagal Membuat Pesanan',
              style: TextStyle(color: AppColors.gold)),
          content: Text(errorMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK', style: TextStyle(color: AppColors.gold)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  currentRoute: '/customer-checkout',
                ),
              ),

              // Page Header
              SliverToBoxAdapter(
                child: _buildPageHeader(),
              ),

              // Error Message
              if (_errorMessage != null)
                SliverToBoxAdapter(
                  child: _buildErrorMessage(),
                ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Product Detail Section
                      _buildProductDetail(),
                      const SizedBox(height: 24),

                      // Order Form Section
                      _buildOrderForm(),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Loading Overlay
          if (_isLoading)
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
              Icon(FontAwesomeIcons.shoppingBag,
                  color: AppColors.gold, size: 24),
              const SizedBox(width: 12),
              Text(
                'Checkout Pesanan',
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
          const SizedBox(height: 8),
          Text(
            'Lengkapi data pemesanan di bawah ini',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFdc3545).withOpacity(0.2),
        border: Border.all(color: const Color(0xFFdc3545).withOpacity(0.5)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(FontAwesomeIcons.exclamationTriangle,
              color: Colors.white, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetail() {
    final hasDiscount = widget.produk.adaDiskon;
    final imageUrl = widget.produk.gambar != null
        ? ApiService.getImageUrl(widget.produk.gambar!)
        : '';

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
          // Section Title
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
            ),
            child: Row(
              children: [
                Icon(FontAwesomeIcons.box, color: AppColors.gold, size: 18),
                const SizedBox(width: 12),
                Text(
                  'Detail Produk',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Product Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image dengan error handling
                _buildProductImage(imageUrl),
                const SizedBox(height: 20),

                // Product Name
                Text(
                  widget.produk.nama,
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Product Description
                if (widget.produk.deskripsi != null)
                  Text(
                    widget.produk.deskripsi!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                const SizedBox(height: 20),

                // Price Info
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (hasDiscount)
                            Text(
                              'Rp ${widget.produk.harga.toStringAsFixed(0)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 14,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          Text(
                            'Rp ${_hargaSetelahDiskon.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: hasDiscount
                                  ? const Color(0xFF28a745)
                                  : Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (widget.produk.stok > 0)
                            Text(
                              'Stok tersedia: ${widget.produk.stok}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          if (widget.quantity > widget.produk.stok)
                            Text(
                              '⚠️ Pesanan melebihi stok tersedia',
                              style: TextStyle(
                                color: const Color(0xFFff6b6b),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.1),
                        border: Border.all(color: AppColors.gold),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${widget.quantity}',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'item',
                            style: TextStyle(
                              color: AppColors.gold.withOpacity(0.8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Total Price
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Harga:',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${widget.quantity} item × Rp ${_hargaSetelahDiskon.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Rp $_totalHarga',
                        style: TextStyle(
                          color: const Color(0xFFffed4e),
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
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

  Widget _buildProductImage(String imageUrl) {
    if (widget.produk.gambar == null) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[800],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, color: Colors.grey, size: 48),
              const SizedBox(height: 8),
              Text(
                'Tidak ada gambar',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[800],
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.gold,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Container(
              color: Colors.grey[800],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.broken_image, color: Colors.grey, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Gambar tidak tersedia',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOrderForm() {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Title
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                children: [
                  Icon(FontAwesomeIcons.userEdit,
                      color: AppColors.gold, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    'Data Pemesanan',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Form Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Name Field
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nama Lengkap',
                    hint: 'Masukkan Nama Lengkap Anda!',
                    icon: FontAwesomeIcons.user,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama harus diisi';
                      }
                      if (value.length < 3) {
                        return 'Nama minimal 3 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Phone Field
                  _buildTextField(
                    controller: _phoneController,
                    label: 'Nomor HP/WhatsApp',
                    hint: 'Contoh: 081234567890',
                    icon: FontAwesomeIcons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor HP harus diisi';
                      }
                      if (value.length < 10 || value.length > 15) {
                        return 'Nomor HP harus 10-15 digit';
                      }
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return 'Nomor HP hanya boleh angka';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Address Field
                  _buildTextArea(
                    controller: _alamatController,
                    label: 'Alamat Pengiriman',
                    hint:
                        'Contoh: Jl. Merdeka No. 123, RT 01/RW 02, Kelurahan Sukajadi, Kecamatan Cimahi, Kota Bandung, 40123',
                    icon: FontAwesomeIcons.mapMarkerAlt,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Alamat pengiriman harus diisi';
                      }
                      if (value.length < 15) {
                        return 'Alamat terlalu pendek, minimal 15 karakter';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 30),

                  // Order Button dengan kondisi validasi stok
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: widget.quantity <= widget.produk.stok
                            ? [AppColors.gold, Color(0xFFffed4e)]
                            : [Colors.grey, Colors.grey[600]!],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: widget.quantity <= widget.produk.stok
                              ? AppColors.gold.withOpacity(0.4)
                              : Colors.transparent,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap:
                            widget.quantity <= widget.produk.stok && !_isLoading
                                ? _processOrder
                                : null,
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: AppColors.darkBlue,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.creditCard,
                                      color:
                                          widget.quantity <= widget.produk.stok
                                              ? AppColors.darkBlue
                                              : Colors.white.withOpacity(0.7),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      widget.quantity <= widget.produk.stok
                                          ? 'Pesan Sekarang'
                                          : 'Stok Tidak Cukup',
                                      style: TextStyle(
                                        color: widget.quantity <=
                                                widget.produk.stok
                                            ? AppColors.darkBlue
                                            : Colors.white.withOpacity(0.7),
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

                  // Pesan peringatan jika stok tidak cukup
                  if (widget.quantity > widget.produk.stok)
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFff6b6b).withOpacity(0.2),
                        border: Border.all(
                            color: const Color(0xFFff6b6b).withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning,
                              color: const Color(0xFFff6b6b), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Jumlah pesanan (${widget.quantity}) melebihi stok tersedia (${widget.produk.stok})',
                              style: TextStyle(
                                color: const Color(0xFFff6b6b),
                                fontSize: 12,
                              ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.gold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.gold, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.gold),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
