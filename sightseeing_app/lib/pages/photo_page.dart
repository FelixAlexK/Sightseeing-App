import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

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
    final fileName = pickedFile.name; // Original filename from the picker
    final savedImage =
        await File(pickedFile.path).copy('${appDir.path}/$fileName');

    setState(() {
      _storedImage = savedImage;
    });
  }

  // Function to display the image
  Future<void> _loadPhoto() async {
    final appDir = await getApplicationDocumentsDirectory();
    final storedImagePath =
        '${appDir.path}/image.jpg'; // Ensure path matches saved name

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
              child: Text('Take Photo'),
            ),
            ElevatedButton(
              onPressed: _loadPhoto,
              child: Text('Load Photo'),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PhotoCaptureApp(),
  ));
}
