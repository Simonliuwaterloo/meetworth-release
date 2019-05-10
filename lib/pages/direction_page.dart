import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../util/user_location.dart';
import '../model/page.dart';
import '../util/network_util.dart';
import '../model/place.dart';
import '../model/instruction_list.dart';
import 'dart:async';
import 'dart:convert';

void pushDirectionPage(BuildContext context, Place destination) async {
  UserLocation userLoc = new UserLocation();
  LatLng latlng = destination.latlng;
  LatLng myLocation = await userLoc.getLatLng();

//get direction data
  NetworkUtil networkUtil = NetworkUtil();
  final DIRECTIONJSON = await networkUtil.getDirectionByLatLng(myLocation, latlng);
  final STEPS = json.decode(DIRECTIONJSON)['routes'][0]['legs'][0]['steps'];

//create waypoints
  List<LatLng> wayPoints = [];
  wayPoints.add(myLocation);
  STEPS.forEach((step) => wayPoints.add(LatLng(step['end_location']['lat'], step['end_location']['lng'])));

//create instruction list 
  List<String> instructions = [];
  STEPS.forEach((step) => instructions.add(step['html_instructions']));
  print(instructions);
  InstructionList listMaker = new InstructionList(instructions);
  Widget insList = listMaker.createList();

//create polyline
  final Polyline polyline = Polyline(
      polylineId: PolylineId("route"),
      color: Colors.blue[300],
      width: 10,
      points: wayPoints,
  );

  MaterialPageRoute directionPage = new MaterialPageRoute<void>(
    builder: (BuildContext context) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      return new Scaffold(
        body: DirectionPage(destination.name, myLocation, latlng, polyline, insList),
      );
    },
  );
  Navigator.of(context).push(directionPage);
}

class DirectionPage extends Page {
  final String destination;
  final LatLng myLatLng;
  final LatLng latLng;
  final Polyline polyline;
  final Widget insList;
  const DirectionPage( this.destination,  this.myLatLng,  this.latLng,  this.polyline,  this.insList);
  @override
  Widget build(BuildContext context) {
      return DirectionPageStateful(this.destination, this.myLatLng, this.latLng, this.polyline, this.insList);
  }
}

class DirectionPageStateful extends StatefulWidget {
  final String destination;
  final LatLng myLatLng;
  final LatLng latLng;
  final Polyline polyline;
  final Widget insList;
  const DirectionPageStateful( this.destination,   this.myLatLng,  this.latLng,  this.polyline,  this.insList);

  @override
  State createState() => DirectionPageState(this.destination, this.myLatLng, this.latLng, this.polyline, this.insList);
}

class DirectionPageState extends State<DirectionPageStateful> {
  UserLocation location = new UserLocation();

  Completer<GoogleMapController> mapController = Completer();
  final String destination;
  final LatLng myLatLng;
  final LatLng latLng;
  final Polyline polyline;
  final Widget insList;
  void _onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  } 

  DirectionPageState( this.destination,   this.myLatLng,  this.latLng,  this.polyline,  this.insList);
  
  @override
  Widget build(BuildContext context) {
    List markers = [
        Marker(
          markerId: MarkerId(this.destination),
          position: this.latLng
        )
    ];

  
    return Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: LatLng(this.myLatLng.latitude, this.myLatLng.longitude),
              zoom:15,
            ),
            markers: Set<Marker>.from(markers),
            onMapCreated: _onMapCreated,
            myLocationEnabled : true,
            polylines: Set<Polyline>.of([polyline]),
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
          new Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.6),
              child: insList,
            )
      ]
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

  Widget _searchBar(BuildContext context, place2) {
  //TODO:delete search bar, add title
  return SizedBox(
      width: MediaQuery.of(context).size.width*0.9,
      height: MediaQuery.of(context).size.height*0.2,
      child: new Container(
        decoration: new BoxDecoration(
            color: Colors.white,
            boxShadow: [new BoxShadow(
            color: Colors.black,
            blurRadius: 5.0,
            ),]
          ),
        child: new Row(
          children: <Widget>[
            new Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05)),
            new Column(
              children: <Widget>[
                new Container(
                  padding: EdgeInsets.only(top: 20),
                  child: new Icon(Icons.person_pin_circle),
                ),
                new Container(
                  padding: EdgeInsets.only(top: 20),
                  child: new Icon(Icons.arrow_downward),
                ),
                new Container(
                  padding: EdgeInsets.only(top: 20),
                  child: new Icon(Icons.person_pin_circle),
                ),
              ],
            ),
            new Column (
              children: [
                Container(
//                  color: Colors.blue,
                  padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                  height:  MediaQuery.of(context).size.height*0.1,
                  width: MediaQuery.of(context).size.width*0.75,
                  child: new TextFormField(
                    initialValue: 'Your Location',
                    decoration: const InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 0, 0),
                  height:  MediaQuery.of(context).size.height*0.1,
                  width: MediaQuery.of(context).size.width*0.75,
                  child: new TextFormField(
                    initialValue: place2,
                    decoration: const InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                    ),
                  ),
                ),
              ]
            )
          ],
        ),
      )
    );
  }
}
