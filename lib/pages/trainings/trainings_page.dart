import 'package:ata_new_app/components/cards/tab_card.dart';
import 'package:ata_new_app/pages/trainings/courses/courses_page.dart';
import 'package:ata_new_app/pages/trainings/documents/documents_page.dart';
import 'package:ata_new_app/pages/trainings/videos/video_playlist_page.dart';
import 'package:flutter/material.dart';

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 8, // Updated to match the number of tabs
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Theme.of(context).colorScheme.primary,
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: const Text(
            'Trainings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Column(
            children: [
              Row(
                children: [
                  const Expanded(
                    child: TabCard(
                      image: 'lib/assets/icons/document.png',
                      title: 'Documents',
                      isSelected: true,
                    ),
                  ),
                  Expanded(
                    child: TabCard(
                      image: 'lib/assets/icons/video_outline.png',
                      title: 'Videos',
                      onTap: () {
                        final route = MaterialPageRoute(
                            builder: (context) => const VideoPlayListPage());
                        Navigator.push(context, route);
                      },
                    ),
                  ),
                  Expanded(
                    child: TabCard(
                      image: 'lib/assets/icons/course_outline.png',
                      title: 'Courses',
                      onTap: () {
                        final route = MaterialPageRoute(
                            builder: (context) => const CoursesPage());
                        Navigator.push(context, route);
                      },
                    ),
                  ),
                ],
              ),
              // Start Epublications
              const Expanded(
                child: DocumentsPage(
                  isShowAppBar: false,
                  path: 'documents',
                ),
              ),
              // Expanded(
              //   child: ListView.builder(
              //     itemCount: 10,
              //     itemBuilder: (context, index) {
              //       return FolderCard(
              //         onTap: () {
              //           final route = MaterialPageRoute(
              //             builder: (context) => DocumentsPage(),
              //           );
              //           Navigator.push(context, route);
              //         },
              //       );
              //     },
              //   ),
              // ),
              // End Epublications
            ],
          ),
        ),
      ),
    );
  }
}
