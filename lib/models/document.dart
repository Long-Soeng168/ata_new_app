class Document {
  final List<String> folders;
  final List<String> files;
  final String status; // can_read, need_login, need_purchase

  Document({
    required this.folders,
    required this.files,
    required this.status,
  });
}
