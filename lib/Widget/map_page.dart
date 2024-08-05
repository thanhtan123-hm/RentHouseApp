import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:post_house_rent_app/MongoDb_Connect.dart';
import 'package:post_house_rent_app/Widget/DetailPage.dart';
import 'package:post_house_rent_app/Widget/HomeScreen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  Set<Marker> _markers = {}; // Set để lưu trữ các marker

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(10.732639899999999, 106.69976390000001),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  Future<void> _initializeMarkers() async {
    List<Map<String, dynamic>> markerData = await MongoDatabase.all_post();
    Set<Marker> markers = {};

    // Load custom icon
    BitmapDescriptor customIcon = await _loadCustomMarkerIcon();

    for (var marker in markerData) {
      markers.add(
        Marker(
          markerId: MarkerId(marker['_id'].toString()),
          icon: customIcon,
          position: await _getLocationFromAddress(marker['address']),
          onTap: () {
            _showInfoWindow(
                marker['price'].toString() + ' VND',
                marker['area'].toString() + ' m2',
                marker['imageUrls'][0],
                marker);
          },
        ),
      );
    }
    setState(() {
      _markers = markers;
    });
  }

  Future<BitmapDescriptor> _loadCustomMarkerIcon() async {
    final url =
        'https://firebasestorage.googleapis.com/v0/b/post-room-house-rent.appspot.com/o/assets%2Fhouse.png?alt=media&token=7edfdb01-6e9e-47d7-b23e-d73a6ca4cbb6';
    final http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Uint8List markerIcon = response.bodyBytes;

      // Resize the image
      img.Image originalImage = img.decodeImage(markerIcon)!;
      img.Image resizedImage =
          img.copyResize(originalImage, width: 150, height: 150);

      // Convert the resized image back to bytes
      final Uint8List resizedMarkerIcon =
          Uint8List.fromList(img.encodePng(resizedImage));

      return BitmapDescriptor.fromBytes(resizedMarkerIcon);
    } else {
      throw Exception('Failed to load marker icon');
    }
  }

  Future<LatLng> _getLocationFromAddress(String address) async {
    try {
      List<String> addressParts = address.split(',');
      if (addressParts.length <= 2) {
        // Chỉ lấy nội dung sau dấu phẩy đầu tiên
        address = addressParts.last.trim();
      }
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(locations[0].latitude, locations[0].longitude);
      } else {
        return LatLng(0, 0);
      }
    } catch (e) {
      print(e.toString());
      return LatLng(0, 0);
    }
  }

  Future<void> _addCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition();
    LatLng currentLatLng = LatLng(position.latitude, position.longitude);

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("currentLocation"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          position: currentLatLng,
        ),
      );
    });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 15));
  }

  void _showInfoWindow(
      String price, String area, String imageUrl, Map<String, dynamic> marker) {
    showModalBottomSheet(
      backgroundColor: Colors.black,
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      imageUrl,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Giá: $price",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  Text(
                    "Diện tích: $area",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailPage(post: marker)),
                      );
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.white,
                    ),
                    label: Text(
                      "Xem chi tiết",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bài đăng xung quanh',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[800],
      ),
      body: Stack(children: [
        GoogleMap(
          mapType: MapType.terrain,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          markers: _markers,
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: FloatingActionButton(
            onPressed: _addCurrentLocation,
            child: const Icon(Icons.location_searching),
            tooltip: 'Get Current Location',
          ),
        ),
      ]),
    );
  }
}
