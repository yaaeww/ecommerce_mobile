import 'package:flutter/material.dart';
import '../constants/colors.dart';

/// Tab 4: Chat
/// Placeholder — real-time chat dengan penjual / AI chatbot akan ditambahkan
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        title: Text('Chat', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text('Fitur chat belum tersedia', style: TextStyle(color: AppColors.textDark, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Chat dengan penjual dan bantuan AI akan datang segerga.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textGrey)),
          ]),
        ),
      ),
    );
  }
}
