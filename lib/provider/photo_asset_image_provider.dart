import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PhotoAssetImageProvider extends ImageProvider<PhotoAssetImageProvider> {
  const PhotoAssetImageProvider(
    this.entity, {
    this.scale = 1.0,
    this.thumbSize = const <int>[200, 200],
    this.isOriginal = true,
  }) : assert(
          isOriginal || thumbSize?.length == 2,
          'thumbSize must contain and only contain two integers when it\'s not original',
        );

  final AssetEntity entity;

  /// Scale for image provider.
  /// 缩放
  final double scale;

  /// Size for thumb data.
  /// 缩略图的大小
  final List<int>? thumbSize;

  /// Choose if original data or thumb data should be loaded.
  /// 选择载入原数据还是缩略图数据
  final bool isOriginal;

  /// File type for the image asset, use it for some special type detection.
  /// 图片资源的类型，用于某些特殊类型的判断
  ImageFileType get imageFileType => _getType();

  @override
  ImageStreamCompleter load(
    PhotoAssetImageProvider key,
    DecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: key.scale,
      informationCollector: () {
        return <DiagnosticsNode>[
          DiagnosticsProperty<ImageProvider>('Image provider', this),
          DiagnosticsProperty<PhotoAssetImageProvider>('Image key', key),
        ];
      },
    );
  }

  @override
  Future<PhotoAssetImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PhotoAssetImageProvider>(this);
  }

  Future<ui.Codec> _loadAsync(
    PhotoAssetImageProvider key,
    DecoderCallback decode,
  ) async {
    try {
      assert(key == this);
      if (key.entity.type == AssetType.audio ||
          key.entity.type == AssetType.other) {
        throw UnsupportedError(
          'Image data for the ${key.entity.type} is not supported.',
        );
      }
      Uint8List? data;
      final ImageFileType _type;
      if (key.imageFileType == ImageFileType.other) {
        // Assume the title is invalid here, try again with the async getter.
        _type = _getType(await key.entity.titleAsync);
      } else {
        _type = key.imageFileType;
      }
      if (isOriginal) {
        if (key.entity.type == AssetType.video) {
          data = await key.entity.thumbDataWithOption(
            _thumbOption(thumbSize![0], thumbSize![1]),
          );
        } else if (_type == ImageFileType.heic) {
          data = await (await key.entity.file)?.readAsBytes();
        } else {
          data = await key.entity.originBytes;
        }
      } else {
        final List<int> _thumbSize = thumbSize!;
        data = await key.entity.thumbDataWithOption(
          _thumbOption(_thumbSize[0], _thumbSize[1]),
        );
      }
      if (data == null) {
        throw StateError('The data of the entity is null: $entity');
      }
      return decode(data);
    } catch (e) {
      // Depending on where the exception was thrown, the image cache may not
      // have had a chance to track the key in the cache at all.
      // Schedule a microtask to give the cache a chance to add the key.
      Future<void>.microtask(() {
        PaintingBinding.instance?.imageCache?.evict(key);
      });
      rethrow;
    }
  }

  ThumbOption _thumbOption(int width, int height) {
    if (Platform.isIOS || Platform.isMacOS) {
      return ThumbOption.ios(
        width: width,
        height: height,
        deliveryMode: DeliveryMode.opportunistic,
      );
    }
    return ThumbOption(width: width, height: height);
  }

  /// Get image type by reading the file extension.
  /// 从图片后缀判断图片类型
  ///
  /// ⚠ Not all the system version support read file name from the entity,
  /// so this method might not work sometime.
  /// 并非所有的系统版本都支持读取文件名，所以该方法有时无法返回正确的type。
  ImageFileType _getType([String? filename]) {
    ImageFileType? type;
    final String? extension = filename?.split('.').last ??
        entity.mimeType?.split('/').last ??
        entity.title?.split('.').last;
    if (extension != null) {
      switch (extension.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
          type = ImageFileType.jpg;
          break;
        case 'png':
          type = ImageFileType.png;
          break;
        case 'gif':
          type = ImageFileType.gif;
          break;
        case 'tiff':
          type = ImageFileType.tiff;
          break;
        case 'heic':
          type = ImageFileType.heic;
          break;
        default:
          type = ImageFileType.other;
          break;
      }
    }
    return type ?? ImageFileType.other;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    if (identical(this, other)) {
      return true;
    }
    return entity == other.entity &&
        scale == other.scale &&
        thumbSize == other.thumbSize &&
        isOriginal == other.isOriginal;
  }

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode {
    return hashValues(
      entity,
      scale,
      thumbSize?.elementAt(0) ?? 0,
      thumbSize?.elementAt(1) ?? 0,
      isOriginal,
    );
  }
}

enum ImageFileType { jpg, png, gif, tiff, heic, other }

enum SpecialImageType { gif, heic }
