// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/course_card.dart';
import 'package:ata_new_app/models/course.dart';
import 'package:ata_new_app/pages/trainings/courses/course_detail_page.dart';
import 'package:ata_new_app/services/course_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  List<Course> courses = [];
  bool isLoadingCourses = true;
  bool isLoadingCoursesError = false;
  bool hasMoreCourses = true;
  bool isLoadingMore = false;
  int currentPage = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getCourses();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        loadMoreCourses();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getCourses() async {
    try {
      final fetchedCourses = await CourseService.fetchCourses(page: 1);
      setState(() {
        courses = fetchedCourses;
        isLoadingCourses = false;
      });
    } catch (error) {
      setState(() {
        isLoadingCourses = false;
        isLoadingCoursesError = true;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load Courses'),
        ),
      );
    }
  }

  Future<void> loadMoreCourses() async {
    if (!hasMoreCourses || isLoadingMore) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      currentPage++;
      final fetchedCourses =
          await CourseService.fetchCourses(page: currentPage);

      setState(() {
        courses.addAll(fetchedCourses);
        isLoadingMore = false;
      });

      if (fetchedCourses.isEmpty) {
        hasMoreCourses = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No more Data!'),
          ),
        );
      }
    } catch (error) {
      setState(() {
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load Data'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          'Courses'.tr(),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: isLoadingCourses
          ? Center(
              child: CircularProgressIndicator(),
            )
          : courses.isNotEmpty
              ? SafeArea(
                  child: Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          // SliverToBoxAdapter(
                          //   child: MySearch(),
                          // ),
                          SliverPadding(
                            padding: EdgeInsets.all(0.0),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1, // Number of columns
                                childAspectRatio:
                                    1.5, // Aspect ratio of the grid items
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final course = courses[index];
                                  return CourseCard(
                                    aspectRatio: 17 / 9,
                                    width: double.infinity,
                                    id: course.id,
                                    title: course.name,
                                    imageUrl: course.imageUrl,
                                    onTap: () {
                                      final route = MaterialPageRoute(
                                        builder: (context) => CourseDetailPage(
                                          course: course,
                                        ),
                                      );
                                      Navigator.push(context, route);
                                    },
                                  );
                                },
                                childCount: courses.length,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isLoadingMore)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : Center(
                  child: Text('No Data'.tr()),
                ),
    );
  }
}
