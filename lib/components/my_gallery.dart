import 'package:ata_new_app/components/error_image.dart';
import 'package:ata_new_app/components/my_gallery_viewer.dart';
import 'package:flutter/material.dart';

class MyGallery extends StatelessWidget {
  const MyGallery({super.key, required this.imageUrls});
  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              color: Colors.grey.shade500,
            ),
            Text(
              'No images available',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return Container(
      child: Column(
        children: [
          // Display the first image at the top
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyGalleryViewer(
                    imageUrls: imageUrls,
                    initialIndex: 0,
                  ),
                ),
              );
            },
            child: Hero(
              tag: imageUrls[0],
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 400, // Set your desired maximum height here
                ),
                child: Image.network(
                  imageUrls[0],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const ErrorImage(size: 168);
                  },
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) {
                      return child;
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
          // End Image and Detail Section
      
          // Start More Image
          if (imageUrls.length > 1)
            Container(
              height: 160,
              padding: EdgeInsets.only(top: 4, bottom: 4),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: imageUrls.length - 1,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyGalleryViewer(
                            imageUrls: imageUrls,
                            initialIndex:
                                index + 1, // Adjust index to skip the first image
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 160, // Width of the container
                      margin: const EdgeInsets.symmetric(
                          horizontal: 2.0), // Margin between items
                      child: AspectRatio(
                        aspectRatio:
                            1 / 1, // Aspect ratio of 1:1 for square images
                        child: Hero(
                          tag: imageUrls[index + 1],
                          child: Image.network(
                            imageUrls[index + 1],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const ErrorImage(size: 50);
                            },
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          // End More Image
        ],
      ),
    );
  }
}
