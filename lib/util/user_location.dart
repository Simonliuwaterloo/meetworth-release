import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserLocation{
  var currentLocation;
  var _location;

  UserLocation() {
    this.currentLocation = LocationData;
    this._location = new Location();
  }
  Future<double> getLat() async {
    try {
      this.currentLocation = await this._location.getLocation();
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      } 
      currentLocation = null;
    }
    print(currentLocation.latitude);
    return currentLocation.latitude;
  }

  Future<double> getLng() async {
    try {
      this.currentLocation = await this._location.getLocation();
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        print('Permission denied');
      } 
      currentLocation = null;
    }
    return currentLocation.longitude;
  }

  Future<LatLng> getLatLng() async {
    double lat = await getLat();
    double lng = await getLng();
    return LatLng(lat, lng);
  }
}