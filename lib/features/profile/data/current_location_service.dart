import 'dart:async';

import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class CurrentLocationResult {
  const CurrentLocationResult({
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final String address;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
}

class CurrentLocationService {
  CurrentLocationService();

  static const _maximumAccuracyMeters = 50.0;
  static const _maximumFixAge = Duration(seconds: 30);

  Future<CurrentLocationResult> getCurrentAddress() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const CurrentLocationException('Vui lòng bật dịch vụ vị trí.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const CurrentLocationException(
        'Bạn chưa cấp quyền truy cập vị trí.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const CurrentLocationException(
        'Quyền vị trí đã bị từ chối. Hãy bật quyền trong Cài đặt.',
      );
    }
    if (await Geolocator.getLocationAccuracy() !=
        LocationAccuracyStatus.precise) {
      throw const CurrentLocationException(
        'Ứng dụng đang được cấp vị trí gần đúng. Hãy bật "Vị trí chính xác" '
        'trong quyền ứng dụng rồi thử lại.',
      );
    }

    final Position position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          timeLimit: Duration(seconds: 25),
        ),
      );
    } on TimeoutException {
      throw const CurrentLocationException(
        'Không lấy được vị trí. Vui lòng kiểm tra GPS và thử lại.',
      );
    } on LocationServiceDisabledException {
      throw const CurrentLocationException('Vui lòng bật dịch vụ vị trí.');
    }

    if (!position.accuracy.isFinite ||
        position.accuracy > _maximumAccuracyMeters) {
      throw CurrentLocationException(
        'GPS hiện chỉ chính xác trong khoảng ±${position.accuracy.ceil()} m. '
        'Hãy ra nơi thoáng và thử lại.',
      );
    }
    if (DateTime.now().difference(position.timestamp) > _maximumFixAge) {
      throw const CurrentLocationException(
        'GPS trả về vị trí cũ. Hãy bật dịch vụ vị trí và thử lại.',
      );
    }

    try {
      final placemarks = await Geocoding(
        locale: const Locale('vi', 'VN'),
      ).placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      ).timeout(const Duration(seconds: 10));
      final detailedPlacemark = placemarks
          .where((placemark) => _streetAddress(placemark).isNotEmpty)
          .firstOrNull;
      if (detailedPlacemark == null) {
        throw const CurrentLocationException(
          'Không tìm được tên đường tại vị trí này. Hãy chọn địa chỉ đã lưu '
          'hoặc nhập địa chỉ thủ công.',
        );
      }
      return CurrentLocationResult(
        address: _limitAddress(_formatPlacemark(detailedPlacemark)),
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );
    } on CurrentLocationException {
      rethrow;
    } on Exception {
      throw const CurrentLocationException(
        'Không tra được địa chỉ đường/phố. Hãy chọn địa chỉ đã lưu hoặc nhập '
        'địa chỉ thủ công.',
      );
    }
  }

  String _streetAddress(Placemark placemark) {
    final road = placemark.thoroughfare?.trim();
    final houseNumber = placemark.subThoroughfare?.trim();
    final street = placemark.street?.trim();
    return street != null && street.isNotEmpty
        ? street
        : [houseNumber, road]
              .whereType<String>()
              .where((part) => part.isNotEmpty)
              .join(' ');
  }

  String _formatPlacemark(Placemark placemark) {
    final parts = <String>[_streetAddress(placemark)];

    for (final value in [
      placemark.subLocality,
      placemark.locality,
      placemark.subAdministrativeArea,
      placemark.administrativeArea,
      placemark.country,
    ]) {
      for (final candidate in value?.split(',') ?? const <String>[]) {
        final part = candidate.trim();
        if (part.isNotEmpty && !parts.contains(part)) parts.add(part);
      }
    }
    return parts.join(', ');
  }

  String _limitAddress(String address) =>
      address.length > 500 ? address.substring(0, 500) : address;
}

class CurrentLocationException implements Exception {
  const CurrentLocationException(this.message);

  final String message;
}
