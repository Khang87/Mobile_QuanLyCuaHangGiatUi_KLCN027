class LaundryOrderPricing {
  static const _minorUnitsPerVnd = 100;
  static const _vndPerPoint = 1;

  static int redeemablePoints({
    required int availablePoints,
    required int subtotalMinorUnits,
  }) {
    if (availablePoints < 0 || subtotalMinorUnits < 0) {
      throw ArgumentError('Points and subtotal cannot be negative.');
    }

    final pointsForSubtotal =
        subtotalMinorUnits ~/ (_vndPerPoint * _minorUnitsPerVnd);
    return availablePoints < pointsForSubtotal
        ? availablePoints
        : pointsForSubtotal;
  }

  static int pointsDiscountMinorUnits(int points) {
    if (points < 0) throw ArgumentError.value(points, 'points');
    return points * _vndPerPoint * _minorUnitsPerVnd;
  }

  static int lineTotalMinorUnits({
    required num unitPriceVnd,
    num? quantity,
    num? weightKg,
  }) {
    if (!unitPriceVnd.isFinite || unitPriceVnd < 0) {
      throw ArgumentError.value(unitPriceVnd, 'unitPriceVnd');
    }
    if ((quantity == null) == (weightKg == null)) {
      throw ArgumentError('Provide exactly one of quantity or weightKg.');
    }

    final measurement = quantity ?? weightKg!;
    if (!measurement.isFinite || measurement <= 0) {
      throw ArgumentError.value(measurement, 'measurement');
    }

    final unitPriceMinorUnits = (unitPriceVnd * _minorUnitsPerVnd).round();
    final measurementHundredths = (measurement * 100).round();
    final product = unitPriceMinorUnits * measurementHundredths;
    return (product + 50) ~/ 100;
  }

  static int totalMinorUnits({
    required Iterable<int> lineTotalsMinorUnits,
    int deliveryFeeMinorUnits = 0,
    int promotionDiscountMinorUnits = 0,
    int pointsDiscountMinorUnits = 0,
  }) {
    if (deliveryFeeMinorUnits < 0 ||
        promotionDiscountMinorUnits < 0 ||
        pointsDiscountMinorUnits < 0) {
      throw ArgumentError('Fees and discounts cannot be negative.');
    }

    var subtotal = 0;
    for (final lineTotal in lineTotalsMinorUnits) {
      if (lineTotal < 0) {
        throw ArgumentError.value(lineTotal, 'lineTotalsMinorUnits');
      }
      subtotal += lineTotal;
    }

    final totalBeforeDiscount = subtotal + deliveryFeeMinorUnits;
    final total =
        totalBeforeDiscount -
        promotionDiscountMinorUnits -
        pointsDiscountMinorUnits;
    if (total < 0) {
      throw ArgumentError('Discounts cannot exceed the order amount.');
    }
    return total;
  }
}
