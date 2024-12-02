import 'package:ata_new_app/components/error_image.dart';
import 'package:flutter/material.dart';

class AssetIconCard extends StatelessWidget {
  const AssetIconCard(
      {super.key, required this.icon, required this.title, this.onTap});

  final String icon;
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          // color: Colors.amber,
        ),
        // margin: EdgeInsets.all(10),
        padding: EdgeInsets.all(5),
        child: Column(
          children: [
            // Product Image
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    // color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: AspectRatio(
                      aspectRatio: 1,
                      // child: Icon(Icons.favorite),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Image.asset(
                          icon,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const ErrorImage(size: 50);
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // Product Name
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    // backgroundColor: Colors.amber,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
