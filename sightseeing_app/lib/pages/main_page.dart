import 'dart:async';
import 'dart:math' as math;
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/place.dart';

/// Parses a coordinate string in the format "48.8584° N, 2.2945° E".
/// Returns a map with latitude and longitude as doubles.
Map<String, double> parseCoordinates(String cord) {
  final parts = cord.split(','); // Split into ["48.8584° N", " 2.2945° E"]
  
  // Extract latitude
  final latPart = parts[0].trim();
  final latValue = double.parse(latPart.split('°')[0]);
  final latDirection = latPart.split(' ')[1];
  final latitude = latDirection == 'S' ? -latValue : latValue;

  // Extract longitude
  final lonPart = parts[1].trim();
  final lonValue = double.parse(lonPart.split('°')[0]);
  final lonDirection = lonPart.split(' ')[1];
  final longitude = lonDirection == 'W' ? -lonValue : lonValue;

  return {
    'latitude': latitude,
    'longitude': longitude,
  };
}

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
  Place? _selectedPlace;

  // Maximum distance in meters to consider a place as nearby
  final int maxDistance = 1500000; //TODO: from options

  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
    _startLocationUpdates(); // Start continuous location updates
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel(); // Cancel stream subscription to avoid memory leaks
    super.dispose();
  }

  void _startLocationUpdates() {
    _positionStreamSubscription = Geolocator.getPositionStream().listen((position) {
      if (mounted) {
        setState(() {
          _userPosition = position; // Continuously update _userPosition
        });
        _selectRandomPlace(); // Update selected place when location changes
      }
    });
  }

  void _selectRandomPlace() {
    if (_userPosition == null) {
      print('User position is not available.');
      return;
    }

    // Filter places within maxDistance of the user's current location
    final nearbyPlaces = places.where((place) {
      final cords = parseCoordinates(place.cord);
      final placeLat = cords['latitude']!;
      final placeLon = cords['longitude']!;
      final distance = Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        placeLat,
        placeLon,
      );
      return distance <= maxDistance;
    }).toList();

    if (nearbyPlaces.isEmpty) {
      print('No nearby places found within ${maxDistance / 1000} km.');
      setState(() {
        _selectedPlace = null; // No valid place available
      });
      return;
    }

    // Select a random place from the filtered list
    final random = Random();
    setState(() {
      _selectedPlace = nearbyPlaces[random.nextInt(nearbyPlaces.length)];
    });

    print('Selected place: ${_selectedPlace?.name}');
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
    if (_selectedPlace == null) {
      return Center(
        child: Text('No nearby places found within ${maxDistance / 1000} km.'),
      );
    }

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
            child: Text('Device does not have compass sensors.')
          );
        }

        _headingBuffer.add(heading);
        if (_headingBuffer.length > _bufferSize) {
          _headingBuffer.removeAt(0);
        }
        final smoothedHeading = _headingBuffer.reduce((a, b) => a + b) / _headingBuffer.length;

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
    if (_userPosition == null || _selectedPlace == null) return null;

    final cords = parseCoordinates(_selectedPlace!.cord);
    final destLat = cords['latitude']!;
    final destLon = cords['longitude']!;

    // Destination and user coordinates
    final userLat = _userPosition!.latitude * (math.pi / 180);
    final userLon = _userPosition!.longitude * (math.pi / 180);
    final destinationLat = destLat * (math.pi / 180);
    final destinationLon = destLon * (math.pi / 180);

    final deltaLon = destinationLon - userLon;
    final y = math.sin(deltaLon) * math.cos(destinationLat);
    final x = math.cos(userLat) * math.sin(destinationLat) -
        math.sin(userLat) * math.cos(destinationLat) * math.cos(deltaLon);
    final bearing = (math.atan2(y, x) * (180 / math.pi) + 360) % 360;

    return (bearing - currentHeading + 360) % 360;
  }

  void _updateDistanceAndAngle(double currentHeading) {
    if (_userPosition == null || _selectedPlace == null) return;

    final cords = parseCoordinates(_selectedPlace!.cord);
    final destLat = cords['latitude']!;
    final destLon = cords['longitude']!;

    // Calculate distance
    final distance = Geolocator.distanceBetween(
      _userPosition!.latitude,
      _userPosition!.longitude,
      destLat,
      destLon,
    );

    // Update state only if the distance has changed significantly
    if (_distanceToDestination == null || (distance - _distanceToDestination!).abs() > 5) {
      setState(() {
        _distanceToDestination = distance;
      });

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
}
