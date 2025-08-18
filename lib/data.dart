import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<void> saveTasks(Map<String, String> tasks) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File("${directory.path}/tasks.json");
  final jsonString = jsonEncode(tasks);
  await file.writeAsString(jsonString);
}

Future<Map<String, String>> loadTasks() async {
  try {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/tasks.json');

    if (await file.exists()) {
      final jsonString = await file.readAsString();
      final Map<String, dynamic> decoded = jsonDecode(jsonString);

      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } else {
      return {};
    }
  } catch (e) {
    print("Error loading tasks: $e");
    return {};
  }
}
