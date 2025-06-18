import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

enum _MenuOptions {
  openWebsite,
}

class Menu extends StatelessWidget {
  const Menu({required this.controller, Key? key}) : super(key: key);

  final WebViewController controller;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_MenuOptions>(
      onSelected: (value) async {
        switch (value) {
          case _MenuOptions.openWebsite:
            final url = Uri.parse('https://ata-website.kampu.solutions');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            } else {
              // Handle error if URL can't be launched
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch $url')),
              );
            }
            break;
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<_MenuOptions>(
          value: _MenuOptions.openWebsite,
          child: Text('Open Our Website'),
        ),
      ],
    );
  }
}

class WebViewPage extends StatefulWidget {
  final String title;
  final String url;

  const WebViewPage({Key? key, required this.title, required this.url})
      : super(key: key);

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late WebViewController controller;
  int loadingPercentage = 0;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // 👈 Add this here
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            setState(() {
              loadingPercentage = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              loadingPercentage = progress;
            });
          },
          onPageFinished: (url) {
            setState(() {
              loadingPercentage = 100;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        actions: [
          Row(
            children: <Widget>[
              // IconButton(
              //   icon: const Icon(Icons.arrow_back_ios),
              //   onPressed: () async {
              //     final messenger = ScaffoldMessenger.of(context);
              //     if (await controller.canGoBack()) {
              //       await controller.goBack();
              //     } else {
              //       messenger.showSnackBar(
              //         const SnackBar(
              //           duration: Duration(milliseconds: 200),
              //           content: Text(
              //             'Can\'t go back',
              //             style: TextStyle(
              //                 fontSize: 20, fontWeight: FontWeight.bold),
              //           ),
              //         ),
              //       );
              //     }
              //   },
              // ),
              // IconButton(
              //   icon: const Icon(Icons.arrow_forward_ios),
              //   onPressed: () async {
              //     final messenger = ScaffoldMessenger.of(context);
              //     if (await controller.canGoForward()) {
              //       await controller.goForward();
              //     } else {
              //       messenger.showSnackBar(
              //         const SnackBar(
              //           duration: Duration(milliseconds: 200),
              //           content: Text(
              //             'No forward history item',
              //             style: TextStyle(
              //                 fontSize: 20, fontWeight: FontWeight.bold),
              //           ),
              //         ),
              //       );
              //     }
              //   },
              // ),
              IconButton(
                icon: const Icon(Icons.replay),
                onPressed: () {
                  controller.reload();
                },
              ),
              // Add your Menu here:
              Menu(controller: controller),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (loadingPercentage < 100)
            LinearProgressIndicator(
              color: Colors.red,
              value: loadingPercentage / 100.0,
            ),
        ],
      ),
    );
  }
}
