import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

// Provider for the full list of constituencies
final constituenciesListProvider = FutureProvider<List<String>>((ref) async {
  final response = await http.get(Uri.parse('${ApiService.baseUrl}/data/constituencies'));
  if (response.statusCode == 200) {
    return List<String>.from(json.decode(response.body));
  } else {
    throw Exception('Failed to load constituencies');
  }
});

// State provider for the currently selected constituency
final selectedConstituencyNameProvider = StateProvider<String?>((ref) => null);

// Provider for specific constituency details
final constituencyDetailsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final name = ref.watch(selectedConstituencyNameProvider);
  if (name == null) return null;

  final response = await http.get(Uri.parse('${ApiService.baseUrl}/data/results/constituency/$name'));
  if (response.statusCode == 200) {
    return json.decode(response.body);
  } else if (response.statusCode == 404) {
    return null;
  } else {
    throw Exception('Failed to load constituency details');
  }
});
