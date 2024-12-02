class PublicationDetail {
  int? id;
  String? name;
  String? isbn;
  String? year;
  int? pagesCount;
  int? edition;
  String? link;
  String? description;
  String? keywords;
  String? image;
  String? pdf;

  int? authorId;
  String? authorName;

  int? publisherId;
  String? publisherName;

  int? languageId;
  String? languageName;

  int? locationId;
  String? locationName;

  int? typeId;
  String? typeName;

  int? categoryId;
  String? categoryName;

  int? subCategoryId;
  String? subCategoryName;

  int? userId;
  String? userName;

  int? readCount;
  int? downloadCount;
  int? canDownload;
  int? canRead;
  int? status;
  String? createdAt;
  String? updatedAt;

  PublicationDetail(
      {this.id,
      this.name,
      this.isbn,
      this.year,
      this.pagesCount,
      this.edition,
      this.link,
      this.description,
      this.keywords,
      this.image,
      this.pdf,

      this.authorId,
      this.authorName,

      this.publisherId,
      this.publisherName,

      this.languageId,
      this.languageName,

      this.locationId,
      this.locationName,

      this.typeId,
      this.typeName,

      this.categoryId,
      this.categoryName,

      this.subCategoryId,
      this.subCategoryName,

      this.userId,
      this.userName,

      this.readCount,
      this.downloadCount,
      this.canDownload,
      this.canRead,
      this.status,
      this.createdAt,
      this.updatedAt,
    });

}