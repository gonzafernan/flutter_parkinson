import 'package:flutter_parkinson/classifier.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class ClassifierQuant extends Classifier {
  String model_name = "";

  ClassifierQuant(this.model_name, {int numThreads = 1})
      : super(numThreads: numThreads);

  @override
  String get modelName => model_name;

  @override
  NormalizeOp get preProcessNormalizeOp => NormalizeOp(0, 1);

  @override
  NormalizeOp get postProcessNormalizeOp => NormalizeOp(0, 255);
}
