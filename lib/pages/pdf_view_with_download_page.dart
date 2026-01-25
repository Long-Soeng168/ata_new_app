import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class PdfViewWithDonwloadPage extends StatefulWidget {
  final String url;

  const PdfViewWithDonwloadPage({
    super.key,
    this.url =
        'https://www.adobe.com/support/products/enterprise/knowledgecenter/media/c4611_sample_explain.pdf',
  });

  @override
  _PdfViewWithDonwloadPageState createState() =>
      _PdfViewWithDonwloadPageState();
}

class _PdfViewWithDonwloadPageState extends State<PdfViewWithDonwloadPage> {
  String? _localFilePath;
  bool _isLoading = true;
  double _progress = 0;
  int _totalPages = 0;
  int _currentPage = 1;

  late PDFViewController _pdfViewController;

  @override
  void initState() {
    super.initState();
    _downloadAndSavePdf();
  }

  Future<void> _downloadAndSavePdf() async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/temp_view.pdf');

      // Enhanced download with progress tracking
      await Dio().download(
        widget.url,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            setState(() => _progress = received / total);
          }
        },
      );

      setState(() {
        _localFilePath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadToDeviceStorage() async {
    if (_localFilePath == null) return;
    try {
      final params = SaveFileDialogParams(sourceFilePath: _localFilePath!);
      final filePath = await FlutterFileDialog.saveFile(params: params);
      if (filePath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Saved to your device!'),
              behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      debugPrint("Save error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Contrasts with white PDF pages
      appBar: AppBar(
        title: const Text('PDF View', style: TextStyle(fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: _isLoading ? null : _downloadToDeviceStorage,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isLoading ? _buildLoadingUI() : _buildPdfUI(),
      ),
    );
  }

  // A more polished loading screen
  Widget _buildLoadingUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(strokeWidth: 3),
            const SizedBox(height: 20),
            Text("Preparing PDF... ${(_progress * 100).toInt()}%"),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(value: _progress, minHeight: 6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPdfUI() {
    if (_localFilePath == null)
      return const Center(child: Text("Failed to load"));

    return Stack(
      children: [
        PDFView(
          filePath: _localFilePath,
          enableSwipe: true,
          autoSpacing: false, // Per your requirement
          pageFling: false, // Per your requirement
          onRender: (pages) => setState(() => _totalPages = pages!),
          onViewCreated: (vc) => _pdfViewController = vc,
          onPageChanged: (page, total) =>
              setState(() => _currentPage = page! + 1),
        ),

        // Floating Page Indicator
        if (_totalPages > 0)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
