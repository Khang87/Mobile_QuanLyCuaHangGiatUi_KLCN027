import 'package:supabase_flutter/supabase_flutter.dart';

class ReviewRepository {
  ReviewRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<Map<String, dynamic>?> getReviewForOrder(int orderId) async {
    return _client
        .from('DanhGia')
        .select('SoSao,BinhLuan')
        .eq('DonHangID', orderId)
        .maybeSingle();
  }

  Future<void> submitReview({
    required int orderId,
    required int rating,
    required String comment,
  }) async {
    await _client.rpc(
      'submit_order_review',
      params: {
        'p_donhangid': orderId,
        'p_sosao': rating,
        'p_binhluan': comment.trim().isEmpty ? null : comment.trim(),
      },
    );
  }
}
