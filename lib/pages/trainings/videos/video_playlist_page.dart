// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/video_playlist_card.dart';
import 'package:ata_new_app/components/my_search.dart';
import 'package:ata_new_app/models/video_playlist.dart';
import 'package:ata_new_app/pages/trainings/videos/cart/video_cart_page.dart';
import 'package:ata_new_app/pages/trainings/videos/video_playlist_detail_page.dart';
import 'package:ata_new_app/providers/cart_provider.dart';
import 'package:ata_new_app/services/video_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoPlayListPage extends StatefulWidget {
  const VideoPlayListPage({super.key});

  @override
  State<VideoPlayListPage> createState() => _VideoPlayListPageState();
}

class _VideoPlayListPageState extends State<VideoPlayListPage> {
  List<VideoPlaylist> videoPlaylists = [];
  bool isLoadingVideoPlaylists = true;
  bool isLoadingVideoPlaylistsError = false;
  String? search;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getVideoPlaylists();
  }

  Future<void> getVideoPlaylists() async {
    try {
      final fetchedVideoPlaylists =
          await VideoService.fetchVideoPlaylists(search: search);
      // print(fetchedVideos);
      setState(() {
        videoPlaylists = fetchedVideoPlaylists;
        isLoadingVideoPlaylists = false;
      });
    } catch (error) {
      setState(() {
        isLoadingVideoPlaylists = false;
        isLoadingVideoPlaylistsError = true;
      });
      print('Failed to load Videos: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'Videos Trainings',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   Stack(
        //     children: [
        //       IconButton(
        //         onPressed: () {
        //           final route = MaterialPageRoute(
        //             builder: (context) => VideoCartPage(),
        //           );
        //           Navigator.push(context, route);
        //         },
        //         icon: Icon(
        //           Icons.shopping_cart_outlined,
        //           size: 32,
        //         ),
        //       ),
        //       if (cartProvider.totalItems() > 0)
        //         Positioned(
        //           right: 0,
        //           top: 0,
        //           child: CircleAvatar(
        //             radius: 10,
        //             backgroundColor: Colors.red,
        //             child: Text(
        //               cartProvider.totalItems().toString(),
        //               style: TextStyle(fontSize: 14, color: Colors.white),
        //             ),
        //           ),
        //         ),
        //     ],
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Start Search
            MySearch(
              placeholder: 'Search...',
              searchController: _searchController,
              onSearchSubmit: () {
                setState(() {
                  search = _searchController.text;
                  isLoadingVideoPlaylists = true;
                });
                getVideoPlaylists(); // Refetch with search query
              },
            ),
            // End Search

            SizedBox(height: 8),

            // Start Videos
            isLoadingVideoPlaylists
                ? SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Visibility(
                    visible: videoPlaylists.isNotEmpty,
                    child: Column(
                      children: [
                        GridView.builder(
                          shrinkWrap:
                              true, // Important: Let GridView take up only needed space
                          physics:
                              NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1, // Number of columns
                            childAspectRatio:
                                1.23, // Aspect ratio of the grid items
                          ),
                          itemCount: videoPlaylists.length,
                          itemBuilder: (context, index) {
                            final playlist = videoPlaylists[index];
                            return VideoPlayListCard(
                                aspectRatio: 16 / 9,
                                id: playlist.id,
                                title: playlist.name,
                                price: playlist.price,
                                videosCount: playlist.videosCount,
                                imageUrl: playlist.imageUrl,
                                onTap: () {
                                  final route = MaterialPageRoute(
                                    builder: (context) =>
                                        VideoPlayListDetailPage(
                                      videoPlaylist: playlist,
                                    ),
                                  );
                                  Navigator.push(context, route);
                                });
                          }, // Use your PublicationCard widget
                        ),
                      ],
                    ),
                  ),
            Visibility(
              visible: isLoadingVideoPlaylistsError,
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text('Error Loading Resources'),
                ),
              ),
            ),
            // End Videos

            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
