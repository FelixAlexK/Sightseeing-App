import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sightseeing_app/pages/main_page.dart';
import 'package:sightseeing_app/pages/start_page.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  final TextEditingController _locationController = TextEditingController();
  double sliderValue = 100.0;
  bool checkbox1 = false;
  bool checkbox2 = false;
  bool checkbox3 = false;
  double lat = 0.0;
  double lng = 0.0;
  String? _currentAddress;
  bool _loadingAddress = false;

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed
    _locationController.dispose();
    super.dispose();
  }

  Timer? _debounce;

  void _onSliderChanged(double value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        sliderValue = value.roundToDouble();
      });
    });
  }

  String _formatAddress(Placemark place) {
    final locality = place.locality?.isNotEmpty == true
        ? place.locality
        : place.subLocality ?? 'Unknown locality';
    return '${place.street ?? 'Unknown street'}, $locality, ${place.country ?? 'Unknown country'}';
  }

  Future<void> _updateCurrentLocationAndAddress() async {
    try {
      if (_currentAddress != null && _currentAddress!.isNotEmpty) {
        _currentAddress = '';
        return;
      }
      _loadingAddress = true;

      // Step 1: Request location permission
      if (!await _requestLocationPermission()) return;

      // Step 2: Fetch current location
      final Position? position = await _fetchCurrentPosition();
      if (position == null) return;

      // Step 3: Reverse geocode to get address
      await _fetchAddressFromCoordinates(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Error updating location or address: $e");
      setState(() {
        _currentAddress = "Error retrieving location.";
      });
    } finally {
      _loadingAddress = false;
    }
  }

  // Request location permission
  Future<bool> _requestLocationPermission() async {
    PermissionStatus permissionStatus = await Permission.location.request();
    if (permissionStatus != PermissionStatus.granted) {
      setState(() {
        _currentAddress = "Location permission denied.";
      });
      _loadingAddress = false;
      return false;
    }
    return true;
  }

  // Fetch the current position
  Future<Position?> _fetchCurrentPosition() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings:
            LocationSettings(accuracy: LocationAccuracy.bestForNavigation),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('Fetching location timed out.');
      });
      setState(() {
        lat = position.latitude;
        lng = position.longitude;
      });
      return position;
    } catch (e) {
      debugPrint('Error fetching location: $e');
      setState(() {
        _currentAddress = "Error: Location retrieval failed.";
      });
      return null;
    }
  }

  // Reverse geocode to fetch address
  Future<void> _fetchAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      ).timeout(const Duration(seconds: 5), onTimeout: () {
        throw TimeoutException('Reverse geocoding timed out.');
      });

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              _formatAddress(place); // Format the address for display
        });
      } else {
        setState(() {
          _currentAddress = "Address not found.";
        });
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
      setState(() {
        _currentAddress = "Error: Address retrieval failed.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Text(
                  'Navigation Options',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    // Bind controller
                    controller: _locationController,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Enter Location',
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue)),
                    ),
                  ),
                ),
                SizedBox(
                  width: 24,
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor:
                        _loadingAddress ? Colors.grey : Colors.blue,
                    elevation: 8,
                    padding: EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey,
                  ),
                  onPressed: _loadingAddress
                      ? null // Disable the button while loading
                      : () async {
                          FocusScope.of(context).unfocus();
                          setState(() {
                            _loadingAddress = true;
                          });
                          await _updateCurrentLocationAndAddress();
                          setState(() {
                            _locationController.text =
                                _currentAddress ?? 'Unable to fetch address';
                          });
                        },
                  icon: _loadingAddress
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : _currentAddress?.isNotEmpty == true
                          ? Icon(
                              Icons.my_location_outlined,
                              color: Colors.white,
                            )
                          : Icon(
                              Icons.location_searching,
                              color: Colors.white,
                            ),
                ),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Distance: ${sliderValue.round()} km'),
                  ],
                ),
                Slider(
                  value: sliderValue,
                  label: '${sliderValue.round().toString()} km',
                  min: 0,
                  max: 1000,
                  divisions: 200,
                  thumbColor: Colors.blue,
                  activeColor: Colors.lightBlue,
                  onChangeEnd: _onSliderChanged,
                  onChanged: (value) {
                    setState(() {
                    sliderValue = value;
                    });
                  })
              ],
            ),
            Column(
              children: [
                CheckboxListTile(
                  title: const Text('Option 1'),
                  value: checkbox1,
                  onChanged: (value) {
                    setState(() {
                      checkbox1 = value!;
                    });
                  },
                  checkColor: Colors.white,
                  activeColor: Colors.blue,
                ),
                CheckboxListTile(
                  title: const Text('Option 2'),
                  value: checkbox2,
                  onChanged: (value) {
                    setState(() {
                      checkbox2 = value!;
                    });
                  },
                  checkColor: Colors.white,
                  activeColor: Colors.blue,
                ),
                CheckboxListTile(
                  title: const Text('Option 3'),
                  value: checkbox3,
                  onChanged: (value) {
                    setState(() {
                      checkbox3 = value!;
                    });
                  },
                  checkColor: Colors.white,
                  activeColor: Colors.blue,
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (context) => StartPage())),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: BorderSide(
                          color: Colors.blue,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignInside),
                      elevation: 8,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Text(
                      'back',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),
                ElevatedButton(
                    onPressed: () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MainPage(useStoredPlace: false)))
                        },
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.blue,
                      elevation: 8,
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Text(
                      'Start',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
