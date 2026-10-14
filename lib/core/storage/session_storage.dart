import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SessionStorage {
  SessionStorage({this.fileName = 'family_guard_auth_session.json'});

  final String fileName;

  Future<Map<String, dynamic>?> readJson() async {
    final file = await _file;
    if (!await file.exists()) {
      return null;
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return decoded.map((key, value) => MapEntry(key.toString(), value));
    }

    return null;
  }

  Future<void> writeJson(Map<String, dynamic> json) async {
    final file = await _file;
    await file.writeAsString(jsonEncode(json));
  }

  Future<void> clear() async {
    final file = await _file;
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<File> get _file async {
    final directory = await getApplicationSupportDirectory();
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    return File('${directory.path}${Platform.pathSeparator}$fileName');
  }
}
