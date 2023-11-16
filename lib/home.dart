import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:face_recognition_app/main.dart';
import 'package:tflite/tflite.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State <Home> createState() =>  HomeState();
}



class  HomeState extends State <Home> {
  CameraImage? cameraImage;
  CameraController? cameraController;
  String output = '';

  @override
  void initState() {
    super.initState();
    loadCamera();
    loadmodel();
  }
  loadCamera(){
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value){
      if(!mounted){
        return;
      }
      else{
        setState(() {
          cameraController!.startImageStream((imageStream){
            cameraImage = imageStream;
            runModel();
          });
        });
      }
    });
  }

  runModel()async{
    if(cameraImage!=null){
      var predictions = await Tflite.runModelOnFrame(
          bytesList: cameraImage!.planes.map((plane){
            return plane.bytes;
      }).toList(),
      imageHeight: cameraImage!.height,
      imageWidth: cameraImage!.width,
      imageMean: 127.5,
      imageStd: 127.5,
      rotation: 90,
      numResults: 2,
      threshold: 0.1,
      asynch: true);
      for (var element in predictions!) {
        setState(() {
          output = element['Label'];
        });
      }
    }
  }

loadmodel() async {
    await Tflite.loadModel(
        model: "assets/model.tflite",labels: "assets/labels.txt");
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:const Text('Live Emotion Detection App')),
      body: Column(
        children: [
          Padding(padding:
          const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height*.7,
            width: MediaQuery.of(context).size.width*.7,
            child:!cameraController!.value.isInitialized?
            Container():
            AspectRatio(aspectRatio: cameraController!.value.aspectRatio,
            child: CameraPreview(cameraController!),),
          ),
          ),
          Text(output,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20
          ),)
        ]
      ),
    );
  }
}