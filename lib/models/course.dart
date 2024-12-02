class Course {
  final int id;
  final String name;
  final String imageUrl;

  final String description;
  final String price;
  final String start;
  final String end;

  Course({
    required this.id, 
    required this.name, 
    required this.imageUrl,
    this.description = '',
    this.price = '',
    this.start = '',
    this.end = '',
  });
}
