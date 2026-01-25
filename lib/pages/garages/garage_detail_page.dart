// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/detail_list_card.dart';
import 'package:ata_new_app/components/cards/garage_post_card.dart';
import 'package:ata_new_app/components/cards/shop_tile_card.dart';
import 'package:ata_new_app/components/my_slide_show.dart';
import 'package:ata_new_app/components/my_tab_button.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/models/garage_post.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // 1. Added import

class GarageDetailPage extends StatefulWidget {
  const GarageDetailPage({super.key, required this.garage});

  final Garage garage;

  @override
  State<GarageDetailPage> createState() => _GarageDetailPageState();
}

class _GarageDetailPageState extends State<GarageDetailPage> {
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
  }

  void getResource() {
    getGaragesPosts();
  }

  // 2. Added Map Launcher Function
  Future<void> _launchMap() async {
    final lat = widget.garage.latitude;
    final lng = widget.garage.longitude;
    final googleUrl =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');

    if (await canLaunchUrl(googleUrl)) {
      await launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  List<GaragePost> garagesPosts = [];
  bool isLoadingGaragesPosts = true;
  bool isLoadingGaragesPostsError = false;

  Future<void> getGaragesPosts() async {
    try {
      final fetchedGaragesPosts =
          await GarageService.fetchGaragesPosts(garageId: widget.garage.id);
      setState(() {
        garagesPosts = fetchedGaragesPosts;
        isLoadingGaragesPosts = false;
      });
    } catch (error) {
      setState(() {
        isLoadingGaragesPosts = false;
        isLoadingGaragesPostsError = true;
      });
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
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        // 3. Added Map Button in AppBar Actions
        actions: [
          if (widget.garage.latitude != null && widget.garage.longitude != null)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton.icon(
                onPressed: _launchMap,
                icon: const Icon(Icons.location_on_rounded, size: 20),
                label: Text(
                  'Map'.tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor:
                      Colors.blueAccent, // Set the text and icon color
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: MySlideShow(imageUrls: [
                widget.garage.bannerUrl,
              ]),
            ),
            ShopTileCard(
              isShowChevron: false,
              phone: widget.garage.phone,
              name: widget.garage.name,
              address: widget.garage.address,
              imageUrl: widget.garage.logoUrl,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Row(
                  children: [
                    SizedBox(width: 8),
                  ],
                ),
              ],
            ),
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
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: garagesPosts.length,
                                itemBuilder: (context, index) {
                                  final garagePost = garagesPosts[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 0),
                                    child: GaragePostCard(
                                      aspectRatio: 16 / 9,
                                      id: garagePost.id,
                                      title: garagePost.name,
                                      imageUrl: garagePost.imageUrl,
                                      imageUrls: garagePost.images,
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
            if (_selectedTabIndex == 1)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.0),
                    Column(children: [
                      DetailListCard(
                        keyword: 'Contact'.tr(),
                        value: widget.garage.phone,
                        isCopyable: true,
                      ),
                      DetailListCard(
                        keyword: 'Address'.tr(),
                        value: widget.garage.address,
                      ),
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
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
