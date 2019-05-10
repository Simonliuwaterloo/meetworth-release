import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../util/place_search.dart';
import '../model/page.dart';
import 'meetup_page.dart';

void pushSearchPage(BuildContext context, String text) async {
  LatLng latlng = await getPlaceAddress(text);
  MaterialPageRoute searchPage = new MaterialPageRoute<void>(
    builder: (BuildContext context) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      return new Scaffold(
        body: SearchPage( text, latlng),
      );
    },
  );
  Navigator.of(context).push(searchPage);
}

class SearchPage extends Page {
  final String destination;
  final LatLng latLng;
  const SearchPage( this.destination,  this.latLng);
  @override
  Widget build(BuildContext context) {
      return SearchPageStateful(this.destination, this.latLng);
  }
}

class SearchPageStateful extends StatefulWidget {
  final String destination;
  final LatLng latLng;
  const SearchPageStateful( this.destination,  this.latLng);

  @override
  State createState() => SearchPageState(this.destination, this.latLng);
}

class SearchPageState extends State<SearchPageStateful> {
  Completer<GoogleMapController> mapController = Completer();
  final String destination;
  final LatLng latLng;

  void _onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  } 

  SearchPageState( this.destination,  this.latLng );
  
  @override
  Widget build(BuildContext context) {
    getDestination(this.latLng);

    return Stack(
        children: <Widget>[
          GoogleMap(
            myLocationEnabled : true,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: LatLng(0.0, 0.0)),
            markers: Set<Marker>.from([Marker(
              markerId: MarkerId("destination"),
              position: LatLng(this.latLng.latitude, this.latLng.longitude)
              )]),
          ),          
          new Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _topBar(context),
          ),
          new Positioned(
            top: MediaQuery.of(context).size.height*0.05,
            left: MediaQuery.of(context).size.width*0.05,
            right: MediaQuery.of(context).size.width*0.05,
            child: _searchBar(context, this.destination),
          ),
          new Positioned(
            top: MediaQuery.of(context).size.height*0.8,
            left: MediaQuery.of(context).size.width*0.05,
            right: MediaQuery.of(context).size.width*0.05,
            child: _optionCard(context, this.destination),
          ),
        ]
    );
  }
  Future<void> getDestination(LatLng latLng) async{
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(latLng.latitude, latLng.longitude),
              zoom: 15.0,
            )
        )
    );
  }

  Widget _topBar(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height*0.08,
        child: new Container(
          color: Colors.blue,
        )
    );
  }

  Widget _searchBar(BuildContext context, place) {
  //TODO:delete search bar, add title
    return SizedBox(
        width: MediaQuery.of(context).size.width*0.9,
        height: MediaQuery.of(context).size.height*0.08,
        child: new Container(
          color: Colors.white,
          child: new Row(
            children: <Widget>[
              new IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              new Container(
                width: MediaQuery.of(context).size.width*0.75,
                child: new TextFormField(
                  initialValue: place,
                  decoration: const InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _optionCard(BuildContext context, String place) {
    String placeName = place.split(", ")[0];
    String placeDetail = place.substring(place.indexOf(", ") + 1);
    return new Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.album),
            title: Text(placeName),
            subtitle: Text(placeDetail),
          ),
          ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text('Cancel'),
                  onPressed: () => Navigator.pop(context),
                ),
                FlatButton(
                  child: const Text('Meet Up!'),
                  onPressed: () { pushMeetUpPage(context, place); },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
