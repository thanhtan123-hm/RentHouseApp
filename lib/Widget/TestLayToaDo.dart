import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

class GetLocationPage extends StatefulWidget {
  @override
  _GetLocationPageState createState() => _GetLocationPageState();
}

class _GetLocationPageState extends State<GetLocationPage> {
  TextEditingController _addressController = TextEditingController();
  String _latitude = '';
  String _longitude = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Get Location'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'Enter Address',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _getLocationFromAddress();
              },
              child: Text('Get Location'),
            ),
            SizedBox(height: 20),
            Text('Latitude: $_latitude'),
            Text('Longitude: $_longitude'),
          ],
        ),
      ),
    );
  }

  Future<void> _getLocationFromAddress() async {
    try {
      List<Location> locations = await locationFromAddress(_addressController.text);
      if (locations.isNotEmpty) {
        print(locations[0].latitude.toString());
        print(locations[0].longitude.toString());
        setState(() {
          _latitude = locations[0].latitude.toString();
          _longitude = locations[0].longitude.toString();
        });
      } else {
        setState(() {
          _latitude = 'Not found';
          _longitude = 'Not found';
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
