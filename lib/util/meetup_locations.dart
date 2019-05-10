import './network_util.dart';
import 'dart:convert';
import './geo_helper.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MeetUpLocations {
  LatLng _firstPlaceLatLng;
  LatLng _secondPlaceLatLng;
  LatLng _middleLatLng;
  NetworkUtil _networkUtil = NetworkUtil();

  MeetUpLocations(LatLng firstPlaceLatLng, LatLng secondPlaceLatLng) {
    this._firstPlaceLatLng = firstPlaceLatLng;
    this._secondPlaceLatLng = secondPlaceLatLng;
  }

  getMiddlePlaces() async {
    final DIRECTIONJSON = await this._networkUtil.getDirectionByLatLng(this._firstPlaceLatLng, this._secondPlaceLatLng);
    final STEPS = json.decode(DIRECTIONJSON)['routes'][0]['legs'][0]['steps'];
    final DISTANCE = json.decode(DIRECTIONJSON)['routes'][0]['legs'][0]['distance']['value'];
    final HALF_DISTANCE = DISTANCE / 2;
    double culmulatedDistance = 0;
    int indexOfMiddle = 0;
    double distanceOverflow = 0;
    for (var index = 0; index < STEPS.length; ++index) {
      if ( (culmulatedDistance + STEPS[index]['distance']['value']) > HALF_DISTANCE) {
        indexOfMiddle = index;
        distanceOverflow = HALF_DISTANCE - culmulatedDistance;
        break;
      } else {
        culmulatedDistance += STEPS[index]['distance']['value'];
      }
    }

    final startLoc = [STEPS[indexOfMiddle]['start_location']['lat'], STEPS[indexOfMiddle]['start_location']['lng']];
    final stopLoc = [STEPS[indexOfMiddle]['end_location']['lat'], STEPS[indexOfMiddle]['end_location']['lng']];
    var geoHelper = new GeoHelper();
    this._middleLatLng = geoHelper.getFinalPosition(startLoc, stopLoc, distanceOverflow);
    return(this._middleLatLng);
  }
}