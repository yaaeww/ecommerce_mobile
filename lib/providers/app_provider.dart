import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AppProvider with ChangeNotifier {
  List<Kategori> _kategoris = [];
  List<Produk> _produks = [];
  List<Produk> _produksTerbaru = [];
  List<Keranjang> _keranjang = [];
  List<Order> _orders = [];
  User? _user;
  bool _isLoading = false;

  List<Kategori> get kategoris => _kategoris;
  List<Produk> get produks => _produks;
  List<Produk> get produksTerbaru => _produksTerbaru;
  List<Keranjang> get keranjang => _keranjang;
  List<Order> get orders => _orders;
  User? get user => _user;
  bool get isLoading => _isLoading;

  // ✅ PERBAIKAN: Set user dengan type safety
  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  // ✅ PERBAIKAN: Set user dari Map (untuk shared preferences)
  void setUserFromMap(Map<String, dynamic> userData) {
    try {
      _user = User.fromJson(userData);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error setting user from map: $e');
      }
    }
  }

  // Load semua data awal
  Future<void> loadInitialData() async {
    await Future.wait([
      loadKategoris(),
      loadProduksTerbaru(),
      loadKeranjang(),
    ]);
  }

  // Load Kategori
  Future<void> loadKategoris() async {
    _setLoading(true);
    try {
      _kategoris = await ApiService.getKategoris();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading categories: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Load Produk Terbaru
  Future<void> loadProduksTerbaru() async {
    _setLoading(true);
    try {
      _produksTerbaru = await ApiService.getProduksTerbaru();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading new products: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Load Orders
  Future<void> loadOrders() async {
    _setLoading(true);
    try {
      _orders = await ApiService.getOrders();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading orders: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Load Semua Produk
  Future<void> loadAllProduks() async {
    _setLoading(true);
    try {
      _produks = await ApiService.getAllProduks();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading all products: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Load Keranjang
  Future<void> loadKeranjang() async {
    try {
      _keranjang = await ApiService.getKeranjang();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cart: $e');
      }
    }
  }

  // Tambah ke Keranjang
  Future<void> addToKeranjang(Produk produk, int jumlah) async {
    try {
      await ApiService.addToCart(produk.id, jumlah);
      await loadKeranjang(); // Reload keranjang
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding to cart: $e');
      }
      rethrow;
    }
  }

  Future<void> tambahKeKeranjang(int produkId, int jumlah) async {
    try {
      await ApiService.addToCart(produkId, jumlah);
      await loadKeranjang();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error adding to cart: $e');
      }
      rethrow;
    }
  }

  // Logout
  void logout() {
    _user = null;
    _keranjang.clear();
    notifyListeners();
  }

  // Helper untuk set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get total items in cart
  int get totalCartItems {
    return _keranjang.fold(0, (sum, item) => sum + item.jumlah);
  }

  // Get total cart value
  double get totalCartValue {
    return _keranjang.fold(0, (sum, item) {
      if (item.produk != null) {
        return sum + (item.produk!.hargaSetelahDiskon * item.jumlah);
      }
      return sum;
    });
  }
}
