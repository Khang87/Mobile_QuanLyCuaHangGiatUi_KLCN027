import 'package:app_quanly_giaiui/features/order/domain/laundry_order_pricing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LaundryOrderPricing.redeemablePoints', () {
    test('limits points at one VND per point and available balance', () {
      expect(
        LaundryOrderPricing.redeemablePoints(
          availablePoints: 141000,
          subtotalMinorUnits: 2000000,
        ),
        20000,
      );
      expect(
        LaundryOrderPricing.redeemablePoints(
          availablePoints: 500,
          subtotalMinorUnits: 2000000,
        ),
        500,
      );
      expect(
        LaundryOrderPricing.redeemablePoints(
          availablePoints: 500,
          subtotalMinorUnits: 999,
        ),
        9,
      );
    });

    test('converts points to minor currency units', () {
      expect(LaundryOrderPricing.pointsDiscountMinorUnits(2000), 200000);
    });
  });

  group('LaundryOrderPricing.lineTotalMinorUnits', () {
    test('calculates a quantity-priced line', () {
      expect(
        LaundryOrderPricing.lineTotalMinorUnits(
          unitPriceVnd: 25000,
          quantity: 3,
        ),
        7500000,
      );
    });

    test('calculates and rounds a weight-priced line to two decimals', () {
      expect(
        LaundryOrderPricing.lineTotalMinorUnits(
          unitPriceVnd: 30000,
          weightKg: 1.35,
        ),
        4050000,
      );
      expect(
        LaundryOrderPricing.lineTotalMinorUnits(
          unitPriceVnd: 15500,
          weightKg: 0.125,
        ),
        201500,
      );
    });

    test('rejects missing, conflicting, and non-positive measurements', () {
      expect(
        () => LaundryOrderPricing.lineTotalMinorUnits(unitPriceVnd: 1000),
        throwsArgumentError,
      );
      expect(
        () => LaundryOrderPricing.lineTotalMinorUnits(
          unitPriceVnd: 1000,
          quantity: 1,
          weightKg: 1,
        ),
        throwsArgumentError,
      );
      expect(
        () => LaundryOrderPricing.lineTotalMinorUnits(
          unitPriceVnd: 1000,
          quantity: 0,
        ),
        throwsArgumentError,
      );
    });
  });

  group('LaundryOrderPricing.totalMinorUnits', () {
    test('adds delivery then applies promotion and points discounts', () {
      expect(
        LaundryOrderPricing.totalMinorUnits(
          lineTotalsMinorUnits: [7500000, 4050000],
          deliveryFeeMinorUnits: 150000,
          promotionDiscountMinorUnits: 1000000,
          pointsDiscountMinorUnits: 50000,
        ),
        10650000,
      );
    });

    test('rejects discounts greater than the subtotal and delivery fee', () {
      expect(
        () => LaundryOrderPricing.totalMinorUnits(
          lineTotalsMinorUnits: [10000],
          promotionDiscountMinorUnits: 10001,
        ),
        throwsArgumentError,
      );
    });
  });
}
