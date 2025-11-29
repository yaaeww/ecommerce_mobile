import 'dart:convert';

// User Model
class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // ✅ PERBAIKAN: Handle berbagai format JSON
    return User(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString(),
      role: json['role']?.toString() ?? 'pembeli',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatar': avatar,
      'role': role,
    };
  }
}

// Kategori Model
class Kategori {
  final int id;
  final int? parentId;
  final String nama;
  final String slug;
  final String? gambar;
  final List<Kategori>? subkategoris;
  final List<Produk>? produks;

  Kategori({
    required this.id,
    this.parentId,
    required this.nama,
    required this.slug,
    this.gambar,
    this.subkategoris,
    this.produks,
  });

  factory Kategori.fromJson(Map<String, dynamic> json) {
    // ✅ PERBAIKAN: Handle null dan type conversion
    return Kategori(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      parentId: json['parent_id'] != null 
          ? (json['parent_id'] is int ? json['parent_id'] : int.tryParse(json['parent_id'].toString()))
          : null,
      nama: json['nama']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      gambar: json['gambar']?.toString(),
      subkategoris: json['subkategoris'] != null 
          ? (json['subkategoris'] as List).map((i) => Kategori.fromJson(i)).toList()
          : null,
      produks: json['produks'] != null
          ? (json['produks'] as List).map((i) => Produk.fromJson(i)).toList()
          : null,
    );
  }
}

// Produk Model
class Produk {
  final int id;
  final String nama;
  final String? deskripsi;
  final double harga;
  final String? gambar;
  final int stok;
  final double? rating;
  final int kategoriProdukId;
  final int? umkmId;
  final Diskon? diskon;

  Produk({
    required this.id,
    required this.nama,
    this.deskripsi,
    required this.harga,
    this.gambar,
    required this.stok,
    this.rating,
    required this.kategoriProdukId,
    this.umkmId,
    this.diskon,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    // ✅ PERBAIKAN: Handle type conversion dengan safe
    return Produk(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
      harga: json['harga'] is double 
          ? json['harga'] 
          : double.tryParse(json['harga'].toString()) ?? 0.0,
      gambar: json['gambar']?.toString(),
      stok: json['stok'] is int ? json['stok'] : int.tryParse(json['stok'].toString()) ?? 0,
      rating: json['rating'] != null 
          ? (json['rating'] is double 
              ? json['rating'] 
              : double.tryParse(json['rating'].toString()))
          : null,
      kategoriProdukId: json['kategori_produk_id'] is int 
          ? json['kategori_produk_id'] 
          : int.tryParse(json['kategori_produk_id'].toString()) ?? 0,
      umkmId: json['umkm_id'] != null 
          ? (json['umkm_id'] is int 
              ? json['umkm_id'] 
              : int.tryParse(json['umkm_id'].toString()))
          : null,
      diskon: json['diskon'] != null ? Diskon.fromJson(json['diskon']) : null,
    );
  }

  double get hargaSetelahDiskon {
    if (diskon != null && diskon!.isActive) {
      return harga - (harga * diskon!.persenDiskon / 100);
    }
    return harga;
  }

  bool get adaDiskon => diskon != null && diskon!.isActive;
}

// Diskon Model
class Diskon {
  final int id;
  final int produksId;
  final int persenDiskon;
  final DateTime tanggalMulai;
  final DateTime tanggalBerakhir;

  Diskon({
    required this.id,
    required this.produksId,
    required this.persenDiskon,
    required this.tanggalMulai,
    required this.tanggalBerakhir,
  });

  factory Diskon.fromJson(Map<String, dynamic> json) {
    return Diskon(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      produksId: json['produks_id'] is int 
          ? json['produks_id'] 
          : int.tryParse(json['produks_id'].toString()) ?? 0,
      persenDiskon: json['persen_diskon'] is int 
          ? json['persen_diskon'] 
          : int.tryParse(json['persen_diskon'].toString()) ?? 0,
      tanggalMulai: DateTime.parse(json['tanggal_mulai'].toString()),
      tanggalBerakhir: DateTime.parse(json['tanggal_berakhir'].toString()),
    );
  }

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(tanggalMulai) && now.isBefore(tanggalBerakhir);
  }
}

// Ulasan Model
class Ulasan {
  final int id;
  final int usersId;
  final int produksId;
  final int ordersId;
  final int bintang;
  final String ulasan;
  final User? user;

  Ulasan({
    required this.id,
    required this.usersId,
    required this.produksId,
    required this.ordersId,
    required this.bintang,
    required this.ulasan,
    this.user,
  });

  factory Ulasan.fromJson(Map<String, dynamic> json) {
    return Ulasan(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      usersId: json['users_id'] is int 
          ? json['users_id'] 
          : int.tryParse(json['users_id'].toString()) ?? 0,
      produksId: json['produks_id'] is int 
          ? json['produks_id'] 
          : int.tryParse(json['produks_id'].toString()) ?? 0,
      ordersId: json['orders_id'] is int 
          ? json['orders_id'] 
          : int.tryParse(json['orders_id'].toString()) ?? 0,
      bintang: json['bintang'] is int 
          ? json['bintang'] 
          : int.tryParse(json['bintang'].toString()) ?? 0,
      ulasan: json['ulasan']?.toString() ?? '',
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

// Keranjang Model
class Keranjang {
  final int id;
  final int userId;
  final int produkId;
  final int jumlah;
  final Produk? produk;

  Keranjang({
    required this.id,
    required this.userId,
    required this.produkId,
    required this.jumlah,
    this.produk,
  });

  factory Keranjang.fromJson(Map<String, dynamic> json) {
    return Keranjang(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int 
          ? json['user_id'] 
          : int.tryParse(json['user_id'].toString()) ?? 0,
      produkId: json['produk_id'] is int 
          ? json['produk_id'] 
          : int.tryParse(json['produk_id'].toString()) ?? 0,
      jumlah: json['jumlah'] is int 
          ? json['jumlah'] 
          : int.tryParse(json['jumlah'].toString()) ?? 1,
      produk: json['produk'] != null ? Produk.fromJson(json['produk']) : null,
    );
  }
}