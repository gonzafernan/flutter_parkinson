import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui';

import 'package:image/image.dart' as img;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'package:flutter_parkinson/sketcher.dart';
import 'package:flutter_parkinson/drawn_line.dart';
import 'package:flutter_parkinson/classifier.dart';
import 'package:flutter_parkinson/classifier_quant.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final GlobalKey _globalKey = GlobalKey();

  //============================================================================
  // Classification model related
  late Classifier _spiral_classifier;
  late Classifier _wave_classifier;
  File? _image;
  final picker = ImagePicker();
  Category? category;
  //============================================================================

  // Line draw object
  List<DrawnLine> lines = <DrawnLine>[];
  DrawnLine line = DrawnLine([], Colors.black, 5.0);

  // GestureDetector's events to detect the touches on screen
  GestureDetector buildCurrentPath(BuildContext context) {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: RepaintBoundary(
        key: _globalKey,
        child: Container(
          color: Colors.yellow[50],
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CustomPaint(
            painter: Sketcher(lines: [line]),
          ),
        ),
      ),
    );
  }

  void onPanStart(DragStartDetails details) {
    //print("User started drawing");
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    //print(point);

    setState(() {
      line = DrawnLine([point], Colors.black, 5.0);
    });
  }

  void onPanUpdate(DragUpdateDetails details) {
    final box = context.findRenderObject() as RenderBox;
    final point = box.globalToLocal(details.globalPosition);
    //print(point);

    final path = List.from(line.path)..add(point);

    setState(() {
      line = DrawnLine(path, Colors.black, 5.0);
    });
  }

  void onPanEnd(DragEndDetails details) {
    //setState(() {
    //print("User ended drawing");
    //});
  }

  Future<void> save() async {
    try {
      final RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage();
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();
      final saved = await ImageGallerySaver.saveImage(
        pngBytes,
        quality: 100,
        name: DateTime.now().toIso8601String() + ".png",
        isReturnImagePathOfIOS: true,
      );
    } catch (e) {
      //print(e);
    }
  }

  Widget buildButtonMenu() {
    return Positioned(
      bottom: 50.0,
      left: 50.0,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            //buildButtonSave("SAVE DRAWING"),
            buildButtonClear("SUBMIT SPIRAL", 0),
            buildButtonClear("SUBMIT WAVE", 1),
            Text(
              category != null ? category!.label : 'NOT READY',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )
          ]),
    );
  }

  Widget buildButtonSave(String buttonText) {
    return TextButton(onPressed: save, child: Text(buttonText));
  }

  Widget buildButtonClear(String buttonText, int id) {
    if (id == 0) {
      return TextButton(onPressed: getSpiralImage, child: Text(buttonText));
    } else {
      return TextButton(onPressed: getWaveImage, child: Text(buttonText));
    }
  }

  //============================================================================
  // Classification model related

  void _predict(Classifier classifier) async {
    final RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final pngBytes = byteData!.buffer.asUint8List();
    img.Image imageInput = img.decodeImage(pngBytes)!;
    var pred = classifier.predict(imageInput);
    print(classifier.modelName);
    print(pred);

    setState(() {
      category = pred;
    });
  }

  Future getSpiralImage() async {
    //final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      //_image = File(pickedFile!.path);

      _predict(_spiral_classifier);
    });
  }

  Future getWaveImage() async {
    //final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      //_image = File(pickedFile!.path);

      _predict(_wave_classifier);
    });
  }
  //============================================================================

  @override
  void initState() {
    super.initState();
    _spiral_classifier = ClassifierQuant('spiral_model_unquant.tflite');
    _wave_classifier = ClassifierQuant('wave_model_unquant.tflite');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[50],
      body: Stack(
        children: [
          //buildAllPaths(context),
          buildCurrentPath(context),
          buildButtonMenu(),
        ],
      ),
    );
  }

  /*
  @override
  void dispose() {
    linesStreamController.close();
    currentLineStreamController.close();
    super.dispose();
  }
  */
}
