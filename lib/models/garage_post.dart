class GaragePost {
  final int id;
  final String name;
  final String imageUrl; // first image for convenience
  final String description;
  final List<String> images; // all image URLs

  GaragePost({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.images,
  });
}
