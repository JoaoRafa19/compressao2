import 'package:flutter/material.dart';

import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class ImageModel {
  @JsonKey(name: 'base64image')
  final List<int> base64Image;
  @JsonKey(name: 'image_name')
  final String imageName;

  final String? imageId;

  final bool isSelected;

  ImageModel({
    required this.base64Image,
    required this.imageName,
    this.imageId,
    this.isSelected = false,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) => ImageModel(
      base64Image: List<int>.from(json["base64Image"]),
      imageId: json['id'],
      imageName: json['image_name'],
      isSelected: json['is_selected']);

  Map<String, dynamic> toJson() => {
        "base64Image": base64Image,
        "image_name": imageName,
        "id": imageId,
        "is_selected": isSelected,
      };

  ImageModel copyWith({
    String? imagePath,
    List<int>? base64Image,
    String? imageName,
    bool? selected,
    ValueGetter<String?>? imageId,
  }) {
    return ImageModel(
      base64Image: base64Image ?? this.base64Image,
      imageName: imageName ?? this.imageName,
      imageId: imageId != null ? imageId() : this.imageId,
      isSelected: selected ?? isSelected,
    );
  }
}
