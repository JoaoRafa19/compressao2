import 'package:camera/camera.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CameraPageController {
  final isTakingPicture = signal(false);
  final selectedResulution = signal(ResolutionPreset.veryHigh);
}
