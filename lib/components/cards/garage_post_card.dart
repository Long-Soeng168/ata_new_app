import 'package:ata_new_app/components/error_image.dart';
import 'package:ata_new_app/components/my_gallery_viewer.dart';
import 'package:flutter/material.dart';

class GaragePostCard extends StatelessWidget {
  const GaragePostCard({
    super.key,
    this.id = 0,
    this.title = '',
    this.subTitle = '',
    this.price = 0,
    this.imageUrl = '',
    this.imageUrls,
    this.aspectRatio = 1 / 1,
    this.width = 200,
    this.onEdit, // <-- new callback
  });

  final int id;
  final String title;
  final String subTitle;
  final double price;
  final String imageUrl;
  final void Function()? onEdit; // overlay edit button
  final double aspectRatio;
  final double width;
  final List<String>? imageUrls;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        width: width,
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                // IMAGE TAP → Gallery
                GestureDetector(
                  onTap: () {
                    if (imageUrls != null && imageUrls!.isNotEmpty) {
                      final initialIndex = imageUrls!.indexOf(imageUrl);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyGalleryViewer(
                            imageUrls: imageUrls!,
                            initialIndex: initialIndex >= 0 ? initialIndex : 0,
                          ),
                        ),
                      );
                    } else if (imageUrl.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MyGalleryViewer(
                            imageUrls: [imageUrl],
                            initialIndex: 0,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: AspectRatio(
                        aspectRatio: aspectRatio,
                        child: Image.network(
                          imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const ErrorImage(size: 50),
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // EDIT BUTTON OVERLAY
                if (onEdit != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 20),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // TITLE/SUBTITLE
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600),
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
