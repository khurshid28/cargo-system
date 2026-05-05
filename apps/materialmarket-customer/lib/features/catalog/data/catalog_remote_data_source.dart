import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({required this.id, required this.nameUz, required this.icon});
  final String id;
  final String nameUz;
  final String icon;
  @override
  List<Object?> get props => [id];
}

class Product extends Equatable {
  const Product({
    required this.id,
    required this.nameUz,
    required this.merchantName,
    required this.unit,
    required this.price,
    required this.photo,
    required this.categoryId,
  });
  final String id;
  final String nameUz;
  final String merchantName;
  final String unit;
  final int price;
  final String photo;
  final String categoryId;
  @override
  List<Object?> get props => [id];
}

abstract class CatalogRemoteDataSource {
  Future<List<Category>> categories();
  Future<List<Product>> products({String? categoryId, String? q});
}

class CatalogRemoteDataSourceImpl implements CatalogRemoteDataSource {
  CatalogRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Category>> categories() async {
    final r = await _dio.get('/categories');
    return (r.data as List).map((e) => Category(
          id: e['id'],
          nameUz: e['nameUz'],
          icon: e['icon'] ?? '📦',
        )).toList();
  }

  @override
  Future<List<Product>> products({String? categoryId, String? q}) async {
    final r = await _dio.get('/products', queryParameters: {
      if (categoryId != null) 'categoryId': categoryId,
      if (q != null && q.isNotEmpty) 'q': q,
    });
    return (r.data as List)
        .map((e) => Product(
              id: e['id'],
              nameUz: e['nameUz'],
              merchantName: e['merchant']?['name'] ?? '',
              unit: e['unit'],
              price: (e['price'] as num).toInt(),
              photo: (e['photos'] as List?)?.firstOrNull as String? ?? '',
              categoryId: e['categoryId'],
            ))
        .toList();
  }
}

class CatalogMockDataSource implements CatalogRemoteDataSource {
  final _categories = const [
    Category(id: 'c1', nameUz: 'Ko‘mir', icon: '🪨'),
    Category(id: 'c2', nameUz: 'G‘isht', icon: '🧱'),
    Category(id: 'c3', nameUz: 'Shag‘al', icon: '⛰️'),
    Category(id: 'c4', nameUz: 'Sement', icon: '🏗️'),
    Category(id: 'c5', nameUz: 'Qum', icon: '🏖️'),
    Category(id: 'c6', nameUz: 'Yog‘och', icon: '🪵'),
  ];

  static const _img =
      'https://images.unsplash.com/photo-1519074069444-1ba4fff66d16?auto=format&fit=crop&w=600&q=70';

  late final List<Product> _products = [
    const Product(id: 'p1', nameUz: 'Toshkent ko‘miri', merchantName: 'KomirSavdo', unit: 'tonna', price: 1450000, photo: _img, categoryId: 'c1'),
    const Product(id: 'p2', nameUz: 'Qora ko‘mir AAA', merchantName: 'EnergoFuel', unit: 'tonna', price: 1620000, photo: _img, categoryId: 'c1'),
    const Product(id: 'p3', nameUz: 'Qizil g‘isht M-150', merchantName: 'GishtPro', unit: 'dona', price: 1800, photo: _img, categoryId: 'c2'),
    const Product(id: 'p4', nameUz: 'Silikat g‘isht', merchantName: 'GishtPro', unit: 'dona', price: 1450, photo: _img, categoryId: 'c2'),
    const Product(id: 'p5', nameUz: 'Maydalangan shag‘al 5-20', merchantName: 'Karyer-1', unit: 'm³', price: 320000, photo: _img, categoryId: 'c3'),
    const Product(id: 'p6', nameUz: 'Sement M-400', merchantName: 'Bekobod Sement', unit: 'qop', price: 58000, photo: _img, categoryId: 'c4'),
    const Product(id: 'p7', nameUz: 'Yuvilgan qum', merchantName: 'Karyer-2', unit: 'm³', price: 210000, photo: _img, categoryId: 'c5'),
    const Product(id: 'p8', nameUz: 'Qarag‘ay taxta 25mm', merchantName: 'YogochUz', unit: 'm³', price: 4200000, photo: _img, categoryId: 'c6'),
  ];

  @override
  Future<List<Category>> categories() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _categories;
  }

  @override
  Future<List<Product>> products({String? categoryId, String? q}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return _products.where((p) {
      if (categoryId != null && p.categoryId != categoryId) return false;
      if (q != null && q.isNotEmpty && !p.nameUz.toLowerCase().contains(q.toLowerCase())) return false;
      return true;
    }).toList();
  }
}
