import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:async';

import '../model/page.dart';
import '../util/user_location.dart';
import '../util/place_search.dart';
import 'search_page.dart';

class MainPage extends Page {

  @override
  Widget build(BuildContext context) {
    return const MainPageStateful();
  }
}

class MainPageStateful extends StatefulWidget {
  const MainPageStateful();
  @override
  State createState() => MainPageState();
}

class MainPageState extends State<MainPageStateful> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  Completer<GoogleMapController> mapController = Completer();
  List<String> suggesList= [];

  void _onMapCreated(GoogleMapController controller) {
    mapController.complete(controller);
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

  Widget _searchBar(BuildContext context) {
    return SizedBox(
        width: MediaQuery.of(context).size.width*0.9,
        height: MediaQuery.of(context).size.height*0.08,
        child: new Container(
          color: Colors.white,
          child: new Row(
            children: <Widget>[
              new IconButton(
                icon: Icon(Icons.view_headline),
                onPressed: () => _scaffoldKey.currentState.openDrawer(),
              ),
              new Container(
                width: MediaQuery.of(context).size.width*0.75,
                child: new TextField(
                  decoration: const InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                  ),
                  onChanged: (text) async {
                    try {
                      List places =  await getPlacesByAutoComplete(text);
                      setState(() {
                        suggesList = places;
                      });
                    } catch (e) {
                      print(e.toString());
                    }
                  },
                  onSubmitted: (text) {
                    pushSearchPage(context, text);
                  },
                ),
              ),
            ],
          ),
        )
    );
  }
  _getSuggestList() {
    if (suggesList == null || suggesList.length == 0) {
      return new Container();
    }
    else {
      return new Padding(
        padding: EdgeInsets.only(top: 100),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.05),
        child: new SizedBox(
            width: MediaQuery.of(context).size.width*0.9,
            height: suggesList.length*40 + 30.1,
            child: new Container(
              decoration: new BoxDecoration(
                color: Colors.white,
                border: new Border.all(color: Colors.blueAccent)
              ),
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 0),
                itemCount: suggesList != null? suggesList.length:0,
                  separatorBuilder: (BuildContext context, int index) => new Container(
                    padding: EdgeInsets.all(0),
                    child: Divider(
                      height: 1,
                    ),
                  ),
                  itemBuilder: (BuildContext context, int index) {
                  return Container (
                    padding: EdgeInsets.all(0),
                    child: ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(
                      suggesList[index].split(", ")[0],
                      style: TextStyle(fontSize: 14.0),
                      ),
                      subtitle: Text(
                        suggesList[index].substring(suggesList[index].indexOf(", ") + 1),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      onTap: () => pushSearchPage(context, suggesList[index]),
                  )
                  );
                }
            ),
          )
        )
        )
      );
    }
  }

  Future<void> locateUser() async{
    UserLocation location = new UserLocation();
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(await location.getLat(), await location.getLng()),
              zoom: 15.0,
            )
        )
    );
  }

  List mylocation;

  Future<void> getMyLocation() async{
    UserLocation location = new UserLocation();
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(await location.getLat(), await location.getLng()),
              zoom: 15.0,
            )
        )
    );
  }


  @override
  Widget build(BuildContext context) {
    getMyLocation();
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: GoogleMap(
              myLocationEnabled : true,
              onMapCreated: _onMapCreated,
              initialCameraPosition:
                CameraPosition(target: LatLng(0.0, 0.0)),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _topBar(context),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height*0.05,
            left: MediaQuery.of(context).size.width*0.05,
            right: MediaQuery.of(context).size.width*0.05,
            child: _searchBar(context),
          ),
          Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: EdgeInsets.all(30),
                child: new RawMaterialButton(
                  animationDuration: Duration(seconds: 1),
                  splashColor: Colors.black,
                  constraints: BoxConstraints(),
                  child: Icon(Icons.my_location),
                  shape: new CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  fillColor: Colors.white,
                  onPressed: () async => await locateUser()
                ),
              ),
              // new Padding(
              //   padding: EdgeInsets.all(5),
              //   child: new RawMaterialButton(
              //     constraints: BoxConstraints(),
              //     child: Icon(Icons.people),
              //     shape: new CircleBorder(),
              //     padding: const EdgeInsets.all(20),
              //     fillColor: Colors.white,
              //     onPressed: null
              //   ),
              // ),
              new Padding(padding: EdgeInsets.all(20))
            ],
          ),
          _getSuggestList()
        ],
      ),
      drawer: Drawer(
          child: ListView(
              children:<Widget>[
                DrawerHeader(
                  child: Text("This app is still being developed \n"),
                ),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  title: Text("This app is still being developed \n"
                      "In next release, several new functionalities will be added, including:\n"
                      "filter of places\n"
                      "tap on home page to quit autocomplete\n"
                      "icon made by Freepik from www.flaticon.com  "),
                )
              ]
          )
      ),
    );
  }
}