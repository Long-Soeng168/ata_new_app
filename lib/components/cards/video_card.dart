import 'package:ata_new_app/components/error_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class VideoCard extends StatelessWidget {
  const VideoCard({
    super.key,
    this.id = 0,
    this.ownPlaylist = false,
    this.title = '',
    this.viewsCount = '0',
    this.imageUrl = '',
    this.onTap,
    this.aspectRatio = 1 / 1,
    this.width = 200,
    this.isPlaying = false,
    this.isFree = false,
  });

  final int id;
  final bool ownPlaylist;
  final String title;
  final String viewsCount;
  final String imageUrl;
  final void Function()? onTap;
  final double aspectRatio;
  final double width;
  final bool isPlaying;
  final bool isFree;

  @override
  Widget build(BuildContext context) {
    print(ownPlaylist);
    return Opacity(
      opacity: (isFree || ownPlaylist) ? 1 : 0.65,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(top: 2, right: 4, left: 4),
          child: Card(
            color: isPlaying
                ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                : Colors.white,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: aspectRatio,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        // width: 160,
                        // height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const ErrorImage(size: 100);
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.remove_red_eye_outlined,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$viewsCount Views',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            isFree
                                ? Text(
                                    'Free',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                  )
                                : Icon(
                                    ownPlaylist ? Icons.play_arrow_outlined : Icons.lock_outline,
                                    color: ownPlaylist ? Theme.of(context).colorScheme.primary : Colors.redAccent,
                                  )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
