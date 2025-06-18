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
                        : 'Documents',
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
                  // Search input
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 18),
                    child: TextFormField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search',
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
                                  builder: (context) => DocumentsPage(
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
                                  builder: (context) => PdfViewPage(
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
