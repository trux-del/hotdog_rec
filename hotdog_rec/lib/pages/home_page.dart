import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({ Key? key }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  PickedFile? _image;
  bool _loading = false ;
  List<dynamic>? _outputs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff313C46),
        title: const Text("Hotdog Detector"),
      ),
      body: _loading ? const Center(
        child: CircularProgressIndicator(color: Colors.blue,),
      ) : SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _image == null ? Container() : Image.file(File(_image!.path), fit: BoxFit.contain,),
                  const SizedBox(
                    height: 30,
                  ),
                  _outputs != null ? 
                    Text("${_outputs![0]["label"]}", style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),)
                  : Container(child: Text("hmmmm")),
                ],
            ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: const Color(0xff313C46),
            ),
            child: IconButton(
              icon: const Icon(Icons.photo_camera_outlined, color: Colors.white,),
              onPressed: chooseCameraImage,
            ),
          ),
          SizedBox(height: 5,),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              color: const Color(0xff313C46),
            ),
            child: IconButton(
              icon: const Icon(Icons.image_outlined, color: Colors.white,),
              onPressed: chooseGalleryImage,
            ),
          ),
        ],
      ),
    );
  }
  
  Future chooseCameraImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.camera);
    
    setState(() {
      _image = image;
    });
    classifyImage(_image);
  }

  Future chooseGalleryImage() async {
    var image = await ImagePicker().getImage(source: ImageSource.gallery);
    
    setState(() {
      _image = image;
    });
    classifyImage(_image);
  }

  classifyImage(image) async {
    var output = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    if (output == null) print("lol");
    setState(() {
      _loading = false;
      _outputs = output;
      print("output: " + output.toString());
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt" 
    );
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

}

