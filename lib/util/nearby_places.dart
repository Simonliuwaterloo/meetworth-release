import 'package:http/http.dart' as http;
import 'dart:convert';

import '../model/place_card.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyPlaces{
  LatLng _myplace;
  final _BASE_URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
  final _PHOTO_URL = "https://maps.googleapis.com/maps/api/place/photo?";
  final _API_KEY = ""YOUR_KEY"";
  NearbyPlaces(LatLng myplace) {
    this._myplace = myplace;
  }

  getNearbyPlaces({double radius, 
    List minMaxPrice,
    String name,
    bool openNow,
    String rankby,
    String type}
  ) async {
    if (rankby == "distance") radius = null;
    if (rankby == null && radius == null) radius = 1500;
    String url = "location=${this._myplace.latitude},${this._myplace.longitude}"
    + ((radius != null) ? "&radius=${radius.toString()}":"")
    + ((minMaxPrice != null) ? "&minprice=${minMaxPrice[0]}&maxprice=${minMaxPrice[1]}": "")
    + ((name != null) ? "&name=$name":"")
    + ((openNow != null) ? "&opennow":"")
    + ((rankby != null) ? "&rankby=$rankby":"")
    + ((type != null) ? "&type=$type":"")
    + "&key=${this._API_KEY}";
    var result = await http.get(this._BASE_URL + url);
    var jsonResult = json.decode(result.body)['results'];
    jsonResult = jsonResult.where((place) => !place['types'].contains('locality') && !place['types'].contains('neighborhood'));
    return  jsonResult;
  }
  getPhoto(String reference, {height: 180})  {
    if (reference == null) return null;
    String url = "maxheight=$height"
    + "&photoreference=$reference"
    + "&key=${this._API_KEY}";
    // var res = await http.get(this._PHOTO_URL + url);
    // return res.body;
    return (this._PHOTO_URL + url);
  }
  getAllPlaces() async{
    var result = await this.getNearbyPlaces(radius: 500, minMaxPrice: null, name: null, openNow: null, rankby: null, type: null);
    List placesList = [];
    result.forEach((place) async{
      LatLng latlng = LatLng(place['geometry']['location']['lat'], place['geometry']['location']['lng']);
      String id = place['id'];
      String name = place['name'];
      bool openNow = (place['opening_hurs'] != null && place['opening_hurs']['open_now'] == 'true') ? true:false;
      String photo = place['photos'] != null ? place['photos'][0]['photo_reference']:null;
      String placeId = place['place_id'];
      double rating = place['rating'] != null ? place['rating'].toDouble():null;
      List types = place['types'];
      String vicinity = place['vicinity'];
      int ratingTotal = place['user_ratings_total'];
      String photoURL = this.getPhoto(photo);
      PlaceCard thisPlace = new PlaceCard(latlng, id, name, openNow, photo, placeId, rating, types, vicinity, ratingTotal, photoURL);
      placesList.add(thisPlace);
    });
    return placesList;
  }
}