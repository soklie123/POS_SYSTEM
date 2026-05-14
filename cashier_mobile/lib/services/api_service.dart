import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1/cashier';
  static const _storage = FlutterSecureStorage();

  // ── Read token from secure storage ────────
  static Future<Map<String, String>> get _headers async {
    final token = await _storage.read(key: 'auth_token');

    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Connection': 'keep-alive',
    };
  }

  static String fixImageUrl(String url) {
    return url.replaceAll('http://127.0.0.1:8000/', 'http://10.0.2.2:8000/');
  }

  // ── Get Products ──────────────────────────
  static Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
  }) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (category != null && category != 'all') params['category'] = category;

    final uri = Uri.parse('$baseUrl/products').replace(queryParameters: params);

    final response = await http.get(uri, headers: await _headers);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List)
          .map((e) => ProductModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Get Categories
  static Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/categories'),
      headers: await _headers,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List)
          .map((e) => CategoryModel.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // ── Create Order ──────────────────────────
  static Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required double discount,
    required String paymentMethod,
    required double amountReceived,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/orders'),
      headers: await _headers,
      body: jsonEncode({
        'items': items,
        'discount': discount,
        'payment_method': paymentMethod,
        'amount_received': amountReceived,
      }),
    );

    print('Create Order Response Status: ${response.statusCode}');
    print('Create Order Response Body: ${response.body}');

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return json['data'] ?? json;
    } else {
      final json = jsonDecode(response.body);
      throw Exception(json['message'] ?? 'Failed to create order');
    }
  }

  // ── Get Orders History ──────────────────────────
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: await _headers,
      );

      print('Get Orders Response Status: ${response.statusCode}');
      print('Get Orders Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        // Handle different response formats
        if (json.containsKey('data') && json['data'] is List) {
          return List<Map<String, dynamic>>.from(json['data']);
        } else if (json is List) {
          return List<Map<String, dynamic>>.from(json);
        } else {
          return [];
        }
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please login again.');
      } else {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? 'Failed to load orders');
      }
    } catch (e) {
      print('Error loading orders: $e');
      throw Exception('Failed to load orders: $e');
    }
  }

  // ── Get Single Order Details ────────────────────
  static Future<Map<String, dynamic>> getOrder(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$orderId'),
        headers: await _headers,
      );

      print('Get Order Detail Status: ${response.statusCode}');
      print('Get Order Detail Body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Map<String, dynamic>.from(json['data'] ?? json);
      } else {
        throw Exception('Failed to load order details');
      }
    } catch (e) {
      throw Exception('Failed to load order details: $e');
    }
  }

  // ── Cancel Order ────────────────────────────────
  static Future<void> cancelOrder(String orderId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/orders/$orderId/cancel'),
        headers: await _headers,
      );

      print('Cancel Order Status: ${response.statusCode}');
      print('Cancel Order Body: ${response.body}');

      if (response.statusCode != 200) {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? 'Failed to cancel order');
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  // ── Retry Sync Order ────────────────────────────
  static Future<void> retrySyncOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders/$orderId/retry-sync'),
        headers: await _headers,
      );

      print('Retry Sync Status: ${response.statusCode}');
      print('Retry Sync Body: ${response.body}');

      if (response.statusCode != 200) {
        final json = jsonDecode(response.body);
        throw Exception(json['message'] ?? 'Failed to retry sync');
      }
    } catch (e) {
      throw Exception('Failed to retry sync: $e');
    }
  }
}