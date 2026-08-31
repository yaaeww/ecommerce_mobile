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
    return User(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
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
    return Kategori(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      parentId: json['parent_id'] != null
          ? (json['parent_id'] is int
              ? json['parent_id']
              : int.tryParse(json['parent_id'].toString()))
          : null,
      nama: json['nama']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      gambar: json['gambar']?.toString(),
      subkategoris: json['subkategoris'] != null
          ? (json['subkategoris'] as List)
              .map((i) => Kategori.fromJson(i))
              .toList()
          : null,
      produks: json['produks'] != null
          ? (json['produks'] as List).map((i) => Produk.fromJson(i)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parent_id': parentId,
      'nama': nama,
      'slug': slug,
      'gambar': gambar,
      'subkategoris': subkategoris?.map((k) => k.toJson()).toList(),
      'produks': produks?.map((p) => p.toJson()).toList(),
    };
  }
}

// Produk Model - DIPERBARUI untuk handle field 'ulasans'
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
  final dynamic ulasans; // Bisa jadi List<Ulasan> atau null

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
    this.ulasans,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    // Handle field 'ulasans' yang mungkin ada di response JSON
    dynamic parsedUlasans;
    if (json['ulasans'] != null && json['ulasans'] is List) {
      try {
        parsedUlasans =
            (json['ulasans'] as List).map((i) => Ulasan.fromJson(i)).toList();
      } catch (e) {
        print('Error parsing ulasans: $e');
        parsedUlasans = null;
      }
    }

    return Produk(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      nama: json['nama']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
      harga: json['harga'] is double
          ? json['harga']
          : (json['harga'] is int
              ? json['harga'].toDouble()
              : double.tryParse(json['harga'].toString()) ?? 0.0),
      gambar: json['gambar']?.toString(),
      stok: json['stok'] is int
          ? json['stok']
          : int.tryParse(json['stok'].toString()) ?? 0,
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
      ulasans: parsedUlasans,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'deskripsi': deskripsi,
      'harga': harga,
      'gambar': gambar,
      'stok': stok,
      'rating': rating,
      'kategori_produk_id': kategoriProdukId,
      'umkm_id': umkmId,
      'diskon': diskon?.toJson(),
      'ulasans': ulasans is List<Ulasan>
          ? (ulasans as List<Ulasan>).map((u) => u.toJson()).toList()
          : null,
    };
  }

  double get hargaSetelahDiskon {
    if (diskon != null && diskon!.isActive) {
      return harga - (harga * diskon!.persenDiskon / 100);
    }
    return harga;
  }

  bool get adaDiskon => diskon != null && diskon!.isActive;

  // Helper untuk mendapatkan ulasan sebagai List<Ulasan>
  List<Ulasan>? get ulasanList {
    if (ulasans is List<Ulasan>) {
      return ulasans as List<Ulasan>;
    }
    return null;
  }
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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'produks_id': produksId,
      'persen_diskon': persenDiskon,
      'tanggal_mulai': tanggalMulai.toIso8601String(),
      'tanggal_berakhir': tanggalBerakhir.toIso8601String(),
    };
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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'users_id': usersId,
      'produks_id': produksId,
      'orders_id': ordersId,
      'bintang': bintang,
      'ulasan': ulasan,
      'user': user?.toJson(),
    };
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
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'produk_id': produkId,
      'jumlah': jumlah,
      'produk': produk?.toJson(),
    };
  }
}

// Order Model - DIPERBARUI SESUAI DATABASE
class Order {
  final int id;
  final int? userId;
  final int produkId;
  final String name;
  final String alamat;
  final String phone;
  final int jumlah;
  final int totalHarga; // Database menggunakan bigint, jadi int
  final String status;
  final String? statusPesanan;
  final String? orderIdMidtrans;
  final String? snapToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Produk? produk;
  final bool stokDikurangi;

  Order({
    required this.id,
    this.userId,
    required this.produkId,
    required this.name,
    required this.alamat,
    required this.phone,
    required this.jumlah,
    required this.totalHarga,
    required this.status,
    this.statusPesanan,
    this.orderIdMidtrans,
    this.snapToken,
    required this.createdAt,
    required this.updatedAt,
    this.produk,
    this.stokDikurangi = false,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] != null
          ? (json['user_id'] is int
              ? json['user_id']
              : int.tryParse(json['user_id'].toString()))
          : null,
      produkId: json['produk_id'] is int
          ? json['produk_id']
          : int.tryParse(json['produk_id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      alamat: json['alamat']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      jumlah: json['jumlah'] is int
          ? json['jumlah']
          : int.tryParse(json['jumlah'].toString()) ?? 0,
      totalHarga: json['total_harga'] is int
          ? json['total_harga']
          : int.tryParse(json['total_harga'].toString()) ?? 0,
      status: json['status']?.toString() ?? 'pending',
      statusPesanan: json['status_pesanan']?.toString(),
      orderIdMidtrans: json['order_id_midtrans']?.toString(),
      snapToken: json['snap_token']?.toString(),
      createdAt: DateTime.parse(json['created_at'].toString()),
      updatedAt: DateTime.parse(json['updated_at'].toString()),
      produk: json['produk'] != null ? Produk.fromJson(json['produk']) : null,
      stokDikurangi:
          json['stok_dikurangi'] == 1 || json['stok_dikurangi'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'produk_id': produkId,
      'name': name,
      'alamat': alamat,
      'phone': phone,
      'jumlah': jumlah,
      'total_harga': totalHarga,
      'status': status,
      'status_pesanan': statusPesanan,
      'order_id_midtrans': orderIdMidtrans,
      'snap_token': snapToken,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'produk': produk?.toJson(),
      'stok_dikurangi': stokDikurangi ? 1 : 0,
    };
  }
}

// UMKM Model - DIPERBARUI SESUAI DATABASE
class Umkm {
  final int id;
  final int userId;
  final String namaToko;
  final String? deskripsi;
  final String alamat;
  final String? noTelp;
  final String? logo;
  final String status;

  Umkm({
    required this.id,
    required this.userId,
    required this.namaToko,
    this.deskripsi,
    required this.alamat,
    this.noTelp,
    this.logo,
    required this.status,
  });

  factory Umkm.fromJson(Map<String, dynamic> json) {
    return Umkm(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      namaToko: json['nama_toko']?.toString() ?? '',
      deskripsi: json['deskripsi']?.toString(),
      alamat: json['alamat']?.toString() ?? '',
      noTelp: json['no_telp']?.toString(),
      logo: json['logo']?.toString(),
      status: json['status']?.toString() ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nama_toko': namaToko,
      'deskripsi': deskripsi,
      'alamat': alamat,
      'no_telp': noTelp,
      'logo': logo,
      'status': status,
    };
  }
}

// Extension untuk metode helper
extension OrderExtension on Order {
  bool get isPending => status == 'pending';
  bool get isComplete => status == 'complete';
  bool get isCancel => status == 'cancel';

  bool get isDikemas => statusPesanan == 'dikemas';
  bool get isDikirim => statusPesanan == 'dikirim';
  bool get isDiterima => statusPesanan == 'diterima';
  bool get isBelumDiterima => statusPesanan == 'belum_diterima';

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Menunggu Pembayaran';
      case 'complete':
        return 'Selesai';
      case 'cancel':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  String get statusPesananText {
    switch (statusPesanan) {
      case 'dikemas':
        return 'Sedang Dikemas';
      case 'dikirim':
        return 'Sedang Dikirim';
      case 'diterima':
        return 'Sudah Diterima';
      case 'belum_diterima':
        return 'Belum Diterima';
      default:
        return statusPesanan ?? 'Menunggu';
    }
  }
}
