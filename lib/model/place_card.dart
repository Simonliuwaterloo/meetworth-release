import 'package:google_maps_flutter/google_maps_flutter.dart';
import './place.dart';

class PlaceCard{
  LatLng latLng;
  String id;
  String name;
  bool openNow;
  String photo;
  String placeId;
  double rating;
  List types;
  String vicinity;
  int ratingTotal;
  String photoURL;
  Place thisPlace;

  PlaceCard(
    LatLng latLng,
    String id,
    String name,
    bool openNow,
    String photo,
    String placeId,
    double rating,
    List types,
    String vicinity,
    int ratingTotal,
    String photoURL
  ) {
    this.latLng = latLng;
    this.id = id;
    this.name = name;
    this.openNow = openNow;
    this.photo = photo;
    this.placeId = placeId;
    this.rating = rating;
    this.types = types;
    this.vicinity = vicinity;
    this.ratingTotal = ratingTotal;
    this.photoURL = photoURL;
    Place place = new Place(this.name, this.latLng);
    this.thisPlace = place;
  }
}