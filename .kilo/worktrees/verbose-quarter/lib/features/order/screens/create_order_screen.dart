import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/navigation/app_routes.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/core/widgets/section_header.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  int _currentStep = 0;
  
  // Data
  String? _selectedService;
  String _deliveryMethod = 'pickup'; // pickup or self
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  final TextEditingController _notesController = TextEditingController();

  final List<String> _services = [
    'Giặt thường', 'Giặt khô', 'Ủi đồ', 'Giặt chăn mền', 'Giặt giày'
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onNextStep() {
    if (_currentStep < 2) {
      if (_currentStep == 0 && _selectedService == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn dịch vụ.')),
        );
        return;
      }
      
      setState(() {
        _currentStep++;
      });
    } else {
      // Go to summary
      context.pushNamed(AppRoutes.orderSummary);
    }
  }

  void _onPrevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.newOrder),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Timeline indicator
          _buildTimelineIndicator(),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStepView(),
            ),
          ),
          
          // Bottom Actions
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _onPrevStep,
                      child: Text(
                        _currentStep == 0 ? AppStrings.cancel : 'Quay lại',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _onNextStep,
                      child: Text(
                        _currentStep == 2 ? 'Xem Tóm tắt' : AppStrings.next,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          _buildTimelineNode(0, 'Dịch vụ'),
          _buildTimelineLine(0),
          _buildTimelineNode(1, 'Giao nhận'),
          _buildTimelineLine(1),
          _buildTimelineNode(2, 'Ghi chú'),
        ],
      ),
    );
  }

  Widget _buildTimelineNode(int index, String title) {
    final isActive = _currentStep >= index;
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.divider,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.textMuted,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTypography.caption.copyWith(
            color: isActive ? AppColors.primary : AppColors.textMuted,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(int index) {
    final isActive = _currentStep > index;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
        height: 2,
        color: isActive ? AppColors.primary : AppColors.divider,
      ),
    );
  }

  Widget _buildCurrentStepView() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Services();
      case 1:
        return _buildStep2Delivery();
      case 2:
        return _buildStep3Notes();
      default:
        return const SizedBox();
    }
  }

  // --- Step 1: Chọn dịch vụ ---
  Widget _buildStep1Services() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.selectService, style: AppTypography.heading2),
        const SizedBox(height: 8),
        Text('Bạn có thể mô tả cụ thể về đồ cần giặt ở bước Ghi chú.', 
          style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        
        ..._services.map((service) {
          final isSelected = _selectedService == service;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() => _selectedService = service);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.surface,
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle : Icons.circle_outlined,
                      color: isSelected ? AppColors.primary : AppColors.border,
                    ),
                    const SizedBox(width: 16),
                    Text(service, style: AppTypography.title),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- Step 2: Chọn hình thức giao nhận ---
  Widget _buildStep2Delivery() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.deliveryMethod, style: AppTypography.heading2),
        const SizedBox(height: 24),
        
        // Options
        Row(
          children: [
            Expanded(
              child: _buildDeliveryOption(
                'pickup', 
                AppStrings.pickupDelivery, 
                Icons.local_shipping_outlined
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDeliveryOption(
                'self', 
                AppStrings.selfDelivery, 
                Icons.storefront_outlined
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        if (_deliveryMethod == 'pickup') ...[
          Text('Địa chỉ lấy & giao đồ', style: AppTypography.heading3),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.error),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nhà riêng', style: AppTypography.title),
                      Text(
                        '123 Đường Điện Biên Phủ, Phường 15, Bình Thạnh, TP.HCM',
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                TextButton(onPressed: () {}, child: const Text('Thay đổi')),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          Text(AppStrings.pickupTime, style: AppTypography.heading3),
          const SizedBox(height: 12),
          
          // Time Pickers (Mocked structure for now)
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Ngày lấy',
                    prefixIcon: Icon(Icons.calendar_today),
                    hintText: 'Hôm nay',
                  ),
                  onTap: () async {
                    // TODO: showDatePicker
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Giờ lấy',
                    prefixIcon: Icon(Icons.access_time),
                    hintText: '14:00 - 15:00',
                  ),
                  onTap: () async {
                    // TODO: showTimePicker
                  },
                ),
              ),
            ],
          ),
        ] else ...[
          // Self Delivery Intro
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.infoLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bạn vui lòng mang đồ đến trực tiếp cửa hàng tại địa chỉ: 456 Hai Bà Trưng, Quận 1, TP.HCM.',
                    style: AppTypography.bodyText.copyWith(color: AppColors.info),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeliveryOption(String value, String title, IconData icon) {
    final isSelected = _deliveryMethod == value;
    return InkWell(
      onTap: () => setState(() => _deliveryMethod = value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.surface,
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              size: 40,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTypography.title.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Step 3: Ghi chú ---
  Widget _buildStep3Notes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppStrings.specialNotes, style: AppTypography.heading2),
        const SizedBox(height: 8),
        Text('Giúp chúng tôi chăm sóc đồ của bạn tốt hơn.', 
          style: AppTypography.bodyText.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 24),
        
        TextFormField(
          controller: _notesController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: AppStrings.notesHint,
            alignLabelWithHint: true,
          ),
        ),
        
        const SizedBox(height: 32),
        // Tip
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warningLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: AppColors.warning),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cửa hàng sẽ kiểm tra lại đồ đạc trong túi của bạn trước khi giặt và thông báo chi phí chính xác cuối cùng.',
                  style: AppTypography.bodySmall,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
