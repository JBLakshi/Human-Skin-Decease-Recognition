// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  PickedFile? _imageFile;
  bool _loading = false;

  late List _outputs;
  late List test;
  late String labelData;
  late File _image;
  late String newtest;

  
  final databaseReference = FirebaseDatabase.instance.reference();

  void initState() {
    super.initState();
    Tflite.loadModel(
      model: "assets/human.tflite", // Replace with the path to your model
      labels: "assets/labels.txt", // Replace with the path to your labels file
    );
  }

  classifyImage(File image) async {
    try {
      var output = await Tflite.runModelOnImage(
          path: image.path,
          imageMean: 0.0,
          imageStd: 255.0,
          numResults: 2,
          threshold: 0.2,
          asynch: true);
      setState(() {
        _loading = false;
        _outputs = output!;
        labelData = _outputs[0]["label"].toString();
      });
    } catch (e) {
      // Handle and log the error
      print("Error: $e");
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _loading = true;
      _imageFile = pickedFile;
    });
    File image = File(pickedFile!.path);
    classifyImage(image);
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _loading = true;
        _imageFile = pickedFile;
      });

      File image = File(pickedFile.path);
      classifyImage(image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: Text(
          'Human Disease'.toUpperCase(),
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        _pickImage();
                      },
                      icon: Icon(Icons.image),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        iconColor: MaterialStateProperty.all(Colors.white),
                        elevation: MaterialStateProperty.all(5),
                      ),
                      label: Text(
                        'Gallery',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      )),
                  ElevatedButton.icon(
                      onPressed: () {
                        _pickImageFromCamera();
                      },
                      icon: Icon(Icons.image),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        iconColor: MaterialStateProperty.all(Colors.white),
                        elevation: MaterialStateProperty.all(5),
                      ),
                      label: Text(
                        'Camera',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ))
                ],
              ),
              SizedBox(
                height: 15,
              ),
               Center(
                  child: _imageFile == null
                      ? Image.asset(
                          'assets/default.jpg',
                          height: 300,
                          width: 300,
                        )
                      : Image.file(
                          File(_imageFile!.path),
                          height: 300,
                          width: 300,
                        ),
                ),
                _imageFile == null
                    ? Container()
                    : _outputs != null
                        ? Column(
                            children: [
                              StreamBuilder(
                                stream: databaseReference
                                    .child(
                                        _outputs[0]["label"].toString().trim())
                                    .onValue,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    var data = snapshot.data!.snapshot.value;

                                    final jsonDataEncode = json.encode(data);
                                    // final jsonData = '''$data''';
                                    Map<String, dynamic> newData =
                                        json.decode(jsonDataEncode);
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _outputs[0]["label"].toString(),
                                          style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 163, 4, 137)),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          color:
                                              Color.fromARGB(255, 196, 15, 15),
                                          child: SizedBox(
                                            height: 5,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          child: Text(
                                            'Problem',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: Colors.blueAccent),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Text(
                                            newData['details'],
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          child: Text(
                                            'Solution',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 24,
                                                color: Colors.blueAccent),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 15, right: 15),
                                          child: Text(
                                            newData['solution'],
                                            textAlign: TextAlign.justify,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                     
                                     
                                      ],
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text("Error: ${snapshot.error}");
                                  }
                                  return CircularProgressIndicator(); // Loading indicator
                                },
                              )
                            ],
                          )
                        : Container(child: Text("")),
                SizedBox(
                  height: 20,
                ),
       
            ],
          ),
        ),
      ),
    );
  }
}
