import 'package:ata_new_app/components/error_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class MyGalleryViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const MyGalleryViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  _MyGalleryViewerState createState() => _MyGalleryViewerState();
}

class _MyGalleryViewerState extends State<MyGalleryViewer> {
  late int currentIndex;
  late PageController _pageController;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void toggleFullScreen() {
    setState(() {
      isFullScreen = !isFullScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: isFullScreen
          ? null
          : AppBar(
              foregroundColor: Theme.of(context).colorScheme.primary,
              title: Text(
                '${"Image".tr()} ${currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(
                    isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                  ),
                  onPressed: toggleFullScreen,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 80),
            child: GestureDetector(
              onTap: toggleFullScreen,
              child: PhotoViewGallery.builder(
                itemCount: widget.imageUrls.length,
                pageController: _pageController,
                builder: (context, index) {
                  return PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(widget.imageUrls[index]),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    heroAttributes:
                        PhotoViewHeroAttributes(tag: widget.imageUrls[index]),
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                scrollPhysics: const BouncingScrollPhysics(),
                backgroundDecoration: const BoxDecoration(color: Colors.black),
              ),
            ),
          ),
          if (!isFullScreen)
            ThumbnailStrip(
              imageUrls: widget.imageUrls,
              currentIndex: currentIndex,
              onTap: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
        ],
      ),
    );
  }
}

class ThumbnailStrip extends StatefulWidget {
  final List<String> imageUrls;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const ThumbnailStrip({
    super.key,
    required this.imageUrls,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  _ThumbnailStripState createState() => _ThumbnailStripState();
}

class _ThumbnailStripState extends State<ThumbnailStrip> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void didUpdateWidget(covariant ThumbnailStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != oldWidget.currentIndex) {
      _scrollToCurrentThumbnail();
    }
  }

  void _scrollToCurrentThumbnail() {
    final double screenWidth = MediaQuery.of(context).size.width;
    const double itemWidth = 80.0 + 8.0; // Thumbnail width + margin

    // Calculate the position where the current thumbnail should be centered
    final double targetPosition =
        (widget.currentIndex * itemWidth) - (screenWidth - itemWidth) / 2;

    // Ensure the target position is within valid scroll range
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;
    final double clampedPosition = targetPosition.clamp(0.0, maxScrollExtent);

    _scrollController.animateTo(
      clampedPosition,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 10.0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 80.0, // Adjust height if needed
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: widget.imageUrls.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => widget.onTap(index),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                padding: const EdgeInsets.all(2.0),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.currentIndex == index
                        ? Colors.white
                        : Colors.transparent,
                  ),
                ),
                child: Image.network(
                  widget.imageUrls[index],
                  width: 80.0,
                  height: 80.0,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const ErrorImage(size: 50);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
