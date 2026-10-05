import 'package:supabase_flutter/supabase_flutter.dart';

class LoyaltyVoucher {
  const LoyaltyVoucher({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discountValue,
    this.minimumOrder,
    this.maximumDiscount,
    this.condition,
  });

  final int id;
  final String code;
  final String title;
  final String discountType;
  final num discountValue;
  final num? minimumOrder;
  final num? maximumDiscount;
  final String? condition;

  factory LoyaltyVoucher.fromJson(Map<String, dynamic> json) {
    return LoyaltyVoucher(
      id: (json['khuyenmaiid'] as num).toInt(),
      code: json['makhuyenmai'] as String,
      title: json['tenkhuyenmai'] as String,
      discountType: json['loaikhuyenmai'] as String,
      discountValue: json['giatrigiam'] as num,
      minimumOrder: json['giatridontoithieu'] as num?,
      maximumDiscount: json['mucgiamtoida'] as num?,
      condition: json['dieukienapdung'] as String?,
    );
  }
}

class LoyaltySummary {
  const LoyaltySummary({required this.points, required this.vouchers});

  final int points;
  final List<LoyaltyVoucher> vouchers;

  factory LoyaltySummary.fromJson(Map<String, dynamic> json) {
    final rawVouchers = json['vouchers'] as List<dynamic>? ?? const [];
    return LoyaltySummary(
      points: (json['points'] as num? ?? 0).toInt(),
      vouchers: rawVouchers
          .whereType<Map<String, dynamic>>()
          .map(LoyaltyVoucher.fromJson)
          .toList(growable: false),
    );
  }
}

class LoyaltyRepository {
  LoyaltyRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  Future<LoyaltySummary> getSummary() async {
    final result = await _client.rpc('get_customer_loyalty');
    return LoyaltySummary.fromJson(result as Map<String, dynamic>);
  }
}
