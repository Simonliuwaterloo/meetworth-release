import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NetworkUtil {
  static final BASE_URL =
      "https://maps.googleapis.com/maps/api/directions/json?";

  static NetworkUtil _instance = new NetworkUtil.internal();

  NetworkUtil.internal();

  factory NetworkUtil() => _instance;

  Future<dynamic> get(String url) {
    print(BASE_URL + url);
    return http.get(BASE_URL + url).then((http.Response response) {
      String res = response.body;
      int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400 || json == null) {
        res = "{\"status\":" +
            statusCode.toString() +
            ",\"message\":\"error\",\"response\":" +
            res +
            "}";
        throw new Exception(res);
      }

      return res;
    });
  }

  Future<dynamic> getDirectionByLatLng(LatLng startLatLng, LatLng endLatlng) {
    return this.get("origin=" + 
              startLatLng.latitude.toString() +
              "," +
              startLatLng.longitude.toString() +
              "&destination=" +
              endLatlng.latitude.toString() +
              "," +
              endLatlng.longitude.toString() +
              "&key="YOUR_KEY""); 
  }

}