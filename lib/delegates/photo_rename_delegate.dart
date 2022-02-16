import 'package:flutter/material.dart';

abstract class PhotoNameDelegate {
  String rename(BuildContext context, String origin);

  static PhotoNameDelegate defaultPhotoNameDelegate =
      DefaultPhotoNameDelegate();

  bool isChinese(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'zh';
}

class DefaultPhotoNameDelegate extends PhotoNameDelegate {
  @override
  String rename(BuildContext context, String origin) {
    String result = origin;
    if (!isChinese(context)) {
      switch (origin) {
        case '最近项目':
        case '最近':
        case '全部':
        case '所有':
          result = 'Recent';
          break;
        case '图片':
        case '照片':
        case '图库':
          result = 'Pictures';
          break;
        case '相机':
        case '拍照':
        case '相機':
        case '原況照片':
        case '实况照片':
          result = 'Camera';
          break;
        case '截圖':
        case '熒幕截圖':
        case '截屏':
          result = 'Screenshots';
          break;
        case '视频':
          result = 'Video';
          break;
        case '电影':
          result = 'Movie';
          break;
        default:
      }
      return result;
    }
    switch (origin) {
      case 'Recent':
      case 'All':
        result = '最近';
        break;
      case 'Pictures':
      case 'Picture':
      case 'picture':
      case 'pictures':
        result = '图片';
        break;
      case 'Camera':
      case 'camera':
      case 'Live Photos':
        result = '相机';
        break;
      case 'Screenshots':
      case 'Screenshot':
      case 'screenshots':
      case 'screenshot':
        result = '截图';
        break;
      case 'video':
      case 'Video':
        result = '视频';
        break;
      case 'Movie':
      case 'movie':
        result = '电影';
        break;
      default:
    }
    return result;
  }
}
