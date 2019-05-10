import "package:google_maps_webservice/places.dart";
import 'dart:async';
import "package:google_maps_webservice/geocoding.dart";

import 'package:google_maps_flutter/google_maps_flutter.dart';

final geocoding = new GoogleMapsGeocoding(apiKey: ""YOUR_KEY"");

Future<PlacesSearchResponse> getPlaceByName(String placeText) async{
  //TODO: change access token
  final _places = new GoogleMapsPlaces(apiKey: ""YOUR_KEY"");
  PlacesSearchResponse response = await _places.searchByText(placeText);
  return response;
}

getPlacesByAutoComplete(String placeText) async {
  final _places = new GoogleMapsPlaces(
      apiKey: ""YOUR_KEY"");
  PlacesAutocompleteResponse res;
  try {
    res = await _places.autocomplete(placeText);
  } catch (e) {
    print(e.toString() + "cannot autocomplete");
  }
  //TODO:session token
  if (res.isOkay) {
    // list autocomplete prediction
    List<String> placeList = [];
    res.predictions.forEach((Prediction p) {
      placeList.add(p.description);
    });
    _places.dispose();
    return placeList;
  }
}

Future<LatLng> getPlaceAddress(String placename) async {
  GeocodingResponse place = await geocoding.searchByAddress(placename);
  return LatLng(place.results[0].geometry.location.lat, place.results[0].geometry.location.lng);
}