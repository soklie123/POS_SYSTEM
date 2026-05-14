import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1';
  static const _storage = FlutterSecureStorage();

  static Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: 'admin_token');
    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  static Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      await _storage.write(key: 'admin_token', value: json['token']);
    } else {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Login failed');
    }
  }

  static Future<void> logout() async {
    await _storage.delete(key: 'admin_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'admin_token');
    return token != null;
  }

  static Future<List<dynamic>> getProducts({String? search}) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$baseUrl/admin/products').replace(queryParameters: params);
    final response = await http.get(uri, headers: await _headers);

    print('Products Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('Products Response: $json');
      // Your API returns { "data": [...] }
      if (json.containsKey('data')) {
        return json['data'];
      }
      return json;
    }
    throw Exception('Failed to load products: ${response.statusCode}');
  }

  static Future<void> createProduct({
    required String name,
    required String description,
    required int categoryId,
    required double price,
    required int stock,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final token = await _storage.read(key: 'admin_token');
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/admin/products'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['category_id'] = categoryId.toString();
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['is_active'] = '1';

    if (imageBytes != null && imageName != null) {
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 201) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to create product');
    }
  }

  static Future<void> updateProduct({
    required int id,
    required String name,
    required String description,
    required int categoryId,
    required double price,
    required int stock,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    final token = await _storage.read(key: 'admin_token');
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/admin/products/$id'));
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['category_id'] = categoryId.toString();
    request.fields['price'] = price.toString();
    request.fields['stock'] = stock.toString();
    request.fields['is_active'] = '1';
    request.fields['_method'] = 'PUT';

    if (imageBytes != null && imageName != null) {
      request.files.add(http.MultipartFile.fromBytes('image', imageBytes, filename: imageName));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to update product');
    }
  }

  static Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/products/$id'),
      headers: await _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product');
    }
  }

  static Future<List<dynamic>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/categories'),
      headers: await _headers,
    );
    
    print('Categories Response Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      print('Categories Response: $json');
      // Your API returns { "data": [...] }
      if (json.containsKey('data')) {
        return json['data'];
      }
      return json;
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }

  static Future<void> createCategory(String name, {String? color}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/categories'),
      headers: await _headers,
      body: jsonEncode({'name': name, 'color': color ?? '#FF6B00'}),
    );
    if (response.statusCode != 201) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to create category');
    }
  }

  static Future<void> updateCategory(int id, String name, {String? color}) async {
    final response = await http.put(
      Uri.parse('$baseUrl/admin/categories/$id'),
      headers: await _headers,
      body: jsonEncode({'name': name, 'color': color ?? '#FF6B00'}),
    );
    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to update category');
    }
  }

  static Future<void> deleteCategory(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/admin/categories/$id'),
      headers: await _headers,
    );
    if (response.statusCode != 200) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to delete category');
    }
  }

  static Future<Map<String, dynamic>> getOrders({int page = 1, String? search}) async {
    final params = <String, String>{'page': page.toString()};
    if (search != null && search.isNotEmpty) params['search'] = search;

    final uri = Uri.parse('$baseUrl/admin/orders').replace(queryParameters: params);
    final response = await http.get(uri, headers: await _headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load orders');
  }

  static Future<List<dynamic>> getUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/users'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['data'];
    }
    throw Exception('Failed to load users');
  }

  static Future<void> createUser({required String name, required String email, required String password}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/users'),
      headers: await _headers,
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (response.statusCode != 201) {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to create user');
    }
  }

  static Future<Map<String, dynamic>> getDashboard() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/dashboard'),
      headers: await _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Failed to load dashboard');
  }
}