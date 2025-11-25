/// Helper class to format DateTime as "time ago" strings
class TimeAgoHelper {
  /// Format a DateTime to "time ago" string in Vietnamese
  /// 
  /// Examples:
  /// - 'Vừa xong' (just now)
  /// - '5 phút trước' (5 minutes ago)
  /// - '2 giờ trước' (2 hours ago)
  /// - '3 ngày trước' (3 days ago)
  /// - '2 tuần trước' (2 weeks ago)
  /// - '1 tháng trước' (1 month ago)
  static String formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} phút trước';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks tuần trước';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months tháng trước';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years năm trước';
    }
  }
  
  /// Format a DateTime to short "time ago" string (for compact display)
  /// 
  /// Examples:
  /// - 'Vừa xong'
  /// - '5p' (5 minutes)
  /// - '2h' (2 hours)
  /// - '3d' (3 days)
  /// - '2w' (2 weeks)
  static String formatTimeAgoShort(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}p';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '${months}mo';
    } else {
      final years = (difference.inDays / 365).floor();
      return '${years}y';
    }
  }
}
