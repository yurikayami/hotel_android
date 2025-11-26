import 'package:flutter/material.dart';

/// Legal Content Screen showing Privacy Policy and Terms of Service
class PrivacyTermsScreen extends StatefulWidget {
  final String initialTab; // 'privacy' or 'terms'

  const PrivacyTermsScreen({
    super.key,
    this.initialTab = 'privacy',
  });

  @override
  State<PrivacyTermsScreen> createState() => _PrivacyTermsScreenState();
}

class _PrivacyTermsScreenState extends State<PrivacyTermsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialIndex = widget.initialTab == 'terms' ? 1 : 0;
    _tabController = TabController(length: 2, vsync: this, initialIndex: initialIndex);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bảo mật & Điều khoản',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          tabs: const [
            Tab(
              icon: Icon(Icons.security),
              text: 'Chính sách bảo mật',
            ),
            Tab(
              icon: Icon(Icons.description),
              text: 'Điều khoản dịch vụ',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPrivacyContent(context, colorScheme, textTheme),
          _buildTermsContent(context, colorScheme, textTheme),
        ],
      ),
    );
  }

  /// Build privacy policy content
  Widget _buildPrivacyContent(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final sections = LegalContent.privacySections;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: sections.map((section) {
          return _buildLegalSection(
            context,
            section['title'] as String,
            section['content'] as String,
            section['icon'] as IconData?,
            colorScheme,
            textTheme,
          );
        }).toList(),
      ),
    );
  }

  /// Build terms of service content
  Widget _buildTermsContent(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    final sections = LegalContent.termsSections;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: sections.map((section) {
          return _buildLegalSection(
            context,
            section['title'] as String,
            section['content'] as String,
            section['icon'] as IconData?,
            colorScheme,
            textTheme,
          );
        }).toList(),
      ),
    );
  }

  /// Build individual legal section
  Widget _buildLegalSection(
    BuildContext context,
    String title,
    String content,
    IconData? icon,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title with icon
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 24,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Content with formatted text
              Text(
                content,
                style: textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LegalContent {
  /// Privacy Policy Sections with icons and structured content
  static List<Map<String, dynamic>> get privacySections => [
        {
          'title': '1. Thu thập dữ liệu',
          'icon': Icons.cloud_download,
          'content':
              '''Chúng tôi thu thập các thông tin cần thiết để cung cấp dịch vụ chăm sóc sức khỏe cá nhân hóa:

• Thông tin cơ bản: Tên, tuổi, chiều cao, cân nặng
• Dữ liệu sức khỏe: Lịch sử BMI, chỉ số dinh dưỡng mục tiêu
• Dữ liệu media: Hình ảnh món ăn để phân tích AI
• Dữ liệu hoạt động: Lịch sử theo dõi calo, dữ liệu yêu thích''',
        },
        {
          'title': '2. Sử dụng thông tin',
          'icon': Icons.analytics,
          'content':
              '''Thông tin của bạn được sử dụng để:

• Tính toán chỉ số BMI và nhu cầu calo hàng ngày
• Phân tích thành phần dinh dưỡng thông qua AI
• Gợi ý bài thuốc và món ăn phù hợp với thể trạng
• Cải thiện độ chính xác của thuật toán AI
• Cung cấp thống kê cá nhân và báo cáo sức khỏe''',
        },
        {
          'title': '3. Bảo mật dữ liệu',
          'icon': Icons.lock,
          'content':
              '''Chúng tôi cam kết bảo vệ thông tin của bạn:

• Mọi dữ liệu cá nhân được mã hóa khi lưu trữ
• KHÔNG chia sẻ thông tin sức khỏe cho bên thứ ba không có sự đồng ý
• Hình ảnh môn ăn có thể được xử lý ẩn danh để cải thiện AI
• Dữ liệu được bảo vệ bằng các chuẩn bảo mật quốc tế
• Thường xuyên kiểm toán bảo mật''',
        },
        {
          'title': '4. Quyền của người dùng',
          'icon': Icons.verified_user,
          'content':
              '''Bạn có các quyền sau:

• Xem, chỉnh sửa hoặc yêu cầu xóa toàn bộ dữ liệu cá nhân
• Tải xuất dữ liệu của bạn dưới dạng tệp
• Tắt quyền camera/thư viện ảnh bất cứ lúc nào
• Từ chối các tính năng phân tích AI
• Yêu cầu không nhận thông báo tiếp thị''',
        },
        {
          'title': '5. Cookie & Theo dõi',
          'icon': Icons.cookie,
          'content':
              '''Về việc sử dụng cookie và dữ liệu theo dõi:

• Chúng tôi sử dụng cookie để cải thiện trải nghiệm người dùng
• Dữ liệu phân tích được sử dụng để hiểu cách bạn sử dụng ứng dụng
• Bạn có thể vô hiệu hóa cookie trong cài đặt ứng dụng
• Chúng tôi tuân thủ GDPR và các quy định bảo mật toàn cầu''',
        },
        {
          'title': '6. Liên hệ & Hỗ trợ',
          'icon': Icons.contact_mail,
          'content':
              '''Nếu có thắc mắc về bảo mật:

• Email: nguyenngocphuc@gmail.com
• Chúng tôi sẽ phản hồi trong vòng 7 ngày làm việc
• Bạn có thể báo cáo lo ngại về bảo mật tại địa chỉ trên
• Liên hệ bất cứ lúc nào để yêu cầu xóa dữ liệu''',
        },
      ];

  /// Terms of Service Sections with icons and structured content
  static List<Map<String, dynamic>> get termsSections => [
        {
          'title': '1. Chấp nhận điều khoản',
          'icon': Icons.handshake,
          'content':
              '''Bằng việc sử dụng ứng dụng, bạn đồng ý:

• Tuân thủ tất cả các điều khoản sử dụng này
• Chịu trách nhiệm về tất cả hoạt động trên tài khoản của mình
• Cung cấp thông tin chính xác và cập nhật
• Không vi phạm bất kỳ quy tắc nào được nêu ra''',
        },
        {
          'title': '2. Từ chối trách nhiệm y tế',
          'icon': Icons.warning_amber,
          'content':
              '''⚠️ QUAN TRỌNG: Vui lòng đọc kỹ

• Ứng dụng chỉ mang tính hỗ trợ theo dõi sức khỏe và tham khảo dinh dưỡng
• Kết quả phân tích từ AI có thể có sai số
• KHÔNG thay thế lời khuyên, chẩn đoán hoặc điều trị từ bác sĩ
• Luôn tham khảo ý kiến bác sĩ trước khi áp dụng chế độ ăn kiêng
• Chúng tôi KHÔNG chịu trách nhiệm cho bất kỳ hậu quả sức khỏe nào''',
        },
        {
          'title': '3. Quy định sử dụng',
          'icon': Icons.rule,
          'content':
              '''Bạn đồng ý KHÔNG:

• Sử dụng ứng dụng cho mục đích phi pháp hoặc bất hợp pháp
• Tải lên hình ảnh phản cảm, bạo lực hoặc không liên quan
• Spam hoặc quấy rối các người dùng khác
• Cố gắng hack hoặc truy cập trái phép vào hệ thống
• Sử dụng bot hoặc tự động hóa trái phép''',
        },
        {
          'title': '4. Quản lý tài khoản',
          'icon': Icons.security,
          'content':
              '''Về tài khoản của bạn:

• Bạn chịu trách nhiệm bảo mật thông tin đăng nhập
• Chúng tôi có quyền khóa tài khoản nếu phát hiện vi phạm
• Bạn có thể xóa tài khoản bất cứ lúc nào trong cài đặt
• Xóa tài khoản sẽ xóa vĩnh viễn tất cả dữ liệu của bạn
• Chúng tôi sẽ xóa dữ liệu trong vòng 30 ngày''',
        },
        {
          'title': '5. Nội dung người dùng',
          'icon': Icons.image,
          'content':
              '''Về hình ảnh và nội dung bạn tải lên:

• Bạn giữ quyền sở hữu toàn bộ nội dung của mình
• Bạn cấp cho chúng tôi giấy phép để sử dụng nội dung để cải thiện dịch vụ
• Nội dung có thể được xử lý bằng AI để phân tích
• Chúng tôi không sử dụng nội dung của bạn cho mục đích quảng cáo
• Bạn có thể yêu cầu xóa nội dung bất cứ lúc nào''',
        },
        {
          'title': '6. Hạn chế trách nhiệm',
          'icon': Icons.gavel,
          'content':
              '''Giới hạn pháp lý:

• Ứng dụng được cung cấp "nguyên trạng" mà không có bảo hành
• Chúng tôi KHÔNG chịu trách nhiệm về tổn thất dữ liệu hoặc gián đoạn dịch vụ
• Trách nhiệm tối đa của chúng tôi không vượt quá số tiền bạn đã trả
• Chúng tôi không chịu trách nhiệm về tổn thất gián tiếp hoặc tư lợi''',
        },
        {
          'title': '7. Cập nhật điều khoản',
          'icon': Icons.update,
          'content':
              '''Về những thay đổi trong điều khoản:

• Chúng tôi có thể cập nhật điều khoản bất cứ lúc nào
• Các thay đổi sẽ được thông báo qua ứng dụng hoặc email
• Tiếp tục sử dụng ứng dụng có nghĩa là bạn chấp nhận các thay đổi
• Bạn có quyền từ chối các điều khoản mới bằng cách xóa tài khoản
• Bản điều khoản hiện tại có hiệu lực kể từ ngày cuối cùng cập nhật''',
        },
      ];

}
