import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api';

  // Helper method untuk mendapatkan token
  static Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('token');
    } catch (e) {
      print('Error getting token: $e');
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

  // Handle response dengan better error messages dan debugging
  static dynamic _handleResponse(http.Response response) {
    print('API Response Status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        return json.decode(response.body);
      } catch (e) {
        print('JSON Decode Error: $e');
        throw Exception('Format response tidak valid: $e');
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['message'] ??
            errorData['error'] ??
            'Terjadi kesalahan: ${response.statusCode}';

        // Log detail error
        if (errorData['errors'] != null) {
          print('Validation Errors: ${errorData['errors']}');
        }

        throw Exception(errorMessage);
      } catch (e) {
        print('Error parsing error response: $e');
        throw Exception(
            'Terjadi kesalahan: ${response.statusCode} - ${response.body}');
      }
    }
  }

  // Method saveToken
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      print('Token saved successfully');
    } catch (e) {
      throw Exception('Gagal menyimpan token: $e');
    }
  }

  // Method logout
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
      print('Logout successful');
    } catch (e) {
      throw Exception('Logout gagal: $e');
    }
  }

  // ========== AUTHENTICATION ==========
  // POST Login
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    try {
      print('Attempting login for email: $email');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = _handleResponse(response);

      // Simpan token jika ada
      if (responseData['token'] != null) {
        await saveToken(responseData['token']);
      }

      return responseData;
    } catch (e) {
      print('Login error: $e');
      throw Exception('Login gagal: $e');
    }
  }

  // POST Register
  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': password,
          'role': role,
        }),
      );

      final responseData = _handleResponse(response);

      // Simpan token jika ada
      if (responseData['token'] != null) {
        await saveToken(responseData['token']);
      }

      return responseData;
    } catch (e) {
      throw Exception('Registrasi gagal: $e');
    }
  }

  // ========== USER ==========
  // GET Current User
  static Future<User> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      return User.fromJson(responseData);
    } catch (e) {
      throw Exception('Gagal memuat data user: $e');
    }
  }

  // ========== KATEGORI ==========
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

  // ========== PRODUK ==========
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

  // GET Detail Produk - DIPERBARUI untuk handle error parsing
  static Future<Produk> getProdukDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/produks/$id'),
        headers: await _getHeaders(),
      );

      print('Produk Detail Response Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          
          if (responseData['success'] == true) {
            final dynamic data = responseData['data'];
            
            // Pastikan kita tidak mem-parsing field yang tidak diinginkan
            final Map<String, dynamic> cleanData = Map<String, dynamic>.from(data);
            
            // Jika ada field ulasans yang tidak bisa diparse, hapus saja
            if (cleanData.containsKey('ulasans')) {
              try {
                // Coba parse dulu
                final ulasansList = cleanData['ulasans'];
                if (ulasansList is List) {
                  // Jika bisa diparse, biarkan
                } else {
                  // Jika tidak bisa, hapus field ini
                  cleanData.remove('ulasans');
                }
              } catch (e) {
                print('Warning: Error parsing ulasans, removing field: $e');
                cleanData.remove('ulasans');
              }
            }
            
            return Produk.fromJson(cleanData);
          } else {
            throw Exception(responseData['message'] ?? 'Gagal memuat detail produk');
          }
        } catch (e) {
          print('JSON Decode Error in getProdukDetail: $e');
          throw Exception('Format response tidak valid');
        }
      } else if (response.statusCode == 404) {
        throw Exception('Produk tidak ditemukan');
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Terjadi kesalahan: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getProdukDetail: $e');
      throw Exception('Gagal memuat detail produk: ${e.toString()}');
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

  // ========== KERANJANG ==========
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

  // ========== ORDER ==========
  // POST Create Order - DIPERBARUI tanpa memanggil getProdukDetail
  static Future<Map<String, dynamic>> createOrder(
    int produkId,
    int jumlah,
    String name,
    String phone,
    String alamat,
    double hargaPerItem, // Parameter baru: harga per item
  ) async {
    try {
      print('=== CREATING ORDER ===');
      print('Produk ID: $produkId');
      print('Jumlah: $jumlah');
      print('Nama: $name');
      print('Phone: $phone');
      print('Alamat: $alamat');
      print('Harga per item: $hargaPerItem');

      // Hitung total harga langsung dari parameter
      final totalHarga = (hargaPerItem * jumlah).toInt();
      print('Total harga: $totalHarga');

      final headers = await _getHeaders();
      print('Headers: $headers');

      // SESUAI DENGAN DATABASE: field name, phone, alamat (bukan alamat_pengiriman)
      final body = json.encode({
        'produk_id': produkId,
        'jumlah': jumlah,
        'name': name,
        'phone': phone,
        'alamat': alamat,
        'total_harga': totalHarga,
      });
      print('Request Body: $body');

      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: headers,
        body: body,
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('CREATE ORDER ERROR: $e');
      throw Exception('Gagal membuat pesanan: $e');
    }
  }

  // GET Order Detail
  static Future<Order> getOrderDetail(int orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final dynamic data = responseData['data'];
      return Order.fromJson(data);
    } catch (e) {
      throw Exception('Gagal memuat detail order: $e');
    }
  }

  // GET All Orders
  static Future<List<Order>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat daftar order: $e');
    }
  }

  // ========== UMKM ==========
  // GET All UMKM
  static Future<List<Umkm>> getUmkms() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/umkms'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => Umkm.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal memuat UMKM: $e');
    }
  }

  // GET Detail UMKM
  static Future<Umkm> getUmkmDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/umkms/$id'),
        headers: await _getHeaders(),
      );

      final responseData = _handleResponse(response);
      final dynamic data = responseData['data'];
      return Umkm.fromJson(data);
    } catch (e) {
      throw Exception('Gagal memuat detail UMKM: $e');
    }
  }

  // ========== ULASAN ==========
  // POST Create Ulasan
  static Future<void> createUlasan(Map<String, dynamic> ulasanData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ulasan'),
        headers: await _getHeaders(),
        body: json.encode(ulasanData),
      );

      _handleResponse(response);
    } catch (e) {
      throw Exception('Gagal membuat ulasan: $e');
    }
  }

  // ========== IMAGE HANDLING ==========
  // Helper untuk build image URL
  static String getImageUrl(String? imagePath) {
    if (imagePath == null) {
      print('Image path is null');
      return '';
    }

    // Debug log
    print('Original image path: $imagePath');

    // Jika sudah full URL
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Handle berbagai format path
    String correctedPath = imagePath;

    // Jika path dimulai dengan storage/ tapi ada duplikasi
    if (correctedPath.startsWith('storage/')) {
      // Format: storage/produks/xxx.jpg -> sudah benar
    } else if (correctedPath.startsWith('produks/')) {
      // Format: produks/xxx.jpg -> tambahkan storage/
      correctedPath = 'storage/$correctedPath';
    } else if (!correctedPath.contains('/')) {
      // Format: filename.jpg -> asumsi di folder produks
      correctedPath = 'storage/produks/$correctedPath';
    }

    // Pastikan tidak ada duplikasi storage/
    if (correctedPath.startsWith('storage/storage/')) {
      correctedPath =
          correctedPath.replaceFirst('storage/storage/', 'storage/');
    }

    final fullUrl = 'http://localhost:8000/$correctedPath';
    print('Final image URL: $fullUrl');
    return fullUrl;
  }

  // Test koneksi API
  static Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/test'),
        headers: await _getHeaders(),
      );
      print('Test connection status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Test connection error: $e');
      return false;
    }
  }
}