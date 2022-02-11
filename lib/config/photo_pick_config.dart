import 'package:flutter/material.dart';
import 'package:photo_picker/delegates/photo_rename_delegate.dart';

class PhotoPickerConfig {
  PhotoPickerConfig({
    this.backgroundColor = Colors.black,
    this.crossAxisCount = 4,
    this.mainAxisSpacing = 2,
    this.crossAxisSpacing = 2,
    this.perPageSize = 200,
    this.thumbPhotoSize = 200,
    this.maxSelectedCount = 9,
    this.disableCoverColor,
    this.selectedCoverColor,
  });

  static PhotoNameDelegate photoNameDelegate =
      PhotoNameDelegate.defaultPhotoNameDelegate;

  final Color backgroundColor;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final int perPageSize;
  final int thumbPhotoSize;
  final int maxSelectedCount;
  final Color? disableCoverColor;
  final Color? selectedCoverColor;
}
