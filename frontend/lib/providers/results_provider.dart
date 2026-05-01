import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../services/api_service.dart';

final resultsProvider = FutureProvider<List<dynamic>>((ref) async {
  final response = await http.get(Uri.parse('${ApiService.baseUrl}/data/results/summary'));
  
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else {
    throw Exception('Failed to load election results');
  }
});
