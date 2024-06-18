import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  File? _image;
  String? _diseaseResult;
  Interpreter? _interpreter;
  List<String> labels = ["ESCA", "Leaf Blight", "Black rot", "Healthy"];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
          'assets/grape_disease_detection_model.tflite');
      print("Model loaded successfully");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _diseaseResult = null; // Reset output when a new image is picked
      });
    }
  }

  Uint8List _preprocessImage(File imageFile) {
    final originalImage = img.decodeImage(imageFile.readAsBytesSync())!;
    final resizedImage = img.copyResize(originalImage, width: 256, height: 256);
    return resizedImage.getBytes();
  }

  Future<void> _detectDiseases() async {
    print("Detect Diseases button pressed.");

    if (_image == null) {
      print("No image selected.");
      return;
    }

    if (_interpreter == null) {
      print("Model interpreter not initialized.");
      return;
    }

    //   try {
    final input = _preprocessImage(_image!);
    final output = List.filled(labels.length, 0).reshape([1, labels.length]);

    _interpreter!.run(input, output);

    // Debug print the output tensor for verification
    print("Output tensor: $output");

    setState(() {
      final detectedIndex = output[0].indexWhere(
          (element) => element == output[0].reduce((a, b) => a > b ? a : b));
      final detectedLabel = labels[detectedIndex];
      if (detectedLabel == "Healthy") {
        _diseaseResult = "The leaf is healthy.";
      } else {
        _diseaseResult = "The leaf is affected by $detectedLabel.";
      }
    });
    // // } catch (e) {
    //   print("Failed to run model: $e");
    //   setState(() {
    //     _diseaseResult = "Failed to detect disease.";
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LEAF HEALTH CHECKER',
          style: GoogleFonts.poppins(
            textStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF7B4397),
                  Color(0xFFDC2430)
                ], // Grape violet gradient
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _image != null
                    ? Image.file(
                        _image!,
                        width: 200,
                        height: 200,
                      )
                    : Image.asset(
                        'assets/Grape icon2.png',
                        width: 200,
                        height: 200,
                      ),
                SizedBox(height: 50),
                _buildButton(
                  context,
                  'Capture Image',
                  Icons.camera_alt,
                  () {
                    _pickImage(ImageSource.camera);
                  },
                  Colors.purpleAccent,
                ),
                SizedBox(height: 20),
                _buildButton(
                  context,
                  'Browse Gallery',
                  Icons.photo_library,
                  () {
                    _pickImage(ImageSource.gallery);
                  },
                  Colors.deepPurpleAccent,
                ),
                SizedBox(height: 20),
                _buildButton(
                  context,
                  'Detect Diseases',
                  Icons.local_hospital,
                  _detectDiseases,
                  Colors.pinkAccent,
                ),
                SizedBox(height: 20),
                _diseaseResult != null
                    ? Text(
                        _diseaseResult!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
          // You can place other widgets or animations here if needed
        ],
      ),
    );
  }

  Widget _buildButton(BuildContext context, String text, IconData icon,
      VoidCallback onPressed, Color color) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      icon: Icon(icon,
          size: 30,
          color: Colors.white), // Ensure icon color is white for visibility
      label: Text(
        text,
        style: TextStyle(
            fontSize: 18,
            color: Colors.white), // Ensure text color is white for visibility
      ),
      onPressed: onPressed,
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    title: 'Leaf Health Checker',
    theme: ThemeData(
      primarySwatch: Colors.purple,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: MySplash(),
  ));
}
