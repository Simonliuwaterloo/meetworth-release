import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../util/place_search.dart';
import '../util/user_location.dart';
import '../util/meetup_locations.dart';
import '../util/nearby_places.dart';
import '../model/page.dart';
import '../model/place_card.dart';
import './direction_page.dart';
import 'dart:async';

void pushMeetUpPage(BuildContext context, String text) async {
  UserLocation userLoc = new UserLocation();
  LatLng latlng = await getPlaceAddress(text);

  LatLng myLocation = await userLoc.getLatLng();

  var meetUpLocations = new MeetUpLocations(myLocation, latlng);
  LatLng meetUpPlace = await meetUpLocations.getMiddlePlaces();

  var nearbyPlaces = new NearbyPlaces(meetUpPlace);
  List allMeetPlaces = await nearbyPlaces.getAllPlaces();


  MaterialPageRoute meetUpPage = new MaterialPageRoute<void>(
    builder: (BuildContext context) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      return new Scaffold(
        body: MeetUpPage(text, latlng, allMeetPlaces),
      );
    },
  );
  Navigator.of(context).push(meetUpPage);
}

class MeetUpPage extends Page {
  final String destination;
  final LatLng latLng;
  final List allMeetPlaces;
  const MeetUpPage( this.destination,  this.latLng,  this.allMeetPlaces);
  @override
  Widget build(BuildContext context) {
      return MeetUpPageStateful(this.destination, this.latLng, this.allMeetPlaces);
  }
}

class MeetUpPageStateful extends StatefulWidget {
  final String destination;
  final LatLng latLng;
  final List allMeetPlaces;
  const MeetUpPageStateful( this.destination,  this.latLng,  this.allMeetPlaces);

  @override
  State createState() => MeetUpPageState(this.destination, this.latLng, this.allMeetPlaces);
}

class MeetUpPageState extends State<MeetUpPageStateful> {
  UserLocation location = new UserLocation();

  Completer<GoogleMapController> mapController = Completer();
  final String destination;
  final LatLng latLng;
  final List allMeetPlaces;
  Map<MarkerId, Marker> markers = {};
  MarkerId focusedMarker;
  PanelController _pc = new PanelController();

  void _onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
  } 

  MeetUpPageState( this.destination,  this.latLng,  this.allMeetPlaces );

  void _changeMarkerColor(MarkerId markerId) {
    print(markerId.toString());
    Marker newMarker = this.markers[markerId].copyWith(
      iconParam: BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      ),
    );
    if (focusedMarker != null) {
      this.markers[focusedMarker] = this.markers[focusedMarker].copyWith(
        iconParam: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueAzure
        ),
      );
    }
    this.setState(() {
      print("change marker color");
      this.markers[markerId] = newMarker;
      this.focusedMarker = markerId;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) {
      markers[MarkerId("destination")] = (
        Marker(
          markerId: MarkerId("destination"),
          position: latLng,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta
          )
        )
      );
      for (int x = 0; x < allMeetPlaces.length; ++x) {
        print(allMeetPlaces[x].id);
        markers[MarkerId(allMeetPlaces[x].id)] = (
            Marker(
              markerId: MarkerId(allMeetPlaces[x].id),
              position: allMeetPlaces[x].latLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure
              )
            )
        );
      }
    }

    return Stack(
        children: <Widget>[
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: allMeetPlaces[0].latLng,
              zoom:15,
            ),
            markers: Set<Marker>.from(markers.values),
            onMapCreated: _onMapCreated,
            myLocationEnabled: true,
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
          new SlidingUpPanel(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            controller: _pc,
            backdropEnabled: true,
            maxHeight:MediaQuery.of(context).size.height*0.9,
            minHeight:MediaQuery.of(context).size.height*0.08,
            color: Colors.blue,
            collapsed: Container(
              child: Icon(Icons.arrow_upward),
            ),
            panel: Container(
                margin: const EdgeInsets.only(top: 100),
                child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemBuilder: (context, position) {
                  return new Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
                    child: this._cardBuilder(mapController, context, allMeetPlaces[position]),
                  );
                },
                itemCount: allMeetPlaces.length,
              )
            )
          )
      ]
    );
  }

  Widget _cardBuilder(Completer<GoogleMapController> controller, BuildContext context, PlaceCard placeCard ) {
    print('creating card');
    Icon placeIcon;
    switch (placeCard.types[0].toString().replaceAll("_", " ")) {
      case 'store':
        placeIcon = Icon(Icons.store);
        break;
      case 'department store':
        placeIcon = Icon(Icons.store);
        break;
      case 'clothing store':
        placeIcon = Icon(Icons.loyalty);
        break;
      case 'gym':
        placeIcon = Icon(Icons.fitness_center);
        break;
      case 'restaurant':
        placeIcon = Icon(Icons.restaurant);
        break;
      case 'cafe':
        placeIcon = Icon(Icons.local_cafe);
        break;
      case 'bar':
        placeIcon = Icon(Icons.local_bar);
        break;
      case 'car dealer':
        placeIcon = Icon(Icons.directions_car);
        break;
      default:
        placeIcon = Icon(Icons.location_on);
    }
    var imageView = placeCard.photoURL is String ? Image.network(placeCard.photoURL) : new Text('no image');
    return Card(
      color: Colors.white.withOpacity(1),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: placeIcon,
            title: Text(placeCard.name),
            subtitle: Text(placeCard.types[0].toString().replaceAll("_", " ") + "  " + placeCard.rating.toString() + "★"),
          ),
          imageView,
          ButtonTheme.bar( // make buttons use the appropriate styles for cards
            child: ButtonBar(
              children: <Widget>[
                FlatButton(
                  child: const Text('LOCATE ON MAP'),
                  onPressed: () async{
                    _pc.close();
                    print(placeCard.id);
                    _changeMarkerColor(MarkerId(placeCard.id));
                    print(this.markers[MarkerId(placeCard.id)].icon);
                    var mapController = await controller.future;
                    mapController.animateCamera(
                        CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: placeCard.latLng,
                              zoom: 15,
                            )
                        )
                    );
                  },
                ),
                FlatButton(
                  child: const Text('DIRECTION'),
                  onPressed: () { pushDirectionPage(context, placeCard.thisPlace); },
                ),
              ],
            ),
          ),
        ],
      ),
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
