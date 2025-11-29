import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl =
      'http://localhost:8000/api'; // Untuk Android Emulator

  // Helper method untuk mendapatkan token
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      return null;
    }
  }

  // Headers dengan auth
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Handle response dengan better error messages
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final errorData = json.decode(response.body);
      throw Exception(
          errorData['message'] ?? 'Terjadi kesalahan: ${response.statusCode}');
    }
  }

  // ✅ TAMBAHKAN: Method saveToken yang hilang
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
    } catch (e) {
      throw Exception('Gagal menyimpan token: $e');
    }
  }

  // ✅ TAMBAHKAN: Method logout
  static Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: await _getHeaders(),
      );

      _handleResponse(response);

      // Clear token dari shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    } catch (e) {
      throw Exception('Logout gagal: $e');
    }
  }

  // GET Kategori dengan subkategori dan produk
  static Future<List<Kategori>> getKategoris() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kategoris'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => Kategori.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat kategori: $e');
    }
  }

  // GET Produk terbaru
  static Future<List<Produk>> getProduksTerbaru() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produks/terbaru'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => Produk.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat produk terbaru: $e');
    }
  }

  // GET Semua produk
  static Future<List<Produk>> getAllProduks() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produks'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => Produk.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat produk: $e');
    }
  }

  // GET Produk by Kategori
  static Future<List<Produk>> getProduksByKategori(int kategoriId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/kategoris/$kategoriId/produks'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => Produk.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat produk kategori: $e');
    }
  }

  // GET Detail Produk
  static Future<Produk> getProdukDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produks/$id'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final dynamic data = responseData['data'];
      return Produk.fromJson(data);
    } catch (e) {
      throw Exception('Gagal memuat detail produk: $e');
    }
  }

  // GET Ulasan Produk
  static Future<List<Ulasan>> getUlasanByProduk(int produkId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produks/$produkId/ulasan'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => Ulasan.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat ulasan: $e');
    }
  }

  // POST Login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: await _getHeaders(),
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Login gagal: $e');
    }
  }

  // POST Register
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: await _getHeaders(),
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Registrasi gagal: $e');
    }
  }

  // GET Keranjang
  static Future<List<Keranjang>> getKeranjang() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/keranjang'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => Keranjang.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat keranjang: $e');
    }
  }

  // POST Tambah ke Keranjang
  static Future<void> addToCart(int produkId, int jumlah) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/keranjang'),
        headers: await _getHeaders(),
        body: json.encode({
          'produk_id': produkId,
          'jumlah': jumlah,
        }),
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal menambah ke keranjang: $e');
    }
  }

  // UPDATE Keranjang
  static Future<void> updateCart(int keranjangId, int jumlah) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/keranjang/$keranjangId'),
        headers: await _getHeaders(),
        body: json.encode({
          'jumlah': jumlah,
        }),
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal mengupdate keranjang: $e');
    }
  }

  // DELETE dari Keranjang
  static Future<void> removeFromCart(int keranjangId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/keranjang/$keranjangId'),
        headers: await _getHeaders(),
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal menghapus dari keranjang: $e');
    }
  }

  // Helper untuk build image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null) return '';

    if (imagePath.startsWith('http')) return imagePath;

    if (imagePath.startsWith('storage/')) {
      return '$baseUrl/${imagePath.replaceFirst('storage/', 'storage/')}';
    }

    return '$baseUrl/storage/$imagePath';
  }

  // Test koneksi API
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: await _getHeaders(),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
