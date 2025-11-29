import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'token';
  static const String _userKey = 'user';

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      final user = prefs.getString(_userKey);

      // ✅ PERBAIKAN: Cek token DAN user data
      return token != null &&
          token.isNotEmpty &&
          user != null &&
          user.isNotEmpty;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      throw Exception('Gagal menyimpan token: $e');
    }
  }

  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, json.encode(userData));
      print('✅ User data saved: $userData'); // Debug log
    } catch (e) {
      throw Exception('Gagal menyimpan data user: $e');
    }
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(_userKey);

      if (userString != null && userString.isNotEmpty) {
        final userData = json.decode(userString);
        print('✅ User data retrieved: $userData'); // Debug log
        return userData;
      }

      print('❌ No user data found'); // Debug log
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      print('✅ Auth data cleared'); // Debug log
    } catch (e) {
      throw Exception('Gagal menghapus data auth: $e');
    }
  }

  // ✅ METHOD BARU: Logout yang komplit
  static Future<void> logout() async {
    try {
      await clearAuthData();
      print('✅ Logout successful');
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Gagal logout: $e');
    }
  }
}
