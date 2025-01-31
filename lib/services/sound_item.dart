import 'dart:convert';

class SoundItem {
  final String name;
  final String avatar;
  final List<String> tags;
  final String soundFile;

  SoundItem({
    required this.name,
    required this.avatar,
    required this.tags,
    required this.soundFile,
  });

  // Convert SoundItem to JSON string
  String toJson() {
    return jsonEncode({
      'name': name,
      'avatar': avatar,
      'tags': tags,
      'soundFile': soundFile,
    });
  }

  // Convert JSON string to SoundItem
  factory SoundItem.fromJson(String jsonString) {
    final jsonData = jsonDecode(jsonString);
    print('Parsed JSON data: $jsonData'); // Debug print
    return SoundItem(
      name: jsonData['name'],
      avatar: jsonData['avatar'],
      tags: List<String>.from(jsonData['tags']),
      soundFile: jsonData['soundFile'],
    );
  }
}
