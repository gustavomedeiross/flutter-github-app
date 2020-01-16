import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RepositoryDetail extends StatelessWidget {
  final String repository;

  RepositoryDetail({@required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(repository),
      ),
      body: Container(
        child: WebView(
          initialUrl: 'https://github.com/$repository',
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
