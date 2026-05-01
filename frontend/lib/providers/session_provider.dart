import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const _kSessionKey = 'civic_session_id';

/// Provides a stable UUID session ID for this browser session.
/// Persists in SharedPreferences so it survives hot reload and tab refresh.
final sessionProvider = FutureProvider<String>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  var id = prefs.getString(_kSessionKey);
  if (id == null || id.isEmpty) {
    id = const Uuid().v4();
    await prefs.setString(_kSessionKey, id);
  }
  return id;
});
