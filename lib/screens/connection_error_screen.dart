import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/api_service.dart';

class ConnectionErrorScreen extends StatefulWidget {
  const ConnectionErrorScreen({super.key});

  @override
  State<ConnectionErrorScreen> createState() => _ConnectionErrorScreenState();
}

class _ConnectionErrorScreenState extends State<ConnectionErrorScreen> {
  bool _isChecking = false;

  Future<void> _testConnection() async {
    setState(() => _isChecking = true);
    try {
      final isConnected = await ApiService.testConnection();
      if (!mounted) return;
      if (isConnected) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal terhubung ke ${ApiService.baseUrl}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  void _showChangeServerDialog() {
    final controller = TextEditingController(text: ApiService.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.settings_ethernet, color: Color(0xFFF59E0B)),
            SizedBox(width: 8),
            Text('Atur URL / IP Server', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih mode atau ketik IP secara manual:',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('💻 Laptop (127.0.0.1)'),
                  backgroundColor: const Color(0xFF334155),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  onPressed: () {
                    controller.text = 'http://127.0.0.1:8000/api';
                  },
                ),
                ActionChip(
                  label: const Text('📱 HP Teman (192.168.1.211)'),
                  backgroundColor: const Color(0xFF334155),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  onPressed: () {
                    controller.text = 'http://192.168.1.211:8000/api';
                  },
                ),
                ActionChip(
                  label: const Text('🤖 Emulator (10.0.2.2)'),
                  backgroundColor: const Color(0xFF334155),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 11),
                  onPressed: () {
                    controller.text = 'http://10.0.2.2:8000/api';
                  },
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Base URL API',
                labelStyle: const TextStyle(color: Colors.white70),
                hintText: 'http://127.0.0.1:8000/api',
                hintStyle: const TextStyle(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF059669),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final newUrl = controller.text.trim();
              Navigator.pop(ctx);
              await ApiService.setCustomBaseUrl(newUrl);
              setState(() {});
              _testConnection();
            },
            child: const Text('Simpan & Tes'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.wifi_off,
                  color: Colors.red,
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Koneksi Gagal',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                'Tidak dapat terhubung ke server Laravel.\nPastikan server aktif:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),

              // Troubleshooting Steps
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.mediumBlue.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStep('1. Laravel berjalan di port 8000: php artisan serve --host=0.0.0.0'),
                    _buildStep('2. Jika di Laptop/Browser: gunakan 127.0.0.1:8000'),
                    _buildStep('3. Jika di HP Fisik: gunakan IP WiFi Laptop Anda (cth: 192.168.1.211)'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Retry Button
              ElevatedButton.icon(
                onPressed: _isChecking ? null : _testConnection,
                icon: _isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Icon(Icons.refresh),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.darkBlue,
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                label: Text(
                  _isChecking ? 'MEMERIKSA...' : 'COBA LAGI',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Change Server URL Button
              OutlinedButton.icon(
                onPressed: _showChangeServerDialog,
                icon: const Icon(Icons.tune, size: 16),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                label: const Text('Ganti / Pilih IP Server', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(height: 16),

              // Current URL Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.6)),
                ),
                child: Text(
                  'Target URL: ${ApiService.baseUrl}',
                  style: TextStyle(
                    color: AppColors.gold,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
