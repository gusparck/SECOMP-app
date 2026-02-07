import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  group('Backend Integration Tests', () {
    test('Should connect to backend health check endpoint', () async {
      // Assuming backend is running on localhost:3000 mapped by docker-compose
      final response = await http.get(
        Uri.parse('http://localhost:3000/health'),
      );

      expect(response.statusCode, 200);

      final body = jsonDecode(response.body);
      expect(body['status'], 'ok');
    });
  });
}
