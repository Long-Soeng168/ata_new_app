// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/video_card.dart';
import 'package:ata_new_app/components/my_success_dialog.dart';
import 'package:ata_new_app/components/my_video_player.dart';
import 'package:ata_new_app/models/video.dart';
import 'package:ata_new_app/models/video_playlist.dart';
import 'package:ata_new_app/pages/trainings/videos/cart/video_cart_page.dart';
import 'package:ata_new_app/providers/cart_provider.dart';
import 'package:ata_new_app/services/video_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class VideoDetailPage extends StatefulWidget {
  const VideoDetailPage({
    super.key,
    required this.videos,
    required this.videoPlay,
    required this.videoPlaylist,
    required this.ownPlaylist,
  });

  final List<Video> videos;
  final Video videoPlay;
  final VideoPlaylist videoPlaylist;
  final bool ownPlaylist;

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  late List<Video> videos;
  late Video videoPlay;
  bool isExistInCart = false;

  late Video videoDetail;
  bool isLoadingVideoDetail = true;
  bool isLoadingVideoDetailError = false;

  @override
  void initState() {
    super.initState();
    videos = widget.videos;
    videoPlay = widget.videoPlay;
    getVideoDetail();
    // print(videoPlay.videoUrl);
    // getVideos();
  }

  void changeVideoPlay(int index) {
    setState(() {
      videoPlay = videos[index];
    });
    getVideoDetail();
  }

  Future<void> getVideoDetail() async {
    try {
      final fetchedVideoDetail =
          await VideoService.fetchVideoById(id: videoPlay.id);
      print(fetchedVideoDetail);
      setState(() {
        videoDetail = fetchedVideoDetail;
        isLoadingVideoDetail = false;
      });
      // print(fetchedVideoDetail);
    } catch (error) {
      setState(() {
        isLoadingVideoDetail = false;
        isLoadingVideoDetailError = true;
      });
      print('Failed to load Video: $error');
    }
  }

  void _addToCart({bool isShowDialog = true}) {
    // Check if the item already exists in the cart
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final existingItem = cartProvider.items
        .indexWhere((item) => item.videoPlaylist.id == widget.videoPlaylist.id);

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
      cartProvider.addToCart(widget.videoPlaylist);
    }
  }

  void _showPurchaseDialog(Video video) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Buy to Watch'),
          content: Text(
              'You need to buy this course on our website to watch it.'),
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
          'Videos',
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
        physics: NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Start Video
            MyVideoPlayer(
              key: ValueKey(videoPlay.videoUrl),
              dataSourceType: DataSourceType.network,
              url: videoPlay.videoUrl,
            ),
            // End Video

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoPlay.name,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      // GestureDetector(
                      //   onTap: () {},
                      //   child: Row(
                      //     children: const [
                      //       Icon(
                      //         Icons.favorite_outline,
                      //         size: 32,
                      //         color: Colors.grey,
                      //       ),
                      //       SizedBox(width: 4),
                      //       Text(
                      //         'Favorite',
                      //         maxLines: 1,
                      //         overflow: TextOverflow.ellipsis,
                      //         style:
                      //             TextStyle(fontSize: 12, color: Colors.grey),
                      //       )
                      //     ],
                      //   ),
                      // ),
                      // SizedBox(width: 26),
                      Row(
                        children: [
                          Icon(
                            Icons.remove_red_eye_outlined,
                            size: 24,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '${videoPlay.viewsCount} Views',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            DefaultTabController(
              length: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TabBar(
                    unselectedLabelColor: Colors.grey,
                    labelColor: Theme.of(context).colorScheme.primary,
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                        // gradient: LinearGradient(colors: [
                        //   Theme.of(context).colorScheme.primary,
                        //   Theme.of(context).colorScheme.primary,
                        // ]),
                        // // borderRadius: BorderRadius.circular(50),
                        // color: Theme.of(context).colorScheme.primary,
                        border: Border(
                            bottom: BorderSide(
                      width: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ))),
                    tabs: const [
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("VIDEOS"),
                        ),
                      ),
                      Tab(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text("DESCRIPTION"),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height *
                        0.6, // Adjust height as needed
                    child: TabBarView(
                      children: [
                        // Start Related Items
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(bottom: 130),
                                child: GridView.builder(
                                  shrinkWrap:
                                      true, // Important: Let GridView take up only needed space
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
                                      isPlaying: video.id == videoPlay.id,
                                      aspectRatio: 16 / 9,
                                      id: video.id,
                                      title: video.name,
                                      isFree: video.isFree,
                                      viewsCount: video.viewsCount,
                                      imageUrl: video.imageUrl,
                                      ownPlaylist: widget.ownPlaylist,
                                      onTap: () {
                                        if (!video.isFree &&
                                            widget.ownPlaylist == false) {
                                          _showPurchaseDialog(video);
                                        } else {
                                          changeVideoPlay(index);
                                        }
                                      },
                                    );
                                  }, // Use your PublicationCard widget
                                ),
                              ),
                            ),
                          ],
                        ),
                        // End Related Items

                        // Start Description
                        SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      isLoadingVideoDetail
                                          ? SizedBox(
                                              width: double.infinity,
                                              height: 100,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            )
                                          : ListTile(
                                              contentPadding: EdgeInsets.all(2),
                                              title: Text(
                                                'Description',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              subtitle:
                                                  Text(videoDetail.description),
                                            ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        // End Description
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
