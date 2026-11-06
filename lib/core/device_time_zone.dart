import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

/// Used when the phone does not say which time zone it is in.
const _fallbackTimeZone = 'Europe/Istanbul';

/// The phone's IANA time zone name, such as `Europe/Istanbul`. New
/// Households start in it.
final deviceTimeZoneProvider = FutureProvider<String>((ref) async {
  try {
    return (await FlutterTimezone.getLocalTimezone()).identifier;
  } catch (error) {
    debugPrint('Reading the phone time zone failed: $error');
    return _fallbackTimeZone;
  }
});
