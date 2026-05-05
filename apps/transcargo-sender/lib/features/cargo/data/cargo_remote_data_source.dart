import 'package:dio/dio.dart';

abstract class CargoRemoteDataSource {
  Future<List<Map<String, dynamic>>> myRequests();
  Future<Map<String, dynamic>> create(Map<String, dynamic> body);
}

class CargoRemoteDataSourceImpl implements CargoRemoteDataSource {
  CargoRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<List<Map<String, dynamic>>> myRequests() async {
    final res = await _dio.get('/cargo-requests/mine');
    return List<Map<String, dynamic>>.from(res.data as List);
  }

  @override
  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final res = await _dio.post('/cargo-requests', data: body);
    return Map<String, dynamic>.from(res.data as Map);
  }
}
