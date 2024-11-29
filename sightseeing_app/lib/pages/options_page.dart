import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sightseeing_app/pages/main_page.dart';
import 'package:sightseeing_app/pages/start_page.dart';
import 'package:geocoding/geocoding.dart';

class OptionsPage extends StatefulWidget {
  const OptionsPage({super.key});

  @override
  _OptionsPageState createState() => _OptionsPageState();
}

class _OptionsPageState extends State<OptionsPage> {
  final TextEditingController _locationController = TextEditingController();
  double sliderValue = 0.0;
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

  Future<void> _updateCurrentLocationAndAddress() async {
    try {
      if (_currentAddress != null && _currentAddress!.isNotEmpty) {
        _currentAddress = '';
        return;
      }
      _loadingAddress = true;

      // Get the current position
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
      );

      // Update state for the position
      setState(() {
        lat = position.latitude;
        lng = position.longitude;
      });

      // Get the address from the coordinates
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];
        setState(() {
          _currentAddress =
              '${place.street}, ${place.locality?.isEmpty == true ? place.administrativeArea : place.locality}, ${place.country}';
        });
      } else {
        setState(() {
          _currentAddress = "Address not found";
        });
      }

      _loadingAddress = false;
    } catch (e) {
      debugPrint("Error fetching location or address: $e");
      setState(() {
        _currentAddress = "Error retrieving location.";
      });
    } finally {
      _loadingAddress = false;
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
                    keyboardType: TextInputType.streetAddress,
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
                  onChanged: (value) {
                    setState(() {
                      sliderValue = value;
                    });
                  },
                  label: '${sliderValue.round().toString()} km',
                  min: 0,
                  max: 1000,
                  divisions: 100,
                  thumbColor: Colors.blue,
                  activeColor: Colors.lightBlue,
                )
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
                                  builder: (context) => MainPage()))
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
