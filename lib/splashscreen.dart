import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'dart:io';

class MySplash extends StatefulWidget {
  @override
  _MySplashState createState() => _MySplashState();
}

class _MySplashState extends State<MySplash> {
  File? _image;
  String path = "";
  String? _diseaseResult;
  List<String> labels = ["ESCA", "Leaf Blight", "Black rot", "Healthy"];

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    try {
      await Tflite.loadModel(
          model: "assets/grape_disease_detection_model.tflite",
          labels: "assets/labels.txt",
          numThreads: 1, // defaults to 1
          isAsset:
              true, // defaults to true, set to false to load resources outside assets
          useGpuDelegate:
              false // defaults to false, set to true to use GPU delegate
          );
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
        path = pickedFile.path;
        _image = File(pickedFile.path);
        _diseaseResult = null; // Reset output when a new image is picked
      });
    }
  }

  // Uint8List _preprocessImage(File imageFile) {
  //   final originalImage = img.decodeImage(imageFile.readAsBytesSync())!;
  //   final resizedImage = img.copyResize(originalImage, width: 256, height: 256);
  //   return resizedImage.getBytes();
  // }

  Future<void> _detectDiseases() async {
    print("Detect Diseases button pressed.");

    if (_image == null) {
      print("No image selected.");
      return;
    }

    // if (_interpreter == null) {
    //   print("Model interpreter not initialized.");
    //   return;
    // }

    try {
      //final input = _preprocessImage(_image!);
      //final output = List.filled(labels.length, 0).reshape([1, labels.length]);

      var output = await Tflite.runModelOnImage(
          path: path, // required
          imageMean: 127.5, // defaults to 127.5
          imageStd: 127.5, // defaults to 127.5
          threshold: 0.4, // defaults to 0.1
          //numResultsPerClass: 2, // defaults to 5
          asynch: true // defaults to true
          );

      // Debug print the output tensor for verification
      print("Output tensor: $output");

      setState(() {
        final detectedLabel = output![0]['label'];
        if (detectedLabel == "Healthy") {
          _diseaseResult = "The leaf is healthy.";
        } else {
          _diseaseResult = "The leaf is affected by $detectedLabel.";
        }
      });
    } catch (e) {
      print("Failed to run model: $e");
      setState(() {
        _diseaseResult = "Failed to detect disease.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LEAF HEALTH CHECKER',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
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
            decoration: const BoxDecoration(
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
                const SizedBox(height: 50),
                _buildButton(
                  context,
                  'Capture Image',
                  Icons.camera_alt,
                  () {
                    _pickImage(ImageSource.camera);
                  },
                  Colors.purpleAccent,
                ),
                const SizedBox(height: 20),
                _buildButton(
                  context,
                  'Browse Gallery',
                  Icons.photo_library,
                  () {
                    _pickImage(ImageSource.gallery);
                  },
                  Colors.deepPurpleAccent,
                ),
                const SizedBox(height: 20),
                _buildButton(
                  context,
                  'Detect Diseases',
                  Icons.local_hospital,
                  _detectDiseases,
                  Colors.pinkAccent,
                ),
                const SizedBox(height: 20),
                _diseaseResult != null
                    ? Text(
                        _diseaseResult!,
                        style: const TextStyle(
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
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      ),
      icon: Icon(icon,
          size: 30,
          color: Colors.white), // Ensure icon color is white for visibility
      label: Text(
        text,
        style: const TextStyle(
            fontSize: 18,
            color: Colors.white), // Ensure text color is white for visibility
      ),
      onPressed: onPressed,
    );
  }

  @override
  void dispose() {
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
