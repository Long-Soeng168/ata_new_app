import 'package:ata_new_app/components/error_image.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    this.id = 0,
    this.title = '',
    this.price = '',
    this.imageUrl = '',
    this.onTap,
    this.aspectRatio = 1 / 1,
    this.width = 200,
  });

  final int id;
  final String title;
  final String price;
  final String imageUrl;
  final void Function()? onTap;
  final double aspectRatio;
  final double width;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Container(
          width: width,
          height: double.infinity,
          // padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            // border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.transparent,
                    ),
                    borderRadius: BorderRadius.circular(8)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: AspectRatio(
                    aspectRatio: aspectRatio,
                    child: Image.network(
                      imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const ErrorImage(size: 50);
                      },
                      // loadingBuilder: (BuildContext context, Widget child,
                      //     ImageChunkEvent? loadingProgress) {
                      //   if (loadingProgress == null) return child;
                      //   return Center(
                      //     child: CircularProgressIndicator(
                      //       value: loadingProgress.expectedTotalBytes != null
                      //           ? loadingProgress.cumulativeBytesLoaded /
                      //               (loadingProgress.expectedTotalBytes ?? 1)
                      //           : null,
                      //     ),
                      //   );
                      // },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.only(left: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14, // Set font size to 12
                            ),
                          ),

                          // Text(
                          //   'Long Soeng',
                          //   maxLines: 2,
                          //   overflow: TextOverflow.ellipsis,
                          //   style: TextStyle(color: Colors.grey.shade400),
                          // ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '$price \$',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.redAccent),
                            ),
                          ),
                          // Container(
                          //   padding: EdgeInsets.all(4),
                          //   decoration: BoxDecoration(
                          //     // color: Theme.of(context)
                          //     //     .colorScheme
                          //     //     .primary
                          //     //     .withOpacity(0.05),
                          //     shape: BoxShape.circle,
                          //   ),
                          //   child: GestureDetector(
                          //     onTap: () {
                          //       // Your onPressed action here
                          //     },
                          //     child: Padding(
                          //       padding: EdgeInsets.all(0), // No padding
                          //       child: Icon(
                          //         Icons.favorite_outline,
                          //         size: 24,
                          //         color: Theme.of(context)
                          //             .colorScheme
                          //             .primary
                          //             .withOpacity(0.5),
                          //       ),
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
