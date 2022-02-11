import 'package:photo_manager/photo_manager.dart';

abstract class SortPathDelegate<Path> {
  const SortPathDelegate();

  void sort(List<Path> list);

  static const defaultDelegate = DefaultSortPathDelegate();
}

class DefaultSortPathDelegate extends SortPathDelegate<AssetPathEntity> {
  const DefaultSortPathDelegate();

  @override
  void sort(List<AssetPathEntity> list) {
    list.sort((AssetPathEntity path1, AssetPathEntity path2) {
      if (path1.isAll) {
        return -1;
      }
      if (path2.isAll) {
        return 1;
      }
      if (_isCamera(path1)) {
        return -1;
      }
      if (_isCamera(path2)) {
        return 1;
      }
      if (_isScreenShot(path1)) {
        return -1;
      }
      if (_isScreenShot(path2)) {
        return 1;
      }
      return 0;
    });

    // 删除隐藏相册
    list.removeWhere((element) {
      return _isHide(element);
    });
  }

  int otherSort(AssetPathEntity path1, AssetPathEntity path2) {
    return path1.name.compareTo(path2.name);
  }

  bool _isCamera(AssetPathEntity entity) {
    return entity.name == 'Camera' ||
        entity.name == '相机' ||
        entity.name == '相機' ||
        entity.name == 'Live Photos' ||
        entity.name == '原況照片' ||
        entity.name == '实况照片';
  }

  bool _isScreenShot(AssetPathEntity entity) {
    return entity.name == 'Screenshots' ||
        entity.name == 'Screenshot' ||
        entity.name == '截圖' ||
        entity.name == '熒幕截圖' ||
        entity.name == '截屏';
  }

  bool _isHide(AssetPathEntity entity) {
    return entity.name == '已隐藏' ||
        entity.name == 'Hidden' ||
        entity.name == '非表示' ||
        entity.name == '已隱藏';
  }
}
