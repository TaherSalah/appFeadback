class PdfBookModel {
  final String id;
  final String title;
  final String url;
  final String? coverUrl; // Optional: URL for book cover image
  final String fileName; // Local file name
  bool isDownloaded;

  PdfBookModel({
    required this.id,
    required this.title,
    required this.url,
    required this.fileName,
    this.coverUrl,
    this.isDownloaded = false,
  });
}
