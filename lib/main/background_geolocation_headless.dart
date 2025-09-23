import 'package:flutter_background_geolocation/flutter_background_geolocation.dart'
    as bg;
import 'package:mighty_delivery/main/network/http_utils.dart';
import 'package:mighty_delivery/main/utils/storage.dart';

@pragma('vm:entry-point')
void backgroundGeolocationHeadlessTask(bg.HeadlessEvent event) async {
  switch (event.name) {
    case bg.Event.LOCATION:
      final loc = event.event as bg.Location;
      final vehicleId = SpUtil.getJSON("vehicleId");
      try {
        final resp =
            await HttpUtils.postJson('/api/mobile/locations/create', data: {
          'address': 'location.',
          'VehicleId': vehicleId,
          'latitude': loc.coords.latitude,
          'longitude': loc.coords.longitude,
        });
        if (resp.code == 0) {
          print(
              '[HEADLESS] upload success ${DateTime.now().toUtc().toIso8601String()}');
        } else {
          print('[HEADLESS] upload fail code=${resp.code}');
        }
      } catch (e) {
        print('[HEADLESS] upload exception $e');
      }
      break;
    case bg.Event.HEARTBEAT:
      print('[HEADLESS] HEARTBEAT');
      break;
    case bg.Event.TERMINATE:
      print('[HEADLESS] TERMINATE');
      break;
    default:
      break;
  }
}
