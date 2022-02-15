import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_picker/delegates/photo_rename_delegate.dart';
import 'package:photo_picker/delegates/photo_sort_path_delegate.dart';

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
    this.requestType = RequestType.image,
    this.hasAll = true,
    this.onlyAll = false,
    this.filterOption,
    this.photoNameDelegate,
    this.photoSortPathDelegate,
    this.canPreview = true,
    this.pageTransitionCurves = Curves.easeIn,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.onlyShowPreviewBottomPanel = false,
    this.selectedAssets = const [],
  });

  final PhotoNameDelegate? photoNameDelegate;
  final SortPathDelegate? photoSortPathDelegate;

  /// 整个布局的背景颜色
  final Color backgroundColor;

  /// 一行显示多少
  final int crossAxisCount;

  /// 主轴方向的间距
  final double mainAxisSpacing;

  /// 副轴方向的间距
  final double crossAxisSpacing;

  /// 分页加载时每页请求多少长图片
  final int perPageSize;

  /// 显示的缩略图大小
  final int thumbPhotoSize;

  /// 最大可选的数量
  final int maxSelectedCount;

  /// 选择上限后的图片蒙板颜色
  final Color? disableCoverColor;

  /// 选中图片所覆盖的颜色
  final Color? selectedCoverColor;

  /// 请求图片的类型，如图片、视频、音频等
  final RequestType requestType;

  /// 已经选择了的资源
  final List<AssetEntity> selectedAssets;

  /// see [PhotoManager.getAssetPathList]
  final bool hasAll;
  final bool onlyAll;
  final FilterOptionGroup? filterOption;

  /// 是否可以预览
  final bool canPreview;

  final Curve pageTransitionCurves;
  final Duration pageTransitionDuration;

  /// 只显示预览时底部的容器，在主页不显示
  final bool onlyShowPreviewBottomPanel;

  /// 重命名目录的代理
  PhotoNameDelegate get getPhotoNameDelegate =>
      photoNameDelegate ?? PhotoNameDelegate.defaultPhotoNameDelegate;

  /// 排序目录的代理，可操作删除等
  SortPathDelegate get getPhotoSortPathDelegate =>
      photoSortPathDelegate ?? SortPathDelegate.defaultDelegate;
}
