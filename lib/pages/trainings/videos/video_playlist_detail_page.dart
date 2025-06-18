// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/detail_list_card.dart';
import 'package:ata_new_app/components/cards/video_card.dart';
import 'package:ata_new_app/components/my_gallery.dart';
import 'package:ata_new_app/components/my_list_header.dart';
import 'package:ata_new_app/components/my_success_dialog.dart';
import 'package:ata_new_app/models/video.dart';
import 'package:ata_new_app/models/video_playlist.dart';
import 'package:ata_new_app/pages/trainings/videos/video_detail_page.dart';
import 'package:ata_new_app/providers/cart_provider.dart';
import 'package:ata_new_app/services/video_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class VideoPlayListDetailPage extends StatefulWidget {
  const VideoPlayListDetailPage({
    super.key,
    required this.videoPlaylist,
  });

  final VideoPlaylist videoPlaylist;

  @override
  State<VideoPlayListDetailPage> createState() =>
      _VideoPlayListDetailPageState();
}

class _VideoPlayListDetailPageState extends State<VideoPlayListDetailPage> {
  List<String> imageUrls = [];
  late VideoPlaylist videoPlaylist;

  List userPlaylists = [];
  bool isLoadingUserPlayLists = true;
  bool ownPlaylist = false;
  List<Video> videos = [];
  bool isLoadingVideo = true;
  bool isLoadingVideoError = false;
  bool isExistInCart = false;

  @override
  void initState() {
    super.initState();
    imageUrls = [widget.videoPlaylist.imageUrl]; // Reassigning the list
    videoPlaylist = widget.videoPlaylist;
    getVideos();
    getUserPlayList();

    // final cartProvider = Provider.of<CartProvider>(context, listen: false);
    // final existingItem = cartProvider.items
    //     .indexWhere((item) => item.videoPlaylist.id == videoPlaylist.id);
    // if (existingItem < 0) {
    //   isExistInCart = true;
    // }
  }

  Future<void> getVideos() async {
    try {
      final fetchedVideos =
          await VideoService.fetchVideos(playlistId: videoPlaylist.id);
      setState(() {
        videos = fetchedVideos;
        isLoadingVideo = false;
      });
    } catch (error) {
      setState(() {
        isLoadingVideo = false;
        isLoadingVideoError = true;
      });
    }
  }

  Future<void> getUserPlayList() async {
    try {
      final fectchedPlayLists = await VideoService.fetchUserPlaylists();
      setState(() {
        isLoadingUserPlayLists = false;
        userPlaylists = fectchedPlayLists;
        ownPlaylist =
            fectchedPlayLists.contains(widget.videoPlaylist.id) ? true : false;
      });
    } catch (error) {
      isLoadingUserPlayLists = false;
      print('get User Video Playlist Errors');
    }
  }

  void _addToCart({bool isShowDialog = true}) {
    // Check if the item already exists in the cart
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final existingItem = cartProvider.items
        .indexWhere((item) => item.videoPlaylist.id == videoPlaylist.id);

    // Show custom confirmation dialog with a different message
    if (isShowDialog) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SuccessDialog(
            message: 'Added to cart successfully!',
          );
        },
      );
    }

    setState(() {
      isExistInCart = true;
    });

    // If item doesn't exist, add it to the cart
    if (existingItem < 0) {
      cartProvider.addToCart(videoPlaylist);
    }
  }

  // void _removeFromCart() {
  //   // Check if the item already exists in the cart
  //   final cartProvider = Provider.of<CartProvider>(context, listen: false);
  //   // Show custom confirmation dialog with a different message
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return SuccessDialog(
  //         message: 'Remove from cart successfully!',
  //       );
  //     },
  //   );
  //   setState(() {
  //     isExistInCart = false;
  //   });

  //   // If item doesn't exist, add it to the cart
  //   cartProvider.removeFromCart(videoPlaylist.id);
  // }

  void _showPurchaseDialog(Video video) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buy to Watch'),
          content:
              Text('You need to buy this course on our website to watch it.'),
          // actions: [
          //   Row(
          //     mainAxisAlignment: MainAxisAlignment.end,
          //     children: [
          //       OutlinedButton(
          //         style: OutlinedButton.styleFrom(
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //           side: BorderSide(
          //               color: Theme.of(context)
          //                   .colorScheme
          //                   .primary), // Set border color here
          //         ),
          //         onPressed: () {
          //           Navigator.of(context).pop();
          //           _addToCart(); // Call your add to cart method
          //         },
          //         child: Row(
          //           children: [
          //             Text(
          //               'Add',
          //               style: TextStyle(
          //                   color: Theme.of(context)
          //                       .colorScheme
          //                       .primary), // Text color
          //             ),
          //             SizedBox(width: 4),
          //             Icon(
          //               Icons.add_shopping_cart_rounded,
          //               color: Theme.of(context).colorScheme.primary,
          //             ),
          //           ],
          //         ),
          //       ),
          //       SizedBox(width: 12),
          //       ElevatedButton(
          //         style: ElevatedButton.styleFrom(
          //           backgroundColor: Theme.of(context).colorScheme.primary,
          //           shape: RoundedRectangleBorder(
          //             borderRadius: BorderRadius.circular(12),
          //           ),
          //         ),
          //         onPressed: () {
          //           Navigator.pop(context);
          //           _addToCart(isShowDialog: false);
          //           final route = MaterialPageRoute(
          //             builder: (context) => VideoCartPage(),
          //           );
          //           Navigator.push(context, route);
          //         },
          //         child: Text(
          //           'Buy Now',
          //           style: TextStyle(color: Colors.white),
          //         ),
          //       ),
          //     ],
          //   )
          // ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.transparent,
        title: Text(
          'Videos Training',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Start Image and Detail Section
                MyGallery(imageUrls: imageUrls),
                // End Image and Detail Section

                // Start Description
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        videoPlaylist.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Text(
                      //   '${videoPlaylist.price} \$',
                      //   style: TextStyle(
                      //     fontSize: 24,
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.redAccent,
                      //   ),
                      // ),
                      const SizedBox(height: 8.0),
                      Column(children: [
                        // Start Detail
                        // DetailListCard(
                        //   keyword: 'Teacher',
                        //   value: videoPlaylist.teacherName,
                        // ),
                        // DetailListCard(
                        //   keyword: 'Category',
                        //   value: videoPlaylist.categoryName,
                        // ),
                        DetailListCard(
                          keyword: 'Videos',
                          value: videoPlaylist.videosCount.toString(),
                        ),
                        // End Detail

                        ListTile(
                          contentPadding: EdgeInsets.all(2),
                          title: Text(
                            'Description',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(videoPlaylist.description),
                        ),
                      ])
                    ],
                  ),
                ),
                // End Description

                // Start  Related Items
                SizedBox(height: 24),
                MyListHeader(
                  title: 'Videos',
                  isShowSeeMore: false,
                ),

                // Start Videos
                isLoadingVideo
                    ? SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Visibility(
                        visible: videos.isNotEmpty,
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
                                    3.8, // Aspect ratio of the grid items
                              ),
                              itemCount: videos
                                  .length, // Total number of filtered items
                              itemBuilder: (context, index) {
                                final video = videos[index];
                                return VideoCard(
                                  aspectRatio: 16 / 9,
                                  id: video.id,
                                  title: video.name,
                                  viewsCount: video.viewsCount,
                                  imageUrl: video.imageUrl,
                                  isFree: video.isFree,
                                  ownPlaylist: ownPlaylist,
                                  onTap: () {
                                    if (!video.isFree && ownPlaylist == false) {
                                      _showPurchaseDialog(video);
                                    } else {
                                      final route = MaterialPageRoute(
                                        builder: (context) => VideoDetailPage(
                                          videos: videos,
                                          videoPlay: video,
                                          videoPlaylist: videoPlaylist,
                                          ownPlaylist: ownPlaylist,
                                        ),
                                      );
                                      Navigator.push(context, route);
                                    }
                                  },
                                );
                              }, // Use your PublicationCard widget
                            ),
                          ],
                        ),
                      ),
                Visibility(
                  visible: isLoadingVideoError,
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Center(
                      child: Text('Error Loading Resources'),
                    ),
                  ),
                ),
                // End Videos

                SizedBox(height: 80),
              ],
            ),
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Container(
                color: Colors.white.withOpacity(0.8),
                padding: EdgeInsets.all(8),
                width: double.infinity,
                child: Row(
                  children: [
                    // if (!ownPlaylist && !isLoadingUserPlayLists)
                    //   Expanded(
                    //     child: ElevatedButton(
                    //       style: ElevatedButton.styleFrom(
                    //         backgroundColor: Colors.white,
                    //         padding: const EdgeInsets.symmetric(vertical: 12.0),
                    //         shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(10),
                    //           side: BorderSide(
                    //               color: Theme.of(context).colorScheme.primary),
                    //         ),
                    //       ),
                    //       onPressed: _addToCart,
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Icon(Icons.add_shopping_cart_outlined,
                    //               color: Theme.of(context).colorScheme.primary),
                    //           SizedBox(width: 8),
                    //           Text(
                    //             'Add To Cart',
                    //             style: TextStyle(
                    //               color: Theme.of(context).colorScheme.primary,
                    //               fontSize: 16,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            // side: BorderSide(color: Colors.white),
                          ),
                        ),
                        onPressed: () {
                          final route = MaterialPageRoute(
                            builder: (context) => VideoDetailPage(
                              videos: videos,
                              videoPlay: videos[0],
                              ownPlaylist: ownPlaylist,
                              videoPlaylist: videoPlaylist,
                            ),
                          );
                          Navigator.push(context, route);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.play_circle_outline_outlined,
                                color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Play Video',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
