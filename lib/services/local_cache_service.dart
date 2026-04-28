import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import '../models/user_profile.dart';

class LocalCacheService {
  static const String cacheFileName = 'user_profiles.json';

  Future<File> _localFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$cacheFileName');
  }

  Future<void> saveProfiles(List<UserProfile> profiles) async {
    final file = await _localFile();
    final jsonList = profiles.map((p) => p.toMap()).toList();
    await file.writeAsString(jsonEncode(jsonList));
  }

  Future<List<UserProfile>> loadCachedProfiles() async {
    try {
      final file = await _localFile();
      if (!await file.exists()) return [];
      final contents = await file.readAsString();
      final parsed = jsonDecode(contents) as List<dynamic>;
      return parsed
          .map((item) => UserProfile.fromMap(Map<String, dynamic>.from(item)))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
