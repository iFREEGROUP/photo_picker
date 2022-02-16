import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_picker/config/photo_pick_config.dart';
import 'package:photo_picker/delegates/photo_pick_builder_delegate.dart';
import 'package:photo_picker/widgets/bottom_up_page_transition.dart';
import 'package:photo_picker/widgets/photo_picker.dart';

class PhotoPicker {
  static Future<List<AssetEntity>?> pick({
    required BuildContext context,
    PhotoPickerConfig? config,
    PhotoPickBuilderDelegate? builderDelegate,
  }) async {
    config ??= PhotoPickerConfig(
      requestType: RequestType.image,
    );
    builderDelegate ??= DefaultPhotoPickerBuilder();
    if (config.requestType != RequestType.image) {
      throw Exception('目前只支持选择图片，后续开放其他格式的选项');
    }
    return Navigator.of(context).push(
      BottomUpPageRoute(
        builder: PhotoPickerWidget(
          builderDelegate: builderDelegate,
          config: config,
        ),
        transitionCurve: config.pageTransitionCurves,
        transitionDuration: config.pageTransitionDuration,
        settings: const RouteSettings(name: '/photo_picker/picker'),
      ),
    );
  }

  /// 这里返回dynamic,类型取决于[selectedFunc]的结果，如果为null，则返回AssetEntity
  static Future<dynamic> singlePick({
    required BuildContext context,
    PhotoPickerConfig? config,
    PhotoPickBuilderDelegate? builderDelegate,
    dynamic Function(AssetEntity assetEntity)? selectedFunc,
  }) {
    config ??= PhotoPickerConfig(
      requestType: RequestType.image,
    );
    config = config.copyWith(
      singleType: true,
      singleBackFunc: selectedFunc == null
          ? null
          : (assetEntity, backFunc) async {
              final result = await selectedFunc.call(assetEntity);
              if (result != null) {
                backFunc.call(result);
              }
              return result != null;
            },
    );
    builderDelegate ??= DefaultPhotoPickerBuilder();
    if (config.requestType != RequestType.image) {
      throw Exception('目前只支持选择图片，后续开放其他格式的选项');
    }
    return Navigator.of(context).push(
      BottomUpPageRoute(
        builder: PhotoPickerWidget(
          builderDelegate: builderDelegate,
          config: config,
        ),
        transitionCurve: config.pageTransitionCurves,
        transitionDuration: config.pageTransitionDuration,
        settings: const RouteSettings(name: '/photo_picker/picker'),
      ),
    );
  }
}
