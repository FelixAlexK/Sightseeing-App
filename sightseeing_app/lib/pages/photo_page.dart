import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/place.dart';

class PhotoCaptureApp extends StatefulWidget {
  @override
  _PhotoCaptureAppState createState() => _PhotoCaptureAppState();
}

class _PhotoCaptureAppState extends State<PhotoCaptureApp> {
  File? _storedImage;

  // Function to capture a photo
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().toIso8601String(); // Unique filename
    final savedImage =
        await File(pickedFile.path).copy('${appDir.path}/$fileName.jpg');

    setState(() {
      _storedImage = savedImage;
    });
  }

  // Function to display the image
  Future<void> _loadPhoto() async {
    final appDir = await getApplicationDocumentsDirectory();
    final storedImagePath =
        '${appDir.path}/image.jpg'; // Update to dynamic logic if needed

    final storedImage = File(storedImagePath);
    if (await storedImage.exists()) {
      setState(() {
        _storedImage = storedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(places[at].name),
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/map.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/${places[at].imageUrl}',
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        places[at].description,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.0),
                      Text(
                        "Coordinates: ${places[at].cord}",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(1.0, 1.0),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _storedImage != null
                        ? Image.file(
                            _storedImage!,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        : Text('No image captured'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _takePhoto,
                      child: Text('Take Photo'),
                    ),
                    ElevatedButton(
                      onPressed: _loadPhoto,
                      child: Text('Load Photo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
