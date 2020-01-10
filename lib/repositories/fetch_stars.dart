import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:github_viewer/models/star.dart';

Future<List<Star>> fetchStars({int page = 1}) async {
//    final http.Response response = await http.get('https://api.github.com/users/${user.login}/starred?page=$page');
  final url = 'http://192.168.0.103:3000/stars?_limit=5&_page=$page';
  print('url : ${url}');
  final http.Response response = await http.get(url);

  if (response.statusCode != 200) {
    throw HttpException('Error. Try Again Later');
  }

  final List parsedStars = json.decode(response.body);

  final List<Star> stars = parsedStars.map((star) => Star.fromJson(star)).toList();

  return stars;
}