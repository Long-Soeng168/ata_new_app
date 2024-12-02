class VideoPlaylist {
  final int id;
  final String name;
  final String imageUrl;
  final String description;
  final String price;
  final String videosCount;

  final int teacherId;
  final String teacherName;

  final int categoryId;
  final String categoryName;

  VideoPlaylist({
    required this.id, 
    required this.name, 
    required this.imageUrl,
    required this.description,
    required this.price,
    required this.videosCount, 
    required this.teacherId, 
    required this.teacherName, 
    required this.categoryId, 
    required this.categoryName,
  });

  // Convert a VideoPlaylist to a Map (for JSON encoding)
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'imageUrl': imageUrl,
    'description': description,
    'price': price,
    'videosCount': videosCount,
    'teacherId': teacherId,
    'teacherName': teacherName,
    'categoryId': categoryId,
    'categoryName': categoryName,
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
      teacherId: json['teacherId'],
      teacherName: json['teacherName'],
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
    );
  }
}
