import 'package:flutter/material.dart';

abstract class PhotoNameDelegate {
  String rename(BuildContext context, String origin);

  static PhotoNameDelegate defaultPhotoNameDelegate =
      DefaultPhotoNameDelegate();
}

class DefaultPhotoNameDelegate extends PhotoNameDelegate {
  @override
  String rename(BuildContext context, String origin) {
    if (!isChinese(context)) return origin;
    String result = origin;
    switch (origin) {
      case 'Recent':
        result = '最近';
        break;
      case 'Pictures':
        result = '图片';
        break;
      case 'Camera':
        result = '相机';
        break;
      case 'Screenshots':
      case 'Screenshot':
        result = '截图';
        break;
      case 'video':
      case 'Video':
        result = '视频';
        break;
      default:
    }
    return result;
  }

  bool isChinese(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'zh';
}
