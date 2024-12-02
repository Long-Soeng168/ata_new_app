import 'package:ata_new_app/components/error_image.dart';
import 'package:flutter/material.dart';

class GaragePostCard extends StatelessWidget {
  const GaragePostCard({
    super.key,
    this.id = 0,
    this.title = '',
    this.subTitle = '',
    this.price = 0,
    this.imageUrl = '',
    this.onTap,
    this.aspectRatio = 1 / 1,
    this.width = 200,
  });

  final int id;
  final String title;
  final String subTitle;
  final double price;
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
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            // border: Border.all(
            //   color: Theme.of(context).colorScheme.primary,
            //   width: 0.5,
            // ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade200,
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
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    (loadingProgress.expectedTotalBytes ?? 1)
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Container(
                padding: const EdgeInsets.only(left: 4, right: 4),
                // height: 45,
                // color: Colors.amber,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
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
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: Text(
                    //         '${price.toString()} \$',
                    //         maxLines: 1,
                    //         overflow: TextOverflow.ellipsis,
                    //         style: const TextStyle(
                    //             fontSize: 16, color: Colors.redAccent),
                    //       ),
                    //     ),
                    //     Icon(
                    //       Icons.favorite_outline,
                    //       size: 24,
                    //       color: Colors.grey.shade500,
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
