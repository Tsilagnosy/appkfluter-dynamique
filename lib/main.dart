import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const WebViewDynamicUrlApp());
}

class WebViewDynamicUrlApp extends StatelessWidget {
  const WebViewDynamicUrlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewHome(),
    );
  }
}

class WebViewHome extends StatefulWidget {
  const WebViewHome({super.key});

  @override
  State<WebViewHome> createState() => _WebViewHomeState();
}

class _WebViewHomeState extends State<WebViewHome> {
  String? siteUrl;
  bool loading = true;
  String? errorMessage;

  final String configUrl = "https://tsilagnosy.github.io/trackage-site/config.json"; // Change ici

  @override
  void initState() {
    super.initState();
    fetchSiteUrl();
  }

  Future<void> fetchSiteUrl() async {
    try {
      final response = await http.get(Uri.parse(configUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          siteUrl = data['url'];
          loading = false;
        });
      } else {
        setState(() {
          errorMessage = "Erreur de chargement du fichier de configuration.";
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Impossible de récupérer l'URL.\n$e";
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(errorMessage!)),
      );
    }
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(
          controller: WebViewController()
            ..setJavaScriptMode(JavaScriptMode.unrestricted)
            ..loadRequest(Uri.parse(siteUrl!)),
        ),
      ),
    );
  }
}
