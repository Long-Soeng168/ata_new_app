// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/detail_list_card.dart';
import 'package:ata_new_app/components/cards/garage_post_card.dart';
import 'package:ata_new_app/components/cards/shop_tile_card.dart';
import 'package:ata_new_app/components/my_slide_show.dart';
import 'package:ata_new_app/components/my_tab_button.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/models/garage_post.dart';
import 'package:ata_new_app/pages/app_info/web_view_page.dart';
import 'package:ata_new_app/pages/garages/garage_admin/garage_create_post.dart';
import 'package:ata_new_app/pages/garages/garage_admin/garage_edit_page.dart';
import 'package:ata_new_app/pages/garages/garage_admin/garage_edit_post.dart';
import 'package:ata_new_app/pages/home/home_page.dart';
import 'package:ata_new_app/pages/main_page.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AdminGarageDetailPage extends StatefulWidget {
  const AdminGarageDetailPage({super.key, required this.garage});

  final Garage garage;

  @override
  State<AdminGarageDetailPage> createState() => _AdminGarageDetailPageState();
}

class _AdminGarageDetailPageState extends State<AdminGarageDetailPage> {
  int _selectedTabIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getResource();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkGarageStatus();
    });
  }

  void _checkGarageStatus() {
    final status = widget.garage.status.toLowerCase();

    if (status == 'pending' || status == 'suspended' || status == 'rejected') {
      // Choose icon & color based on status
      IconData icon;
      Color iconColor;
      String message;

      switch (status) {
        case 'pending':
          icon = Icons.hourglass_bottom;
          iconColor = Colors.amber;
          message =
              "Your garage is pending approval. Please wait for verification.".tr();
          break;
        case 'suspended':
          icon = Icons.pause_circle_filled;
          iconColor = Colors.orange;
          message =
              "Your garage has been suspended. Contact support for details.".tr();
          break;
        case 'rejected':
          icon = Icons.block;
          iconColor = Colors.red;
          message =
              "Your garage has been rejected. Contact us for further info.".tr();
          break;
        default:
          icon = Icons.info;
          iconColor = Colors.blueGrey;
          message = "Status: $status";
      }

      showDialog(
        context: context,
        barrierDismissible: false, // user must tap a button
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(icon, color: iconColor, size: 28),
                SizedBox(width: 8),
                Text(
                  "Garage Status".tr(),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message,
                  style: TextStyle(fontSize: 16, height: 1.4),
                ),
                SizedBox(height: 12),
                Text(
                  "${'Current Status'.tr()}: ${status[0].toUpperCase()}${status.substring(1)}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actionsPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[700],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GarageEditPage(
                        garage: widget.garage,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.edit, size: 18),
                label: Text("Edit Garage".tr()),
              ),
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
  }

  void getResource() {
    getGaragesPosts();
  }

  final List<String> imageUrls = [
    'https://thnal.com/assets/images/images/thumb/1724644805cYik37Kni4.jpg',
    'https://thnal.com/assets/images/images/thumb/1724645207ijk4Luu0MV.jpg',
  ];

  List<GaragePost> garagesPosts = [];
  bool isLoadingGaragesPosts = true;
  bool isLoadingGaragesPostsError = false;

  Future<void> getGaragesPosts() async {
    try {
      // Fetch garagesPosts outside of setState
      final fetchedGaragesPosts =
          await GarageService.fetchGaragesPosts(garageId: widget.garage.id);
      // Update the state
      setState(() {
        garagesPosts = fetchedGaragesPosts;
        isLoadingGaragesPosts = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingGaragesPosts = false;
        isLoadingGaragesPostsError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Garage Post: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        backgroundColor: Colors.transparent,
        title: Text(
          widget.garage.name,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GarageEditPage(
                          garage: widget.garage,
                        )),
              );
            },
            icon: Icon(
              Icons.edit,
              size: 32,
            ),
          ),
        ],
      ),
      floatingActionButton: widget.garage.status.toLowerCase() == "approved"
          ? SizedBox(
              height: 70.0, // Custom height
              width: 70.0, // Custom width
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GarageCreatePost(
                        garage: widget.garage,
                      ),
                    ),
                  );
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100), // fully round
                ),
                child: const Icon(
                  Icons.add,
                  size: 35,
                ),
              ),
            )
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================= Start Images =========================
            // ========================= Start Slide Show =========================
            AspectRatio(
              aspectRatio: 16 / 9,
              child: MySlideShow(imageUrls: [
                widget.garage.bannerUrl,
              ]),
            ),
            // ========================= End Slide Show =========================
            ShopTileCard(
              isShowChevron: false,
              name: widget.garage.name,
              phone: widget.garage.phone,
              address: widget.garage.address,
              imageUrl: widget.garage.logoUrl,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    SizedBox(
                      width: 8,
                    ),
                    // Row(
                    //   children: [
                    //     IconButton(
                    //       onPressed: () {},
                    //       icon: Icon(
                    //         Icons.thumb_up_outlined,
                    //         size: 24,
                    //         color: Colors.grey,
                    //       ),
                    //     ),
                    //     Text(
                    //       '2139',
                    //       maxLines: 1,
                    //       overflow: TextOverflow.ellipsis,
                    //       style: TextStyle(
                    //         fontSize: 16,
                    //         color: Colors.grey,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // Container(
                    //   width: 1,
                    //   height: 14,
                    //   margin: EdgeInsets.only(left: 18, right: 8),
                    //   color: Colors.grey,
                    // ),
                    // Row(
                    //   children: [
                    //     IconButton(
                    //       onPressed: () {},
                    //       icon: Icon(
                    //         Icons.thumb_down_outlined,
                    //         size: 24,
                    //         color: Colors.grey,
                    //       ),
                    //     ),
                    //     Text(
                    //       '138',
                    //       maxLines: 1,
                    //       overflow: TextOverflow.ellipsis,
                    //       style: TextStyle(
                    //         fontSize: 16,
                    //         color: Colors.grey,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ],
            ),

            // ========================= Start Tab =========================
            Row(
              children: [
                MyTabButton(
                  title: 'Posts'.tr(),
                  isSelected: _selectedTabIndex == 0,
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 0;
                    });
                  },
                ),
                MyTabButton(
                  title: 'About Garage'.tr(),
                  isSelected: _selectedTabIndex == 1,
                  onTap: () {
                    setState(() {
                      _selectedTabIndex = 1;
                    });
                  },
                ),
              ],
            ),

            SizedBox(height: 8),
            // ========================= End Tab =========================

            // ========================= Start Product =========================
            if (_selectedTabIndex == 0)
              Column(
                children: [
                  isLoadingGaragesPosts
                      ? SizedBox(
                          width: double.infinity,
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : Visibility(
                          visible: garagesPosts.isNotEmpty,
                          child: Column(
                            children: [
                              ListView.builder(
                                shrinkWrap:
                                    true, // Let ListView take only as much space as needed
                                physics:
                                    NeverScrollableScrollPhysics(), // Disable its own scrolling if not needed
                                itemCount: garagesPosts.length,
                                itemBuilder: (context, index) {
                                  final garagePost = garagesPosts[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8), // spacing between cards
                                    child: GaragePostCard(
                                      aspectRatio: 16 / 9,
                                      id: garagePost.id,
                                      title: garagePost.name,
                                      imageUrl: garagePost.imageUrl,
                                      imageUrls: garagePost
                                          .images, // optional list of images
                                      onEdit: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                GarageEditPost(
                                              garage: widget.garage,
                                              garagePost: garagePost,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                  Visibility(
                    visible: isLoadingGaragesPostsError,
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Center(
                        child: Text('Error Loading Resources'.tr()),
                      ),
                    ),
                  ),
                ],
              ),
            // ========================= End Product =========================

            // ========================= Start Detail =========================
            if (_selectedTabIndex == 1)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    Column(children: [
                      // Start Detail
                      DetailListCard(
                        keyword: 'Expert'.tr(),
                        value: widget.garage.expertName,
                      ),
                      DetailListCard(
                        keyword: 'Contact'.tr(),
                        value: widget.garage.phone,
                      ),
                      DetailListCard(
                        keyword: 'Address'.tr(),
                        value: widget.garage.address,
                      ),
                      // End Detail

                      ListTile(
                        contentPadding: EdgeInsets.all(2),
                        title: Text(
                          'Description'.tr(),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(widget.garage.description),
                      ),
                    ])
                  ],
                ),
              ),
            // ========================= End Detail =========================
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
