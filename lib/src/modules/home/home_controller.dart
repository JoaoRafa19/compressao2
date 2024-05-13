import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:compressao2/src/model/image_model.dart';
import 'package:compressao2/src/repositories/image_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HomeController {
  final ImageRepository imageRepository;

  HomeController(this.imageRepository);
  final images = signal<List<ImageModel>?>(null);
  final erros = signal<String?>(null);
  final messages = signal<String?>(null);
  final loading = signal<bool>(false);
  final sendProgress = signal<double?>(0.0);

  Future<void> init() async {
    try {
      loading.set(true);
      final savedImages = await imageRepository.getAllImages();
      log("Saved images, : ${savedImages.toSet()}");
      images.value = savedImages;
      loading.set(false);
    } catch (e) {
      loading.set(false);
      erros.value = "Erro ao buscar imagens";
    }
  }

  Future<void> removeImage(ImageModel? image) async {
    if (image == null) return;
    loading.set(true);
    await imageRepository.removeImage(image);
    init();
    loading.set(false);
  }

  Future<void> sendImages() async {
    try {
      loading.value = true;
      final sendImages = <ImageModel>[];
      messages.value = "Comprimindo imagens";
      for (final image
          in images.value?.where((element) => element.isSelected).toList() ??
              <ImageModel>[]) {
        final original = image.copyWith(
            imageName:
                "${image.imageName.split(".").first}_ORIGINAL_${image.imageName.split(".").last}");

        sendImages.add(original);

        var uint8list = Uint8List.fromList(image.base64Image);
        final memoryImage = MemoryImage(uint8list);
        Completer<ui.Image> completer = Completer<ui.Image>();
        memoryImage.resolve(const ImageConfiguration()).addListener(
            ImageStreamListener(
                (ImageInfo info, bool _) => completer.complete(info.image)));
        final int width = (await completer.future).width;
        final int height = (await completer.future).height;
        final int max = width > height ? width : height;
        final int quality = max >= 1080 ? 50 : 80;
        var compressedImage = await FlutterImageCompress.compressWithList(
          uint8list,
          minHeight: height,
          minWidth: width,
          quality: quality,
        );
        final sendImage = image.copyWith(
            base64Image: compressedImage,
            imageName:
                "${image.imageName.split(".").first}_${quality}_${image.imageName.split(".").last}");
        sendImages.add(sendImage);
        var compressed70 = await FlutterImageCompress.compressWithList(
          uint8list,
          minHeight: height,
          minWidth: width,
          quality: 70,
        );
        final sendImage70 = image.copyWith(
            base64Image: compressed70,
            imageName:
                "${image.imageName.split(".").first}_${70}_${image.imageName.split(".").last}");
        sendImages.add(sendImage70);
        var compressed80 = await FlutterImageCompress.compressWithList(
          uint8list,
          minHeight: height,
          minWidth: width,
          quality: 80,
        );
        final sendImage80 = image.copyWith(
            base64Image: compressed80,
            imageName:
                "${image.imageName.split(".").first}_${80}_${image.imageName.split(".").last}");
        sendImages.add(sendImage80);
        var compressed90 = await FlutterImageCompress.compressWithList(
          uint8list,
          minHeight: height,
          minWidth: width,
          quality: 90,
        );
        final sendImage90 = image.copyWith(
            base64Image: compressed90,
            imageName:
                "${image.imageName.split(".").first}_${90}_${image.imageName.split(".").last}");
        sendImages.add(sendImage90);
        var compressed60 = await FlutterImageCompress.compressWithList(
          uint8list,
          minHeight: height,
          minWidth: width,
          quality: 60,
        );
        final sendImage60 = image.copyWith(
            base64Image: compressed60,
            imageName:
                "${image.imageName.split(".").first}_${60}_${image.imageName.split(".").last}");
        sendImages.add(sendImage60);
      }

      messages.value = 'enviando...';
      final result = await imageRepository.sendImages(
        sendImages,
      );
      if (result.fail > 0) {
        erros.set("${result.fail} com falha, ${result.succes} com sucesso");
      }
      messages.value = "recarregando view...";
      await init();
      loading.value = false;
    } catch (e) {
      log("Erro  ao comprimir imagens", error: e);
    }
  }
}
