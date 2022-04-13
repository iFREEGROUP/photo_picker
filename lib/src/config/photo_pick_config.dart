import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_picker/photo_picker.dart';

class PhotoPickerConfig {
  PhotoPickerConfig({
    this.backgroundColor = Colors.black,
    this.crossAxisCount = 4,
    this.mainAxisSpacing = 2,
    this.crossAxisSpacing = 2,
    this.perPageSize = 200,
    this.thumbPhotoSize = 200,
    this.maxSelectedCount = 9,
    this.limitedCoverColor,
    this.selectedCoverColor,
    this.requestType = RequestType.image,
    this.hasAll = true,
    this.onlyAll = false,
    this.filterOption,
    this.photoNameDelegate,
    this.photoSortPathDelegate,
    this.photoTextDelegate,
    this.canPreview = true,
    this.pageTransitionCurves = Curves.easeIn,
    this.pageTransitionDuration = const Duration(milliseconds: 300),
    this.onlyShowPreviewBottomPanel = false,
    this.selectedAssets = const [],
    this.singleType = false,
    this.singleBackFunc,
  });

  PhotoNameDelegate? photoNameDelegate;
  SortPathDelegate? photoSortPathDelegate;
  PhotoTextDelegate? photoTextDelegate;

  /// key
  var key = GlobalKey<PhotoPickerWidgetState>();

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
  final Color? limitedCoverColor;

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

  /// 单选模式，没有右上角的圈圈和选择后的覆盖层
  final bool singleType;

  /// 单选模式，选中后是否立马退出页面返回数据(默认)，可选返回false后主动调用backFunc关闭该页面
  final Future<bool> Function(
    AssetEntity item,
    Function(dynamic result) backFunc,
  )? singleBackFunc;

  /// 重命名目录的代理
  PhotoNameDelegate get getPhotoNameDelegate =>
      photoNameDelegate ??= PhotoNameDelegate.defaultPhotoNameDelegate;

  /// 排序目录的代理，可操作删除等
  SortPathDelegate get getPhotoSortPathDelegate =>
      photoSortPathDelegate ??= SortPathDelegate.defaultDelegate;

  /// 所有文案的代理
  PhotoTextDelegate getPhotoTextDelegate(BuildContext context) =>
      photoTextDelegate ??= DefaultPhotoTextDelegateImpl(context: context);

  PhotoPickerConfig copyWith({
    Color? backgroundColor,
    int? crossAxisCount,
    double? mainAxisSpacing,
    double? crossAxisSpacing,
    int? perPageSize,
    int? thumbPhotoSize,
    int? maxSelectedCount,
    Color? limitedCoverColor,
    Color? selectedCoverColor,
    RequestType? requestType,
    bool? hasAll,
    bool? onlyAll,
    FilterOptionGroup? filterOption,
    PhotoNameDelegate? photoNameDelegate,
    SortPathDelegate? photoSortPathDelegate,
    PhotoTextDelegate? photoTextDelegate,
    bool? canPreview,
    Curve? pageTransitionCurves,
    Duration? pageTransitionDuration,
    bool? onlyShowPreviewBottomPanel,
    List<AssetEntity>? selectedAssets,
    bool? singleType,
    Future<bool> Function(
      AssetEntity item,
      Function(dynamic result) backFunc,
    )?
        singleBackFunc,
  }) {
    return PhotoPickerConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      crossAxisCount: crossAxisCount ?? this.crossAxisCount,
      mainAxisSpacing: mainAxisSpacing ?? this.mainAxisSpacing,
      crossAxisSpacing: crossAxisSpacing ?? this.crossAxisSpacing,
      perPageSize: perPageSize ?? this.perPageSize,
      thumbPhotoSize: thumbPhotoSize ?? this.thumbPhotoSize,
      maxSelectedCount: maxSelectedCount ?? this.maxSelectedCount,
      requestType: requestType ?? this.requestType,
      limitedCoverColor: limitedCoverColor ?? this.limitedCoverColor,
      selectedCoverColor: selectedCoverColor ?? this.selectedCoverColor,
      hasAll: hasAll ?? this.hasAll,
      onlyAll: onlyAll ?? this.onlyAll,
      filterOption: filterOption ?? this.filterOption,
      photoNameDelegate: photoNameDelegate ?? this.photoNameDelegate,
      photoSortPathDelegate:
          photoSortPathDelegate ?? this.photoSortPathDelegate,
      photoTextDelegate: photoTextDelegate ?? this.photoTextDelegate,
      canPreview: canPreview ?? this.canPreview,
      pageTransitionCurves: pageTransitionCurves ?? this.pageTransitionCurves,
      pageTransitionDuration:
          pageTransitionDuration ?? this.pageTransitionDuration,
      onlyShowPreviewBottomPanel:
          onlyShowPreviewBottomPanel ?? this.onlyShowPreviewBottomPanel,
      selectedAssets: selectedAssets ?? this.selectedAssets,
      singleType: singleType ?? this.singleType,
      singleBackFunc: singleBackFunc ?? this.singleBackFunc,
    );
  }
}
