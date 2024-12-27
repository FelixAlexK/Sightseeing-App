import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sightseeing_app/models/place.dart';

class PhotoCaptureApp extends StatefulWidget {
  @override
  _PhotoCaptureAppState createState() => _PhotoCaptureAppState();
}

class _PhotoCaptureAppState extends State<PhotoCaptureApp> {
  File? _storedImage;
  String? _fileName;

  // Function to capture a photo
  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    _fileName = DateTime.now().toIso8601String(); // Unique filename
    final savedImage =
        await File(pickedFile.path).copy('${appDir.path}/$_fileName.jpg');

    setState(() {
      _storedImage = savedImage;
    });
  }

  // Function to display the image
  Future<void> _done() async {
    if (_fileName == null) {
      // Handle case where fileName is null
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No photo taken yet.')),
      );
      final tempPlace = Place(
          name: places[at].name,
          description: places[at].description,
          date: DateTime.now(),
          cord: places[at].cord,
          imageUrl: places[at].imageUrl,
          diff: currentDiff);
      placesBeen.add(tempPlace);
      return;
    }

    final appDir = await getApplicationDocumentsDirectory();
    final storedImagePath = '${appDir.path}/$_fileName.jpg';

    final storedImage = File(storedImagePath);

    if (await storedImage.exists()) {
      setState(() {
        _storedImage = storedImage;
        final tempPlace = Place(
            name: places[at].name,
            description: places[at].description,
            date: DateTime.now(),
            cord: places[at].cord,
            imageUrl: "$_fileName.jpg",
            diff: currentDiff);
        placesBeen.add(tempPlace);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No saved image found.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Photo Capture')),
      body: Center(
        child: Column(
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
              child: Text('Take photo'),
            ),
            ElevatedButton(
              onPressed: _done,
              child: Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
