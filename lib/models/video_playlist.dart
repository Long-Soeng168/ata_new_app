class VideoPlaylist {
  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final String price;
  final String videosCount;

  VideoPlaylist({
    required this.id, 
    required this.name, 
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.videosCount, 
  });

  // Convert a VideoPlaylist to a Map (for JSON encoding)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'description': description,
    'price': price,
    'videosCount': videosCount,
  };

  // Create a VideoPlaylist from a Map (for JSON decoding)
  factory VideoPlaylist.fromJson(Map<String, dynamic> json) {
    return VideoPlaylist(
      id: json['id'],
      name: json['name'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      price: json['price'],
      videosCount: json['videosCount'],
    );
  }
}
