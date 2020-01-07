class User {
  final int id;
  final String login;
  final String name;
  final String bio;
  final String avatarUrl;

  User({this.id, this.login, this.name, this.bio, this.avatarUrl});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      login: json['login'],
      name: json['name'],
      bio: json['bio'],
      avatarUrl: json['avatar_url'],
    );
  }
}
