import 'package:github_viewer/models/user.dart';

class Star {
  final int id;
  final String name;
  final User owner;

  Star({this.id, this.name, this.owner});

  factory Star.fromJson(Map<String, dynamic> json) {
    return Star(
      id: json['id'],
      name: json['name'],
      owner: User.fromJson(json['owner']),
    );
  }
}