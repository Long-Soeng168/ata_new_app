// ignore_for_file: prefer_const_constructors

import 'package:ata_new_app/components/cards/database_card.dart';
import 'package:ata_new_app/components/cards/garage_card.dart';
import 'package:ata_new_app/components/my_list_header.dart';
import 'package:ata_new_app/components/my_slide_show.dart';
import 'package:ata_new_app/models/brand.dart';
import 'package:ata_new_app/models/garage.dart';
import 'package:ata_new_app/pages/garages/garage_detail_page.dart';
import 'package:ata_new_app/pages/garages/garages_list_page.dart';
import 'package:ata_new_app/services/brand_service.dart';
import 'package:ata_new_app/services/garage_service.dart';
import 'package:ata_new_app/services/slide_service.dart';
import 'package:flutter/material.dart';

class GaragesPage extends StatefulWidget {
  const GaragesPage({super.key});

  @override
  State<GaragesPage> createState() => _GaragesPageState();
}

class _GaragesPageState extends State<GaragesPage> {
  List<Garage> garages = [];
  bool isLoadingGarages = true;
  bool isLoadingGaragesError = false;
  bool hasMoreGarages = true;
  bool isLoadingMore = false;
  int currentPage = 1;

  List<String> slides = [];
  bool isLoadingSlide = true;
  bool isLoadingSlideError = false;

  List<Brand> brands = [];
  bool isLoadingBrands = true;
  bool isLoadingBrandsError = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getSlides();
    getBrands();
    getGarages();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        loadMoreGarages();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> getSlides() async {
    try {
      // Fetch garages outside of setState
      final fetchedSlides = await SlideService.fetchSlides(position: 'garage');
      // Update the state
      setState(() {
        slides = fetchedSlides;
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

  Future<void> getBrands() async {
    try {
      // Fetch products outside of setState
      final fetchedBrands = await BrandService.fetchBrands();
      // Update the state
      setState(() {
        brands = fetchedBrands;
        isLoadingBrands = false;
      });
    } catch (error) {
      // Handle any errors that occur during the fetch
      setState(() {
        isLoadingBrands = false;
        isLoadingBrandsError = true;
      });
      // You can also show an error message to the user
      print('Failed to load Brands: $error');
    }
  }

  Future<void> getGarages() async {
    try {
      final fetchedGarages = await GarageService.fetchGarages(page: 1);
      setState(() {
        garages = fetchedGarages;
        isLoadingGarages = false;
      });
    } catch (error) {
      setState(() {
        isLoadingGarages = false;
        isLoadingGaragesError = true;
        isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load Data'),
        ),
      );
    }
  }

  Future<void> loadMoreGarages() async {
    if (!hasMoreGarages || isLoadingMore) {
      return;
    }

    setState(() {
      isLoadingMore = true;
    });

    try {
      currentPage++;
      final fetchedGarages =
          await GarageService.fetchGarages(page: currentPage);

      setState(() {
        garages.addAll(fetchedGarages);
        isLoadingMore = false;
      });

      if (fetchedGarages.isEmpty) {
        hasMoreGarages = false;
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
        title: Text(
          'Garages',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              final route =
                  MaterialPageRoute(builder: (context) => GaragesListPage());
              Navigator.push(context, route);
            },
            icon: Icon(
              Icons.search_outlined,
              size: 32,
            ),
          ),
        ],
      ),
      body: isLoadingGarages
          ? Center(
              child: CircularProgressIndicator(),
            )
          : garages.isNotEmpty
              ? SafeArea(
                  child: Stack(
                    children: [
                      CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverToBoxAdapter(
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: MySlideShow(imageUrls: slides),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 12,
                                ),
                                MyListHeader(
                                  title: 'Expert',
                                  isShowSeeMore: false,
                                ),
                                SizedBox(
                                  height:
                                      130, // Set a fixed height for horizontal ListView
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: brands.length,
                                    itemBuilder: (context, index) {
                                      final brand = brands[index];
                                      return DatabaseCard(
                                        image: brand.imageUrl,
                                        title: brand.name,
                                        onTap: () {
                                          final route = MaterialPageRoute(
                                              builder: (context) =>
                                                  GaragesListPage(
                                                    expertId: brand.id,
                                                  ));
                                          Navigator.push(context, route);
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              children: const [
                                SizedBox(
                                  height: 12,
                                ),
                                MyListHeader(
                                  title: 'Garages',
                                  isShowSeeMore: false,
                                ),
                              ],
                            ),
                          ),
                          SliverPadding(
                            padding: EdgeInsets.all(0.0),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, // Number of columns
                                childAspectRatio: 0.95,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final garage = garages[index];
                                  return GarageCard(
                                    id: garage.id,
                                    name: garage.name,
                                    address: garage.address,
                                    expert: garage.expertName,
                                    logoUrl: garage.logoUrl,
                                    bannerUrl: garage.bannerUrl,
                                    onTap: () {
                                      final route = MaterialPageRoute(
                                        builder: (context) => GarageDetailPage(
                                          garage: garage,
                                        ),
                                      );
                                      Navigator.push(context, route);
                                    },
                                  );
                                },
                                childCount: garages.length,
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Column(
                              children: const [
                                SizedBox(
                                  height: 16,
                                ),
                              ],
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
                  child: Text('No Data'),
                ),
    );
  }
}
