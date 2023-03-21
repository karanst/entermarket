
import 'package:flutter/cupertino.dart';
import 'package:geocoder/geocoder.dart';
import 'package:location/location.dart';

class GetLocation{
  LocationData? _currentPosition;

  late String _address = "";
  Location location1 = Location();
  String firstLocation = "",lat = "",lng = "";
  ValueChanged onResult;

  GetLocation(this.onResult);
  Future<void> getLoc() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location1.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location1.requestService();
      if (!_serviceEnabled) {
        print('ek');
        return;
      }
    }

    _permissionGranted = await location1.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location1.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('no');
        return;
      }
    }
    print('getlocation');
    location1.getLocation().then((LocationData currentLocation) {
      print("${currentLocation.latitude} : ${currentLocation.longitude}");
      _currentPosition = currentLocation;
      print(currentLocation.latitude);

      _getAddress(_currentPosition!.latitude,
          _currentPosition!.longitude)
          .then((value) {
            if(value!=null){
              _address = "${value.first.coordinates.longitude}";
              firstLocation = value.first.subLocality.toString();
              lat = _currentPosition!.latitude.toString();
              lng = _currentPosition!.longitude.toString();
              onResult(value);
            }

      });
    });
  }

  Future<List<Address>?> _getAddress(double? lat, double? lang) async {
    final coordinates = new Coordinates(lat, lang);
    try{
      List<Address> add = await Geocoder.local.findAddressesFromCoordinates(coordinates);
      return add;
    }catch(e){
        print(e);
    }
   return null;
  }


}