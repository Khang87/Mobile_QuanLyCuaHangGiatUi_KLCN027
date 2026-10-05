import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/features/review/data/review_repository.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({required this.orderId, super.key});

  final String orderId;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _repository = ReviewRepository();
  final _commentController = TextEditingController();
  int _rating = 5;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasExistingReview = false;
  String? _loadError;
  String? _errorMessage;

  int? get _orderId => int.tryParse(widget.orderId);

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  Future<void> _loadReview() async {
    final orderId = _orderId;
    if (orderId == null) {
      setState(() {
        _loadError = 'Mã đơn hàng không hợp lệ.';
        _isLoading = false;
      });
      return;
    }

    try {
      final review = await _repository.getReviewForOrder(orderId);
      if (!mounted) return;
      setState(() {
        _rating = (review?['SoSao'] as num?)?.toInt() ?? 5;
        _commentController.text = review?['BinhLuan'] as String? ?? '';
        _hasExistingReview = review != null;
        _loadError = null;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loadError = 'Không thể tải đánh giá hiện tại.');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final orderId = _orderId;
    if (orderId == null || _isLoading || _loadError != null) return;
    final isUpdating = _hasExistingReview;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _repository.submitReview(
        orderId: orderId,
        rating: _rating,
        comment: _commentController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isUpdating
                ? 'Đánh giá đã được cập nhật.'
                : 'Cảm ơn bạn đã đánh giá dịch vụ.',
          ),
        ),
      );
      context.pop();
    } catch (error) {
      if (mounted) setState(() => _errorMessage = '$error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đánh giá dịch vụ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_loadError!),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _loadError = null;
                      });
                      _loadReview();
                    },
                    child: const Text('Thử tải lại'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text('Chất lượng dịch vụ', style: AppTypography.heading2),
                const SizedBox(height: 8),
                Text(
                  'Đơn hàng #${widget.orderId}',
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final value = index + 1;
                    return IconButton(
                      tooltip: '$value sao',
                      onPressed: () => setState(() => _rating = value),
                      icon: Icon(
                        value <= _rating ? Icons.star : Icons.star_border,
                        color: AppColors.warning,
                        size: 36,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _commentController,
                  maxLength: 1000,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Bình luận trải nghiệm',
                    hintText:
                        'Dịch vụ, thái độ phục vụ, thời gian giao nhận...',
                    alignLabelWithHint: true,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
              ],
            ),
      bottomSheet: Container(
        color: AppColors.surface,
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSubmitting || _isLoading || _loadError != null
                  ? null
                  : _submit,
              icon: _isSubmitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.rate_review_outlined),
              label: Text(
                _hasExistingReview ? 'Cập nhật đánh giá' : 'Gửi đánh giá',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
