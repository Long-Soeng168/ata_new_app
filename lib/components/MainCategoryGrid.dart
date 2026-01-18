import 'package:ata_new_app/pages/dtc/dtc_page.dart';
import 'package:ata_new_app/pages/garages/garages_map_page.dart';
import 'package:ata_new_app/pages/garages/garages_page.dart';
import 'package:ata_new_app/pages/shops/products_list_page.dart';
import 'package:ata_new_app/pages/shops/shops_page.dart';
import 'package:ata_new_app/pages/trainings/courses/courses_page.dart';
import 'package:ata_new_app/pages/trainings/documents/documents_page.dart';
import 'package:ata_new_app/pages/trainings/videos/video_playlist_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class MainCategoryGrid extends StatelessWidget {
  const MainCategoryGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Cars for Sale'.tr(),
        'icon': 'lib/assets/icons/car_sale.png', // Assuming you have a car icon
        'page': const ProductsListPage(
          categoryId: 10,
        ),
        'color': Colors.amber.shade700, // Golden/Deep Orange for Sales
      },
      {
        'title': 'Shops'.tr(),
        'icon': 'lib/assets/icons/shop.png',
        'page': const ShopsPage(),
        'color': Colors.orange.shade600, // Classic Orange for Shops
      },
      {
        'title': 'Garages'.tr(),
        'icon': 'lib/assets/icons/garage.png',
        'page': const GaragesPage(),
        'color': Colors.blue.shade600, // Primary Blue
      },
      {
        'title': 'Garages Maps'.tr(),
        'icon': 'lib/assets/icons/map.png', // Assuming you have a map icon
        'page': const GaragesMapPage(),
        'color': Colors.cyan.shade700, // Cyan/Teal for Navigation/Maps
      },
      {
        'title': 'Documents'.tr(),
        'icon': 'lib/assets/icons/document.png',
        'page': const DocumentsPage(),
        'color': Colors.purple.shade500,
      },
      {
        'title': 'Videos'.tr(),
        'icon': 'lib/assets/icons/video.png',
        'page': const VideoPlayListPage(),
        'color': Colors.red.shade600,
      },
      {
        'title': 'DTC'.tr(),
        'icon': 'lib/assets/icons/dtc.png',
        'page': const DtcPage(),
        'color': Colors.teal.shade600,
      },
      {
        'title': 'Courses'.tr(),
        'icon': 'lib/assets/icons/course.png',
        'page': const CoursesPage(),
        'color': Colors.indigo.shade600,
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: menuItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: 0.75, // Taller ratio for a more elegant look
        ),
        itemBuilder: (context, index) {
          final item = menuItems[index];
          return _CategoryCard(
            title: item['title'],
            icon: item['icon'],
            accentColor: item['color'],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => item['page']),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          // Icon Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                // Soft colored background instead of plain white
                color: accentColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accentColor.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Image.asset(
                    icon,
                    fit: BoxFit.contain,
                    // Optional: if your icons are single color, you can tint them
                    // color: accentColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[900],
              letterSpacing: -0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
