import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place{
  String name;
  LatLng latlng;

  Place(String name, LatLng latlng) {
    this.name = name;
    this.latlng = latlng;
  }
}