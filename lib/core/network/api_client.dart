import 'dart:async';
import 'dart:convert';

import 'package:family_guard/core/network/api_constants.dart';
import 'package:family_guard/core/network/api_exception.dart';
import 'package:http/http.dart' as http;

abstract class AuthTokenProvider {
  Future<String?> getAccessToken();
}

class ApiClient {
  ApiClient({
    required AuthTokenProvider tokenProvider,
    http.Client? client,
    String? baseUrl,
  }) : _tokenProvider = tokenProvider,
       _client = client ?? http.Client(),
       _baseUrl = baseUrl ?? ApiConstants.androidEmulatorBaseUrl;

  final AuthTokenProvider _tokenProvider;
  final http.Client _client;
  final String _baseUrl;

  Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'GET',
      path: path,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'POST',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'PATCH',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'PUT',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) {
    return _send(
      method: 'DELETE',
      path: path,
      body: body,
      requiresAuth: requiresAuth,
    );
  }

  Future<dynamic> _send({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? queryParameters,
    required bool requiresAuth,
  }) async {
    final uri = Uri.parse('$_baseUrl$path').replace(
      queryParameters: queryParameters == null || queryParameters.isEmpty
          ? null
          : queryParameters,
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if (requiresAuth) {
      final token = await _tokenProvider.getAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    late final http.Response response;

    try {
      final encodedBody = body == null ? null : jsonEncode(body);
      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: headers)
              .timeout(ApiConstants.requestTimeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encodedBody)
              .timeout(ApiConstants.requestTimeout);
          break;
        case 'PATCH':
          response = await _client
              .patch(uri, headers: headers, body: encodedBody)
              .timeout(ApiConstants.requestTimeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encodedBody)
              .timeout(ApiConstants.requestTimeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: headers, body: encodedBody)
              .timeout(ApiConstants.requestTimeout);
          break;
        default:
          throw ApiException(message: 'HTTP method $method is not supported.');
      }
    } on TimeoutException {
      throw const ApiException(message: 'Request timeout. Vui long thu lai.');
    }

    final decodedBody = _decodeBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody is Map<String, dynamic> &&
          decodedBody.containsKey('data')) {
        return decodedBody['data'];
      }
      return decodedBody;
    }

    throw ApiException(
      message:
          _extractMessage(decodedBody) ??
          'Request failed with status ${response.statusCode}.',
      statusCode: response.statusCode,
      details: decodedBody,
    );
  }

  dynamic _decodeBody(String raw) {
    if (raw.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic> || decoded is List) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }

    return decoded;
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    return null;
  }
}
