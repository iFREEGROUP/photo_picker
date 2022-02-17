import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_picker/config/photo_pick_config.dart';

class PhotoPickController {
  PhotoPickController({required this.config});

  /// 相册分页请求数据时每页的数量
  final PhotoPickerConfig config;

  /// 当前选择的路径
  final ValueNotifier<AssetPathEntity?> pathNotifier = ValueNotifier(null);

  /// 当前选择路径下的所有图片
  final ValueNotifier<List<AssetEntity>?> assetEntityList = ValueNotifier(null);

  /// 相册的权限
  final ValueNotifier<PermissionState> photoPermissionState =
      ValueNotifier(PermissionState.authorized);

  /// 正在切换路径？（相册）
  final ValueNotifier<bool> switchingPath = ValueNotifier(false);

  /// 当前路径下的图片总数
  int _currentPathTotalItemCount = 0;

  /// 存放所有目录下的第一张缩略图数据
  final List<List<dynamic>> assetPathFirstPhotoThumbMap = [];

  /// 已选的列表
  final ValueNotifier<Set<AssetEntity>> selectedAssetList = ValueNotifier({});

  /// 禁止点击事件
  final ValueNotifier<bool> disableClickListener = ValueNotifier(false);

  /// 默认不展示底部详情按钮
  final ValueNotifier<bool> displayBottomWidget = ValueNotifier(false);

  /// 请求权限中
  var _permissionRequesting = false;

  void onInit() async {
    await Future.delayed(config.pageTransitionDuration);
    await checkPhotoPermission();
    // 已选择的资源
    for (var element in config.selectedAssets) {
      selectAsset(element);
    }
    // 开始获取数据
    if (isPhotoPermissionGrant) {
      await getAssetsPathList();
      await getPathAssetsList();
    }
  }

  void dispose() {
    pathNotifier.dispose();
    assetEntityList.dispose();
    photoPermissionState.dispose();
    switchingPath.dispose();
    selectedAssetList.dispose();
    disableClickListener.dispose();
    displayBottomWidget.dispose();
  }

  /// 是否授权了相册的权限
  bool get isPhotoPermissionGrant =>
      photoPermissionState.value == PermissionState.authorized ||
      photoPermissionState.value == PermissionState.limited;

  Future<void> checkPhotoPermission() async {
    _permissionRequesting = true;
    await PhotoManager.setIgnorePermissionCheck(false);
    final state = await PhotoManager.requestPermissionExtend();
    photoPermissionState.value = state;
    _permissionRequesting = false;
  }

  Future<void> getAssetsPathList() async {
    final FilterOptionGroup options = FilterOptionGroup(
      imageOption: const FilterOption(
        needTitle: true,
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      audioOption: const FilterOption(
        needTitle: true,
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
      containsPathModified: true,
    );

    if (config.filterOption != null) {
      options.merge(config.filterOption!);
    }
    final pathList = await PhotoManager.getAssetPathList(
      hasAll: config.hasAll,
      onlyAll: config.onlyAll,
      type: config.requestType,
      filterOption: options,
    );

    // 排序并过滤
    config.getPhotoSortPathDelegate.sort(pathList);

    if (pathList.isNotEmpty) {
      switchAssetPath(pathList.first);
      _cacheFirstThumbFromPathEntity(pathList);
    } else {
      assetEntityList.value = [];
    }
  }

  /// 可以继续加载更多
  bool get hasLoadMore =>
      (assetEntityList.value ?? []).length < _currentPathTotalItemCount;

  Future<void> getPathAssetsList() async {
    if (pathNotifier.value == null) {
      return;
    }
    assetEntityList.value = null;
    final dataList =
        await pathNotifier.value!.getAssetListPaged(0, config.perPageSize);
    assetEntityList.value = dataList;
  }

  /// 照片发生变更事件，包括没权限从设置页面返回，都会回调这个方法
  void onPhotoChangeListener({bool update = true}) async {
    if (_permissionRequesting) return;
    await checkPhotoPermission();
    if (!isPhotoPermissionGrant) return;
    if (pathNotifier.value != null) {
      if (update) {
        await pathNotifier.value!.refreshPathProperties();
      }
    } else {
      await getAssetsPathList();
      await getPathAssetsList();
    }
  }

  /// 当前路径下的图片数量
  int get currentPathAssetsLength => assetEntityList.value?.length ?? 0;

  /// 当前的加载的页面
  int get currentAssetsListPage =>
      (max(1, currentPathAssetsLength) / config.perPageSize).ceil();

  /// 加载更多的照片
  void loadMoreAssetData(int currentIndex, int crossAxisCount) async {
    final loadMore =
        currentIndex == currentPathAssetsLength - crossAxisCount * 4;
    if (loadMore && hasLoadMore) {
      final dataList = await pathNotifier.value!.getAssetListPaged(
        currentAssetsListPage,
        config.perPageSize,
      );
      final oldData = assetEntityList.value ?? [];
      assetEntityList.value = [...oldData, ...dataList];
    }
  }

  /// 循环获取每个目录的第一张图片进行缓存
  void _cacheFirstThumbFromPathEntity(
    List<AssetPathEntity> pathEntity,
  ) async {
    assetPathFirstPhotoThumbMap.clear();
    for (var element in pathEntity) {
      final assetList = await element.getAssetListRange(start: 0, end: 1);
      final asset = await assetList.elementAt(0).thumbData;
      assetPathFirstPhotoThumbMap.add([element, asset]);
    }
  }

  /// 切换相册目录
  void switchAssetPath(AssetPathEntity entity) {
    if (pathNotifier.value?.name == entity.name &&
        pathNotifier.value?.assetCount == entity.assetCount) return;
    pathNotifier.value = entity;
    _currentPathTotalItemCount = entity.assetCount;
    switchingPath.value = false;
    getPathAssetsList();
  }

  /// 选择资源
  void selectAsset(AssetEntity assetEntity) {
    final oldList = selectedAssetList.value;
    if (oldList.contains(assetEntity)) {
      oldList.remove(assetEntity);
      selectedAssetList.value = <AssetEntity>{...oldList};
      // 取消禁止点击
      if (disableClickListener.value) {
        disableClickListener.value = false;
      }
      // 不显示底部详情
      if (selectedAssetList.value.isEmpty) {
        displayBottomWidget.value = false;
      }
    } else {
      // 已经超限制
      if (selectedAssetList.value.length >= config.maxSelectedCount) return;
      selectedAssetList.value = <AssetEntity>{...oldList}..add(assetEntity);
      // 显示底部详情
      if (selectedAssetList.value.length == 1) {
        displayBottomWidget.value = true;
      }
      // 达到最大的上限
      if (selectedAssetList.value.length == config.maxSelectedCount) {
        disableClickListener.value = true;
      }
    }
  }

  /// 是否允许点击预览图片
  bool notAllowPreviewImage(
    AssetEntity assetEntity, {
    bool fromBottomPanel = false,
  }) {
    if (!fromBottomPanel &&
        disableClickListener.value &&
        !selectedAssetList.value.contains(assetEntity)) {
      return true;
    }
    if (!config.canPreview || assetEntity.type != AssetType.image) {
      return true;
    }
    return false;
  }

  /// 单选类型时，点击图片的事件处理
  void singleItemClick(
    BuildContext context,
    AssetEntity assetEntity, {
    Function()? toViewer,
    bool fromPreview = false,
  }) async {
    if (!config.canPreview || fromPreview) {
      var result =
          await config.singleBackFunc?.call(assetEntity, (result) async {
        // 当await外面的result为true时会执行这这里的方法体，此时的result是dynamic类型
        confirm(context, fromPreview: fromPreview, data: result);
      });
      // result == true表示上面的方法体已经处理过了
      if (result == true) {
        return;
      }
      // result == false表示外面有处理，但没结果
      if (result == false) {
        if (fromPreview) {
          Navigator.of(context).pop();
        }
        return;
      }
      // 外面没有处理任何东西
      confirm(context, fromPreview: fromPreview, data: assetEntity);
    } else {
      toViewer?.call();
    }
  }

  /// 多选时的确定
  void confirm(
    BuildContext context, {
    bool fromPreview = false,
    dynamic data,
  }) async {
    if (fromPreview) {
      Navigator.of(context).pop();
      await Future.delayed(const Duration(milliseconds: 200));
    }
    Navigator.of(config.key.currentContext!).pop(data);
  }
}
