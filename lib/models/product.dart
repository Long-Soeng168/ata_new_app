class Product {
  final int id;
  final String name;
  final String price;
  final String imageUrl;
  final bool isInstock;

  final String description;
  final int categoryId;
  final int shopId;
  final String categoryName;
  final int bodyTypeId;
  final String bodyTypeName;
  final int brandId;
  final String brandName;
  final int modelId;
  final String modelName;
  final String createdAt;
  final List<String> imagesUrls;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.isInstock = true,
    
    this.description = '',
    this.categoryId = 0,
    this.shopId = 0,
    this.categoryName = '',
    this.bodyTypeId = 0,
    this.bodyTypeName = '',
    this.brandId = 0,
    this.brandName = '',
    this.modelId = 0,
    this.modelName = '',
    this.createdAt = '',
    List<String>? imagesUrls, // Use nullability
  }) : imagesUrls = imagesUrls ?? [];
}
