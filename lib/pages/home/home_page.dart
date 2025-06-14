// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:ata_new_app/components/cards/asset_icon_card.dart';
import 'package:ata_new_app/components/cards/product_card.dart';
import 'package:ata_new_app/components/cards/video_playlist_card.dart';
import 'package:ata_new_app/components/my_drawer.dart';
import 'package:ata_new_app/components/my_list_header.dart';
import 'package:ata_new_app/components/my_slide_show.dart';
import 'package:ata_new_app/models/product.dart';
import 'package:ata_new_app/models/video_playlist.dart';
import 'package:ata_new_app/pages/dtc/dtc_page.dart';
import 'package:ata_new_app/pages/garages/garages_page.dart';
import 'package:ata_new_app/pages/shops/product_detail_page.dart';
import 'package:ata_new_app/pages/shops/products_list_page.dart';
import 'package:ata_new_app/pages/shops/shops_page.dart';
import 'package:ata_new_app/pages/trainings/courses/courses_page.dart';
import 'package:ata_new_app/pages/trainings/documents/documents_page.dart';
import 'package:ata_new_app/pages/trainings/videos/video_playlist_detail_page.dart';
import 'package:ata_new_app/pages/trainings/videos/video_playlist_page.dart';
import 'package:ata_new_app/services/product_service.dart';
import 'package:ata_new_app/services/slide_service.dart';
import 'package:ata_new_app/services/video_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> slides = [];
  List<String> slidesMiddle = [];
  bool isLoadingSlide = true;
  bool isLoadingSlideError = false;

  List<Product> products = [];
  bool isLoadingProducts = true;
  bool isLoadingProductsError = false;

  List<VideoPlaylist> videoPlaylists = [];
  bool isLoadingVideoPlaylists = true;
  bool isLoadingVideoPlaylistsError = false;

  @override
  void initState() {
    super.initState();
    getResource();
  }

  void getResource() {
    getProducts();
    getVideoPlaylists();
    getSlides();
  }

  Future<void> getProducts() async {
    try {
      // Fetch products outside of setState
      final fetchedProducts = await ProductService.fetchProducts();
      // Update the state
      setState(() {
        products = fetchedProducts;
        isLoadingProducts = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingProducts = false;
        isLoadingProductsError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Products: $error');
    }
  }

  Future<void> getSlides() async {
    try {
      // Fetch products outside of setState
      final fetchedSlides =
          await SlideService.fetchSlides(position: 'HOME-16/9');
      final fetchedSlidesMiddle =
          await SlideService.fetchSlides(position: 'HOME-21/9');
      // Update the state
      setState(() {
        slides = fetchedSlides;
        slidesMiddle = fetchedSlidesMiddle;
        isLoadingSlide = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingSlide = false;
        isLoadingSlideError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Slide: $error');
    }
  }

  Future<void> getVideoPlaylists() async {
    try {
      final fetchedVideoPlaylists = await VideoService.fetchVideoPlaylists();
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: MyDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            icon: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),

        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          'ATA',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () async {
        //       // final AuthService authService = AuthService();
        //       // final token = await authService.getToken();
        //       // // print(token);
        //       // final route = MaterialPageRoute(
        //       //   builder: (context) =>
        //       //       token != null ? AccountPage() : LoginPage(),
        //       // );

        //       // Navigator.push(context, route);
        //     },
        //     icon: Icon(
        //       Icons.translate,
        //       size: 32,
        //     ),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ========================= Start Slide Show =========================
            AspectRatio(
              aspectRatio: 16 / 9,
              child: MySlideShow(
                imageUrls: slides,
              ),
            ),
            // ========================= End Slide Show =========================

            // ========================= Start Icon Navigator =========================
            SizedBox(
              height: 8,
            ),
            Container(
              height: 140, // Set a fixed height for horizontal ListView
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  AssetIconCard(
                    icon: 'lib/assets/icons/shop.png',
                    title: 'Shops',
                    onTap: () {
                      final route =
                          MaterialPageRoute(builder: (context) => ShopsPage());
                      Navigator.push(context, route);
                    },
                  ),
                  AssetIconCard(
                    icon: 'lib/assets/icons/garage.png',
                    title: 'Garages',
                    onTap: () {
                      final route = MaterialPageRoute(
                          builder: (context) => GaragesPage());
                      Navigator.push(context, route);
                    },
                  ),
                  AssetIconCard(
                    icon: 'lib/assets/icons/document.png',
                    title: 'Documents',
                    onTap: () {
                      final route = MaterialPageRoute(
                          builder: (context) => DocumentsPage());
                      Navigator.push(context, route);
                    },
                  ),
                  AssetIconCard(
                    icon: 'lib/assets/icons/video.png',
                    title: 'Videos',
                    onTap: () {
                      final route = MaterialPageRoute(
                          builder: (context) => VideoPlayListPage());
                      Navigator.push(context, route);
                    },
                  ),
                  AssetIconCard(
                    icon: 'lib/assets/icons/dtc.png',
                    title: 'DTC',
                    onTap: () {
                      final route =
                          MaterialPageRoute(builder: (context) => DtcPage());
                      Navigator.push(context, route);
                    },
                  ),
                  AssetIconCard(
                    icon: 'lib/assets/icons/course.png',
                    title: 'Courses',
                    onTap: () {
                      final route = MaterialPageRoute(
                          builder: (context) => CoursesPage());
                      Navigator.push(context, route);
                    },
                  ),
                ],
              ),
            ),
            // ========================= End Icon Navigator =========================

            // ========================= Start Products =========================
            isLoadingProducts
                ? SizedBox(
                    width: double.infinity,
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Visibility(
                    visible: products.isNotEmpty,
                    child: Column(
                      children: [
                        MyListHeader(
                          title: 'New Products',
                          onTap: () {
                            final route = MaterialPageRoute(
                                builder: (context) => ProductsListPage());
                            Navigator.push(context, route);
                          },
                        ),
                        Container(
                          height:
                              290, // Set a fixed height for horizontal ListView
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: products.length,
                            itemBuilder: (context, index) {
                              final product = products[index];
                              return ProductCard(
                                  width: 200,
                                  id: product.id,
                                  title: product.name,
                                  price: product.price,
                                  imageUrl: product.imageUrl,
                                  onTap: () {
                                    final route = MaterialPageRoute(
                                      builder: (context) => ProductDetailPage(
                                        product: product,
                                      ),
                                    );
                                    Navigator.push(context, route);
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
            Visibility(
              visible: isLoadingProductsError,
              child: Container(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text('Error Loading Resources'),
                ),
              ),
            ),
            // ========================= End Products =========================

            // ========================= Start Slide Show Middle =========================
            Visibility(
              visible: slidesMiddle.isNotEmpty,
              child: Column(
                children: [
                  SizedBox(height: 24),
                  AspectRatio(
                    aspectRatio: 40 / 10,
                    child: MySlideShow(
                      imageUrls: slidesMiddle,
                      aspectRatio: 40 / 10,
                    ),
                  ),
                ],
              ),
            ),
            // ========================= End Slide Show Middle =========================

            // ========================= Start Video Training =========================
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
                        SizedBox(height: 20),
                        MyListHeader(
                            title: 'Videos Trainings',
                            onTap: () {
                              final route = MaterialPageRoute(
                                  builder: (context) => VideoPlayListPage());
                              Navigator.push(context, route);
                            }),
                        Container(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: videoPlaylists.length,
                            itemBuilder: (context, index) {
                              final playlist = videoPlaylists[index];
                              return VideoPlayListCard(
                                  width: 300,
                                  aspectRatio: 16 / 9,
                                  id: playlist.id,
                                  title: playlist.name,
                                  price: playlist.price,
                                  imageUrl: playlist.imageUrl,
                                  // teacherName: playlist.teacherName,
                                  videosCount: playlist.videosCount,
                                  onTap: () {
                                    final route = MaterialPageRoute(
                                      builder: (context) =>
                                          VideoPlayListDetailPage(
                                        videoPlaylist: playlist,
                                      ),
                                    );
                                    Navigator.push(context, route);
                                  });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
            Visibility(
              visible: isLoadingVideoPlaylistsError,
              child: Container(
                width: double.infinity,
                height: 50,
                child: Center(
                  child: Text('Error Loading Resources'),
                ),
              ),
            ),
            // ========================= End Video Training =========================
          ],
        ),
      ),
    );
  }
}
