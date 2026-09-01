import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/colors.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';

/// Tab 3: Pesanan
/// Visual timeline tracking + order status
class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    await provider.loadKeranjang(); // reuse to trigger data reload
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        title: Text('Pesanan', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
      ),
      body: Consumer<AppProvider>(builder: (context, provider, _) {
        final orders = provider.orders;

        if (orders.isEmpty) {
          return Center(child: _buildEmptyState());
        }

        // Group by status
        final active = orders.where((o) => o.status == 'pending' || (o.statusPesanan != null && o.statusPesanan != 'diterima' && o.status != 'cancel')).toList();
        final completed = orders.where((o) => o.status == 'complete' && o.statusPesanan == 'diterima').toList();
        final cancelled = orders.where((o) => o.status == 'cancel').toList();

        return DefaultTabComponent(
          tabs: const ['Aktif', 'Selesai', 'Dibatalkan'],
          children: [
            _buildOrderList(active),
            _buildOrderList(completed),
            _buildOrderList(cancelled),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.local_shipping, size: 64, color: AppColors.textMuted),
      const SizedBox(height: 16),
      Text('Belum ada pesanan', style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Pesan produk untuk melihat riwayat di sini', style: TextStyle(color: AppColors.textGrey)),
    ]);
  }

  Widget _buildOrderList(List<Order> orders) {
    if (orders.isEmpty) {
      return Center(child: Text('Tidak ada pesanan', style: TextStyle(color: AppColors.textGrey)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Order order) {
    final bool isCancelled = order.status == 'cancel';
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // Header: seller name + status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: isCancelled ? Colors.grey[100] : AppColors.surface, border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            CircleAvatar(backgroundColor: AppColors.emerald.withOpacity(0.1), radius: 14, child: Icon(Icons.store, color: AppColors.emerald, size: 16)),
            const SizedBox(width: 8),
            Text(order.produk?.nama ?? 'Produk', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 14)),
            const Spacer(),
            Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: _statusColor(order).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(order.statusText, style: TextStyle(color: _statusColor(order), fontSize: 12, fontWeight: FontWeight.bold))),
          ]),
        ),

        // Product row
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: CachedNetworkImage(
                imageUrl: order.produk?.gambar ?? 'https://via.placeholder.com/100',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(width: 70, height: 70, color: AppColors.divider),
                errorWidget: (_, __, ___) => Icon(Icons.broken_image, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(order.produk?.nama ?? 'Produk', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w500, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text('Qty: ${order.jumlah}', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
              const SizedBox(height: 4),
              Text('Rp ${order.totalHarga}', style: TextStyle(color: AppColors.emerald, fontWeight: FontWeight.bold, fontSize: 14)),
            ])),
          ]),
        ),

        // Timeline
        Container(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: _buildTimeline(order)),

        // Action
        if (order.status == 'pending' && order.statusPesanan == null)
          Padding(padding: EdgeInsets.all(12), child: Text('Menunggu pembayaran', style: TextStyle(color: AppColors.textGrey, fontSize: 12), textAlign: TextAlign.center)),
      ]),
    );
  }

  Widget _buildTimeline(Order order) {
    final steps = [
      StepInfo('Pesanan Dibuat', order.createdAt),
      StepInfo('Sedang Dikemas', order.createdAt.add(Duration(hours: 1))),
      StepInfo('Dikirim', order.statusPesanan == null ? null : order.createdAt.add(Duration(hours: 5))),
      StepInfo('Diterima', order.statusPesanan == 'diterima' ? order.createdAt.add(Duration(days: 2)) : null),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Status Pesanan', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 13)),
      const SizedBox(height: 8),
      ...steps.asMap().entries.map((e) {
        final i = e.key;
        final step = e.value;
        final isLast = i == steps.length - 1;
        final isActive = step.time != null;
        final isCurrent = i <= (order.statusPesanan != null ? (order.statusPesanan == 'diterima' ? 3 : order.statusPesanan == 'dikirim' ? 2 : order.statusPesanan == 'dikemas' ? 1 : 0) : 0);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 18, height: 18,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? AppColors.emerald : AppColors.textMuted),
                  child: isActive ? Icon(Icons.check, color: Colors.white, size: 12) : null,
                ),
                if (!isLast) Container(width: 2, height: 24, color: AppColors.divider, margin: EdgeInsets.only(left: 9, top: 2)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.label, style: TextStyle(color: isActive ? AppColors.textDark : AppColors.textGrey, fontWeight: isActive ? FontWeight.w600 : FontWeight.normal, fontSize: 13)),
                  if (isActive && step.time != null) Text(_formatDate(step.time!), style: TextStyle(color: AppColors.textGrey, fontSize: 11)),
                ],
              ),
            ),
          ],
        );
      }),
    ]);
  }

  Color _statusColor(Order order) {
    if (order.status == 'cancel') return Colors.red;
    if (order.status == 'complete') return AppColors.emerald;
    return AppColors.mango;
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class StepInfo {
  final String label;
  final DateTime? time;
  StepInfo(this.label, this.time);
}

class DefaultTabComponent extends StatelessWidget {
  final List<Widget> children;
  final List<String> tabs;

  const DefaultTabComponent({super.key, required this.tabs, required this.children});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Column(children: [
        Container(
          color: AppColors.surface,
          child: TabBar(
            isScrollable: true,
            indicatorColor: AppColors.emerald,
            labelColor: AppColors.emerald,
            unselectedLabelColor: AppColors.textGrey,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
            tabs: tabs.map((t) => Tab(text: t)).toList(),
          ),
        ),
        Expanded(child: TabBarView(children: children)),
      ]),
    );
  }
}
