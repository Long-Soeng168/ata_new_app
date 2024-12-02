// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/detail_list_card.dart';
import 'package:ata_new_app/components/my_gallery.dart';
import 'package:ata_new_app/models/course.dart';
import 'package:ata_new_app/services/course_service.dart';
import 'package:flutter/material.dart';

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({super.key, required this.course});
  final Course course;

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  late List<String> imageUrls = [];

  late Course courseDetail;
  bool isLoadingCourseDetail = true;
  bool isLoadingCourseDetailError = false;

  @override
  void initState() {
    super.initState();
    imageUrls.add(widget.course.imageUrl);
    getResource();
  }

  void getResource() {
    getCourseDetail();
  }

  Future<void> getCourseDetail() async {
    try {
      // Fetch courses outside of setState
      final fetchedCourseDetail =
          await CourseService.fetchCourseById(id: widget.course.id);
      // Update the state
      setState(() {
        courseDetail = fetchedCourseDetail;
        isLoadingCourseDetail = false;
      });
      // print(fetchedCourseDetail.imagesUrls[0]);
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingCourseDetail = false;
        isLoadingCourseDetailError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Product Detail : $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.transparent,
        title: Text(
          'Course',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(
        //       Icons.favorite,
        //       size: 32,
        //     ),
        //   ),
        // ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========================= Start Images =========================
                MyGallery(imageUrls: imageUrls),
                // ========================= End Images =========================

                // ========================= Start Detail =========================
                isLoadingCourseDetail
                    ? Container(
                        height: 400,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Text(
                                courseDetail.name,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                '${courseDetail.price} \$',
                                style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent),
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Column(children: [ 
                              Visibility(
                                visible: courseDetail.start != '',
                                child: DetailListCard(
                                  keyword: 'Start',
                                  value: '${courseDetail.start}',
                                ),
                              ), 
                              Visibility(
                                visible: courseDetail.end != '',
                                child: DetailListCard(
                                  keyword: 'End',
                                  value: '${courseDetail.end}',
                                ),
                              ), 
                              ListTile(
                                contentPadding: EdgeInsets.all(2),
                                title: Text(
                                  'Description',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(courseDetail.description),
                              ),
                            ])
                          ],
                        ),
                      ),

                // ========================= End Detail =========================
              ],
            ),
          ),
        ],
      ),
    );
  }
}
