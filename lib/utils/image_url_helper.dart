/// Helper class to format and fix image URLs
class ImageUrlHelper {
  /// Convert a relative or localhost image URL to use the correct IP
  /// 
  /// Examples:
  /// - '/uploads/image.jpg' → 'https://10.227.9.96:7043/uploads/image.jpg'
  /// - 'localhost:7043/uploads/image.jpg' → 'https://10.227.9.96:7043/uploads/image.jpg'
  /// - 'https://localhost:7043/uploads/image.jpg' → 'https://10.227.9.96:7043/uploads/image.jpg'
  static String formatImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return '';
    }

    // Already a full valid URL with correct IP
    if (imageUrl.contains('10.227.9.96:7043')) {
      return imageUrl;
    }

    // If it's just a path like /uploads/...
    if (imageUrl.startsWith('/')) {
      return 'https://10.227.9.96:7043$imageUrl';
    }

    // Replace localhost with IP (keep port 7043 for image server)
    String url = imageUrl;
    url = url.replaceAll('localhost', '10.227.9.96');
    url = url.replaceAll('http://', 'https://');

    // Ensure it starts with https:// 
    if (!url.startsWith('https://')) {
      url = 'https://$url';
    }

    return url;
  }

  /// Get the base image URL for constructing relative paths
  static String get imageBaseUrl => 'https://10.227.9.96:7043';

  /// Get full image URL from relative path
  static String getFullImageUrl(String relativePath) {
    if (relativePath.isEmpty) return '';
    final path = relativePath.startsWith('/') ? relativePath : '/$relativePath';
    return '$imageBaseUrl$path';
  }
}

