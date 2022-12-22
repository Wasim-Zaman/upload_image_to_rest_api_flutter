// ignore_for_file: depend_on_referenced_packages, avoid_print

import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import "package:http/http.dart" as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? imageFile; // This will store path of the image from the gallery
  final _imagePicker = ImagePicker(); // this will be used to pick image.
  bool showSpinner = false;

  Future pickImage() async {
    try {
      // pick image
      final pickedImage = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      // check if image is picked
      if (pickedImage != null) {
        setState(() {
          imageFile = File(pickedImage.path);
        });
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      showSpinner = true;
    });

    final byteStream = http.ByteStream(imageFile!.openRead());
    final length = await imageFile!.length();

    // multi part request
    final request = http.MultipartRequest(
        "POST", Uri.parse('https://fakestoreapi.com/products'));
    request.fields['title'] = 'Some text';

    // multi part files
    final multiPartFile = http.MultipartFile('image', byteStream, length);
    request.files.add(multiPartFile);

    // getting response
    final response = await request.send();
    print(response.toString());

    if (response.statusCode == 200) {
      setState(() {
        showSpinner = false;
      });
      print("Image successfully uploaded!");
    } else {
      showSpinner = false;
      print('An error occures while uploading an image!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Image'),
      ),
      body: showSpinner
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  child: imageFile == null
                      ? GestureDetector(
                          onTap: () => pickImage(),
                          child: const Center(
                            child: Text('Pick Image'),
                          ),
                        )
                      : Center(
                          child: Image.file(
                            File(imageFile!.path).absolute,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                const SizedBox(
                  height: 50,
                ),
                ElevatedButton(
                  onPressed: () async {
                    await uploadImage();
                  },
                  child: const Text('Upload Image'),
                )
              ],
            ),
    );
  }
}
