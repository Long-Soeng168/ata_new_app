import 'package:ata_new_app/components/error_image.dart';
import 'package:flutter/material.dart';

class GarageCard extends StatelessWidget {
  const GarageCard({
    super.key,
    this.id = 0,
    this.name = '',
    this.address = '',
    this.expert = '',
    this.bannerUrl = '',
    this.logoUrl = '',
    this.likes = '0',
    this.onTap,
    this.aspectRatio = 16 / 9,
    this.width = 200,
  });

  final int id;
  final String name;
  final String address;
  final String expert;
  final String logoUrl;
  final String likes;
  final String bannerUrl;
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
          // padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            // borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
            // border: Border.all(
            //   width: 0.5,
            //   color: Theme.of(context).colorScheme.primary,
            // ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                      ),
                      child: ClipRRect(
                        child: AspectRatio(
                          aspectRatio: aspectRatio,
                          child: Stack(
                            children: [
                              Image.network(
                                bannerUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const ErrorImage(size: 50);
                                },
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    ),
                                  );
                                },
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.75),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    bottom: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.white,
                              ),
                              borderRadius: BorderRadius.circular(9),
                              color: Theme.of(context).colorScheme.surface,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: AspectRatio(
                                aspectRatio: aspectRatio,
                                child: Image.network(
                                  logoUrl,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const ErrorImage(size: 60);
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            width: 125,
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 65,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 4),
                    //   child: Text(
                    //     '061 56 11 54 / 096 233 46 84',
                    //     maxLines: 1,
                    //     textAlign: TextAlign.start,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: TextStyle(fontSize: 12),
                    //   ),
                    // ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Text(
                        address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4, right: 4),
                      child: Text(
                        expert,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Row(
              //   children: [
              //     Expanded(
              //       child: Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: Row(
              //           children: [
              //             Text(
              //               likes,
              //               maxLines: 1,
              //               overflow: TextOverflow.ellipsis,
              //               style: TextStyle(
              //                 fontSize: 16,
              //                 color: Colors.grey,
              //               ),
              //             ),
              //             Text(
              //               ' Likes',
              //               maxLines: 1,
              //               overflow: TextOverflow.ellipsis,
              //               style: TextStyle(
              //                 fontSize: 14,
              //                 color: Colors.grey.shade400,
              //               ),
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //     IconButton(
              //       onPressed: () {},
              //       icon: Icon(
              //         Icons.thumb_up_outlined,
              //         size: 24,
              //         color: Theme.of(context)
              //             .colorScheme
              //             .primary
              //             .withOpacity(0.5),
              //       ),
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
