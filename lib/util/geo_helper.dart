import 'package:google_maps_flutter/google_maps_flutter.dart';

class GeoHelper {
  GeoHelper();
  LatLng getFinalPosition(List startLatLng, List stopLatLng, double distance) {
    // final tangentTheta = ((stopLatLng[0] - startLatLng[0])/(stopLatLng[1] - startLatLng[1]));
    // final tangentThetaSq = pow(tangentTheta, 2);
    // final latDirection = (stopLatLng[0] - startLatLng[0])/(stopLatLng[0] - startLatLng[0]).abs();
    // final lngDirection = (stopLatLng[1] - startLatLng[1])/(stopLatLng[1] - startLatLng[1]).abs();
    // final lngDistance = sqrt(distance/(1+ tangentThetaSq));
    // final latDistance = tangentTheta*lngDistance;
    // return [startLatLng[0] + latDistance*latDirection, startLatLng[1] + lngDistance*lngDirection];
    return LatLng((startLatLng[0] + stopLatLng[0])/2, (startLatLng[1] + stopLatLng[1])/2);
  }

}