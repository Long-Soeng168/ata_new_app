import 'package:ata_new_app/components/cards/folder_card.dart';
import 'package:ata_new_app/config/env.dart';
import 'package:ata_new_app/models/document.dart';
import 'package:ata_new_app/pages/pdf_view_page.dart';
import 'package:ata_new_app/services/document_service.dart';
import 'package:flutter/material.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key, this.isShowAppBar = true, this.path = ''});

  final bool isShowAppBar;
  final String path;

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  late Document documentObjects = Document(folders: [], files: []);
  bool isLoadingDocuments = true;
  bool isLoadingDocumentsError = false;

  @override
  void initState() {
    super.initState();
    getDocuments();
  }

  Future<void> getDocuments() async {
    try {
      // Fetch publications outside of setState
      final Document fetchedPublications;
      if (widget.path != '') {
        fetchedPublications =
            await DocumentService.fetchDocuments(path: widget.path);
      } else {
        fetchedPublications = await DocumentService.fetchDocuments();
      }
      // print(fetchedPublications);
      // Update the state
      setState(() {
        documentObjects = fetchedPublications;
        isLoadingDocuments = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingDocuments = false;
        isLoadingDocumentsError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Documents: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8, // Updated to match the number of tabs
      child: Scaffold(
        appBar: widget.isShowAppBar
            ? AppBar(
                foregroundColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text(
                  widget.path.isNotEmpty ? widget.path.split('~').last : 'Documents',
                  style: const TextStyle(
                    fontSize: 24,
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
                if (isLoadingDocuments)
                  const SizedBox(
                    height: 200,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                if (!isLoadingDocuments)
                  Visibility(
                    visible: documentObjects.folders.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        children: documentObjects.folders.map((item) {
                          return FolderCard(
                            isFolder: true,
                            name: item.split('/').last,
                            onTap: () {
                              final route = MaterialPageRoute(
                                builder: (context) => DocumentsPage(
                                  path: item.replaceAll('/', '~'),
                                ),
                              );
                              Navigator.push(context, route);
                            },
                          );
                        }).toList(), // Convert the Iterable to a List of Widgets
                      ),
                    ),
                  ),
                if (!isLoadingDocuments)
                  Visibility(
                    visible: documentObjects.files.isNotEmpty,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        children: documentObjects.files
                            .where((item) => item.endsWith(
                                '.pdf')) // Filter to include only PDF files
                            .map((item) {
                          return FolderCard(
                            isFolder: false,
                            name: item.split('/').last,
                            onTap: () {
                              final route = MaterialPageRoute(
                                builder: (context) => PdfViewPage(
                                  url: '${Env.basePdfUrl}$item',
                                ),
                              );
                              Navigator.push(context, route);
                            },
                          );
                        }).toList(), // Convert the Iterable to a List of Widgets
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
