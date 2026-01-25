import 'package:ata_new_app/components/cards/folder_card.dart';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/document.dart';
import 'package:ata_new_app/pages/app_info/web_view_page.dart';
import 'package:ata_new_app/pages/auth/login_page.dart';
import 'package:ata_new_app/pages/main_page.dart';
import 'package:ata_new_app/pages/pdf_view_with_download_page.dart';
import 'package:ata_new_app/services/document_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class DocumentsForDownloadPage extends StatefulWidget {
  const DocumentsForDownloadPage(
      {super.key, this.isShowAppBar = true, this.path = ''});

  final bool isShowAppBar;
  final String path;

  @override
  State<DocumentsForDownloadPage> createState() =>
      _DocumentsForDownloadPageState();
}

class _DocumentsForDownloadPageState extends State<DocumentsForDownloadPage> {
  late Document documentObjects =
      Document(folders: [], files: [], status: 'unknown');
  bool isLoadingDocuments = true;
  bool isLoadingDocumentsError = false;

  final TextEditingController _searchController = TextEditingController();
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    getDocuments();
  }

  @override
  void dispose() {
    FocusScope.of(context).unfocus();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> getDocuments() async {
    try {
      final Document fetchedPublications;
      if (widget.path != '') {
        fetchedPublications =
            await DocumentService.fetchDocuments(path: widget.path);
      } else {
        fetchedPublications = await DocumentService.fetchDocuments();
      }
      setState(() {
        documentObjects = fetchedPublications;
        isLoadingDocuments = false;
      });
      // after loading, check status

      if (widget.path.isNotEmpty && widget.path != 'Documents') {
        // print(widget.path);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkDocumentStatus();
        });
      }
    } catch (error) {
      setState(() {
        isLoadingDocuments = false;
        isLoadingDocumentsError = true;
      });
      print('Failed to load Documents: $error');
    }
  }

  List<String> get filteredFolders {
    if (searchQuery.isEmpty) return documentObjects.folders;
    return documentObjects.folders
        .where((item) => item
            .split('/')
            .last
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
  }

  List<String> get filteredFiles {
    if (searchQuery.isEmpty) return documentObjects.files;
    return documentObjects.files
        .where((item) => item
            .split('/')
            .last
            .toLowerCase()
            .contains(searchQuery.toLowerCase()))
        .toList();
  }

  void _checkDocumentStatus() {
    final status = (documentObjects.status ?? '').toLowerCase();
    if (status.isEmpty) return;
    // print(status);

    IconData icon;
    Color iconColor;
    String message;

    switch (status) {
      case 'need_login':
        icon = Icons.lock;
        iconColor = Colors.orange;
        message = "You need to log in to access these documents.".tr();
        break;
      case 'need_purchase':
        icon = Icons.shopping_cart;
        iconColor = Colors.red;
        message =
            "You need to purchase access before reading these documents.".tr();
        break;
      case 'can_read':
        return; // no popup, user can access directly
      default:
        return; // unknown status, skip
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(icon, color: iconColor, size: 28),
              const SizedBox(width: 8),
              Text(
                "Document Access".tr(),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message, style: const TextStyle(fontSize: 16, height: 1.4)),
            ],
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          actions: [
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
              ),
              onPressed: () {
                // TODO: replace with real contact navigation
                // ScaffoldMessenger.of(context).showSnackBar(
                //   SnackBar(content: Text("Redirecting to Contact Us...")),
                // );
                final route = MaterialPageRoute(
                    builder: (context) => WebViewPage(
                          title: 'Contact Us'.tr(),
                          url: 'https://atech-auto.com/contact-us-webview',
                        ));
                Navigator.push(context, route);
              },
              icon: Icon(Icons.support_agent, size: 18),
              label: Text("Contact Us".tr()),
            ),
            if (status == 'need_login')
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).primaryColor, // always fixed color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
                icon: const Icon(Icons.login, color: Colors.white, size: 18),
                label: Text(
                  "Login".tr(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).primaryColor, // always fixed color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MainPage()),
                );
              },
              icon: const Icon(Icons.home, color: Colors.white, size: 18),
              label: Text(
                "Back to Home".tr(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: widget.isShowAppBar
              ? AppBar(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: Text(
                    widget.path.isNotEmpty
                        ? widget.path.split('~').last
                        : 'Documents For Download'.tr(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              child: Column(
                children: [
                  // Search input
                  Visibility(
                    visible: widget.path != 'Documents For Download',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 18),
                      child: TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search...'.tr(),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ),
                  ),

                  if (isLoadingDocuments)
                    const SizedBox(
                      height: 200,
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),

                  if (!isLoadingDocuments)
                    Visibility(
                      visible: filteredFolders.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          children: filteredFolders.map((item) {
                            return FolderCard(
                              isFolder: true,
                              name: item.split('/').last,
                              onTap: () {
                                final route = MaterialPageRoute(
                                  builder: (context) =>
                                      DocumentsForDownloadPage(
                                    path: item.replaceAll('/', '~'),
                                  ),
                                );
                                Navigator.push(context, route);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                  if (!isLoadingDocuments)
                    Visibility(
                      visible: filteredFiles.isNotEmpty,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          children: filteredFiles
                              .where((item) => item.endsWith('.pdf'))
                              .map((item) {
                            return FolderCard(
                              isFolder: false,
                              name: item.split('/').last,
                              onTap: () {
                                final route = MaterialPageRoute(
                                  builder: (context) => PdfViewWithDonwloadPage(
                                    url: '${Env.basePdfUrl}$item',
                                  ),
                                );
                                Navigator.push(context, route);
                              },
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
