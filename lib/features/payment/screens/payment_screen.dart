import 'package:flutter/material.dart';
import 'package:app_quanly_giaiui/core/constants/app_strings.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/features/order/data/order_repository.dart';
import 'package:app_quanly_giaiui/features/payment/data/payment_repository.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({required this.orderId, super.key});

  final String orderId;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _repository = PaymentRepository();
  final _idempotencyKey = OrderRepository.createIdempotencyKey();
  late Future<PaymentDetails> _detailsFuture;
  bool _isSubmitting = false;
  String? _errorMessage;

  int? get _orderId => int.tryParse(widget.orderId);

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadDetails();
  }

  Future<PaymentDetails> _loadDetails() {
    final id = _orderId;
    if (id == null) throw const FormatException('Mã đơn không hợp lệ.');
    return _repository.getPaymentDetails(id);
  }

  Future<void> _refresh() async {
    final future = _loadDetails();
    setState(() {
      _detailsFuture = future;
    });
    await future;
  }

  Future<void> _requestPayment(String method) async {
    final id = _orderId;
    if (id == null) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });
    try {
      await _repository.requestPayment(
        orderId: id,
        method: method,
        idempotencyKey: _idempotencyKey,
      );
      await _refresh();
    } catch (error) {
      if (mounted) setState(() => _errorMessage = '$error');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.payment)),
      body: FutureBuilder<PaymentDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: _refresh,
                child: const Text('Không tải được hóa đơn. Thử lại'),
              ),
            );
          }

          final details = snapshot.data!;
          final invoice = details.invoice;
          if (invoice == null) {
            return const Center(child: Text('Đơn hàng chưa có hóa đơn.'));
          }

          final pending = details.payments.where(
            (payment) => payment.status == 'Chờ thanh toán',
          );
          final isPaid = invoice.status == 'Đã thanh toán';
          final paymentMethod = details.paymentMethod ?? 'Chuyển khoản';
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Hóa đơn ${invoice.number}',
                  style: AppTypography.heading2,
                ),
                const SizedBox(height: 8),
                Text(
                  'Đơn hàng #${widget.orderId}',
                  style: AppTypography.bodyText.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primaryExtraLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tổng thanh toán'),
                      const SizedBox(height: 8),
                      Text(
                        '${invoice.total.toStringAsFixed(0)} đ',
                        style: AppTypography.heading1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(isPaid ? 'Đã thanh toán' : invoice.status),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (isPaid)
                  const _PaymentMessage(
                    icon: Icons.check_circle_outline,
                    text: 'Hóa đơn đã được cửa hàng xác nhận thanh toán.',
                  )
                else if (pending.isNotEmpty)
                  _PaymentMessage(
                    icon: Icons.hourglass_top,
                    text:
                        'Đã ghi nhận yêu cầu ${pending.first.method.toLowerCase()}. '
                        'Thanh toán sẽ hoàn tất sau khi cửa hàng đối soát.',
                  )
                else ...[
                  Text('Hình thức thanh toán', style: AppTypography.heading3),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      paymentMethod == 'Tiền mặt'
                          ? Icons.payments_outlined
                          : Icons.account_balance_outlined,
                    ),
                    title: Text(paymentMethod),
                    subtitle: const Text('Đã chọn khi tạo đơn hàng'),
                  ),
                  const SizedBox(height: 12),
                  const _PaymentMessage(
                    icon: Icons.info_outline,
                    text:
                        'Yêu cầu thanh toán sẽ ở trạng thái chờ cho đến khi nhân viên xác nhận.',
                  ),
                  const SizedBox(height: 12),
                  const _PaymentMessage(
                    icon: Icons.account_balance_wallet_outlined,
                    text:
                        'MoMo chưa khả dụng: cần cấu hình merchant và callback đối soát trước khi bật.',
                  ),
                ],
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                  ),
                ],
              ],
            ),
          );
        },
      ),
      bottomSheet: FutureBuilder<PaymentDetails>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          final details = snapshot.data;
          final canRequest =
              details?.invoice?.status == 'Chưa thanh toán' &&
              !(details?.payments.any(
                    (payment) => payment.status == 'Chờ thanh toán',
                  ) ??
                  false);
          if (!canRequest) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => _requestPayment(
                          details?.paymentMethod ?? 'Chuyển khoản',
                        ),
                  child: _isSubmitting
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Gửi yêu cầu thanh toán'),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PaymentMessage extends StatelessWidget {
  const _PaymentMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
