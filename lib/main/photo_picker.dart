import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_picker/config/photo_pick_config.dart';
import 'package:photo_picker/delegates/photo_pick_builder_delegate.dart';
import 'package:photo_picker/widgets/bottom_up_page_transition.dart';
import 'package:photo_picker/widgets/photo_picker.dart';

class PhotoPicker {
  static void pick({
    required BuildContext context,
    PhotoPickerConfig? config,
  }) async {
    config ??= PhotoPickerConfig(requestType: RequestType.image);
    Navigator.of(context).push(
      BottomUpPageRoute(
        builder: PhotoPickerWidget(
          builderDelegate: DefaultPhotoPickerBuilder(config: config),
        ),
        transitionCurve: config.pageTransitionCurves,
        transitionDuration: config.pageTransitionDuration,
        settings: const RouteSettings(name: '/photo_picker/picker'),
      ),
    );
  }
}
