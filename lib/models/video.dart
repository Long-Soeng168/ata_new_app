class Video {
  final int id;
  final String name;
  final String viewsCount;
  final String imageUrl;
  final String videoUrl;
  final String description;
  final bool isFree;

  Video({
      required this.id,
      this.name = '',
      this.imageUrl = '',
      this.videoUrl = '',
      this.viewsCount = '',
      this.description = '',
      this.isFree = false,
  });
}
