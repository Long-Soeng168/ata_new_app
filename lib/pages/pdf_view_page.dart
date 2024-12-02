import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfViewPage extends StatefulWidget {
  final String url;

  PdfViewPage(
      {this.url =
          'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf'});

  @override
  _PdfViewPageState createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  String? _localFilePath;
  bool _isLoading = true;
  int _totalPages = 0;
  int _currentPage = 1;
  final TextEditingController _pageController = TextEditingController();

  late PDFViewController _pdfViewController;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      var response = await Dio()
          .get(widget.url, options: Options(responseType: ResponseType.bytes));
      var dir = await getApplicationDocumentsDirectory();
      File file = File('${dir.path}/downloaded.pdf');
      await file.writeAsBytes(response.data);
      setState(() {
        _localFilePath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      print("Error downloading PDF: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _jumpToPage(int page) {
    if (page >= 0 && page < _totalPages) {
      _pageController.clear();
      _pdfViewController.setPage(page);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Invalid page number.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PDF View',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isLoading && _totalPages > 0)
            Padding(
              padding: const EdgeInsets.only(right: 32),
              child: Center(child: Text('$_currentPage/$_totalPages')),
            ),
          Container(
            width: 60,
            color: Colors.grey.shade100,
            child: TextField(
              controller: _pageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                hintText: "Page",
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              String input = _pageController.text;
              int? page = int.tryParse(input);
              if (page != null) {
                _jumpToPage(page - 1);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Please enter a valid number.'),
                ));
              }
            },
            child: Text('Go'),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _localFilePath != null
              ? PDFView(
                  enableSwipe: true,
                  autoSpacing: false,
                  pageFling: false,
                  filePath: _localFilePath,
                  onRender: (_pages) {
                    setState(() {
                      _totalPages = _pages!;
                    });
                  },
                  onViewCreated: (PDFViewController vc) {
                    _pdfViewController = vc;
                  },
                  onPageChanged: (page, total) {
                    setState(() {
                      _currentPage = page! + 1;
                    });
                  },
                )
              : Center(child: Text("Failed to load PDF")),
    );
  }
}
