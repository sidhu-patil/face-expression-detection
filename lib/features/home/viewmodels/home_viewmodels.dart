import 'package:image_picker/image_picker.dart';
import 'package:riverpod/riverpod.dart';

final imagesProvider = Provider<ImagePicker>((ref) => ImagePicker());
