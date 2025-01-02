import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/place.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _hasPermissions = false;
  final List<double> _headingBuffer = [];
  final int _bufferSize = 5;
  Position? _userPosition;
  double? _distanceToDestination;
   // Slott Oerebro 59.270998916 15.20916583
  final double _destinationLatitude = 59.270998916; 
  final double _destinationLongitude = 15.20916583;
 

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
    _getUserLocation();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('SightVenture Compass'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: _hasPermissions
            ? Column(
                children: <Widget>[
                  Expanded(child: _buildCompass()),
                  _buildDistanceInfo(),
                ],
              )
            : _buildPermissionSheet(),
      ),
    );
  }

  Widget _buildCompass() {
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error reading heading: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? heading = snapshot.data?.heading;

        // Handle devices without sensors
        if (heading == null) {
          return const Center(
            child: Text("Device does not have compass sensors."),
          );
        }

        // Smooth heading using a moving average
        _headingBuffer.add(heading);
        if (_headingBuffer.length > _bufferSize) {
          _headingBuffer.removeAt(0);
        }
        final smoothedHeading = _headingBuffer.reduce((a, b) => a + b) / _headingBuffer.length;

        // Calculate rotation angle to destination without directly using setState()
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateDistanceAndAngle(smoothedHeading);
        });

        final angleToDestination = _calculateAngleToDestination(smoothedHeading);

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              elevation: 4.0,
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: Transform.rotate(
                    angle: (angleToDestination ?? 0) * (math.pi / 180) * -1,
                    child: Image.asset(
                      'assets/arrow.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              angleToDestination != null
                  ? 'Direction to Destination: ${angleToDestination.toStringAsFixed(1)}°'
                  : 'Calculating...',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDistanceInfo() {
    if (_distanceToDestination == null) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Calculating distance...'),
      );
    }

    final distanceInKm = (_distanceToDestination! / 1000).toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text('Distance to Destination: $distanceInKm km'),
        ],
      ),
    );
  }

  void _checkProximityToDestination() {
    if (_distanceToDestination != null && _distanceToDestination! <= 100) {
      // Avoid showing the dialog repeatedly
      if (ModalRoute.of(context)?.isCurrent == true) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('You\'ve arrived!'),
              content: const Text('You are within 100 meters of your destination.'),
              actions: [
                ElevatedButton(
                  child: const Text('Okay'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    }
  }

  double? _calculateAngleToDestination(double currentHeading) {
    if (_userPosition == null) return null;

    // Destination and user coordinates
    final userLat = _userPosition!.latitude * (math.pi / 180);
    final userLon = _userPosition!.longitude * (math.pi / 180);
    final destLat = _destinationLatitude * (math.pi / 180);
    final destLon = _destinationLongitude * (math.pi / 180);

    // Calculate bearing to destination
    final deltaLon = destLon - userLon;
    final y = math.sin(deltaLon) * math.cos(destLat);
    final x = math.cos(userLat) * math.sin(destLat) -
        math.sin(userLat) * math.cos(destLat) * math.cos(deltaLon);
    final bearing = (math.atan2(y, x) * (180 / math.pi) + 360) % 360;

    return (bearing - currentHeading + 360) % 360;
  }

  void _updateDistanceAndAngle(double currentHeading) {
    if (_userPosition == null) return;

    // Calculate distance
    final distance = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      _destinationLatitude,
      _destinationLongitude,
    );

    // Update state only if the distance has changed significantly
    if (_distanceToDestination == null || (distance - _distanceToDestination!).abs() > 5) {
      setState(() {
        _distanceToDestination = distance;
      });

      // Check proximity to the destination
      _checkProximityToDestination();
    }
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text('Location Permission Required'),
          ElevatedButton(
            child: const Text('Request Permissions'),
            onPressed: () {
              Permission.locationWhenInUse.request().then((ignored) {
                _fetchPermissionStatus();
              });
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Open App Settings'),
            onPressed: () {
              openAppSettings().then((opened) {});
            },
          ),
        ],
      ),
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }

  void _getUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userPosition = position;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }
}
