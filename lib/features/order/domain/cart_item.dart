import 'package:app_quanly_giaiui/features/order/data/order_repository.dart';

/// Represents a single item in the laundry order cart
class CartItem {
  const CartItem({required this.price, required this.measurement});

  final LaundryPriceOption price;
  final num measurement;

  bool get isWeightBased {
    final symbol = price.unitSymbol.toLowerCase();
    return symbol == 'kg' || symbol == 'kilogram';
  }

  int get estimatedTotalMinorUnits {
    // Import and use LaundryOrderPricing when calculating
    final unitPriceMinorUnits = (price.unitPriceVnd * 100).round();
    final measurementHundredths = (measurement * 100).round();
    final product = unitPriceMinorUnits * measurementHundredths;
    return (product + 50) ~/ 100;
  }

  Map<String, dynamic> toJson() => {
    'banggiaid': price.priceId,
    'measurement': measurement,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem &&
          runtimeType == other.runtimeType &&
          price.priceId == other.price.priceId &&
          measurement == other.measurement;

  @override
  int get hashCode => Object.hash(price.priceId, measurement);
}
