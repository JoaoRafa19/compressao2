import 'package:compressao2/src/model/image_model.dart';

abstract interface class ImageRepository {
  Future<String?> saveImage(ImageModel image);
  Future<ImageModel?> getImage(String imageId);
  Future<List<ImageModel>> getAllImages();
  Future<List<String>> getIds();

  Future<bool> removeImage(ImageModel image);

  Future<({int succes, int fail})> sendImages(List<ImageModel> images,
      {Function(int, int)? progress});
}
