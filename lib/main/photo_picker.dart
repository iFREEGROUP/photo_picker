import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_picker/delegates/photo_pick_builder_delegate.dart';
import 'package:photo_picker/widgets/bottom_up_page_transition.dart';
import 'package:photo_picker/widgets/photo_picker.dart';

class PhotoPicker {
  static void pick({
    required BuildContext context,
    Curve pageTransitionCurves = Curves.easeIn,
    Duration pageTransitionDuration = const Duration(milliseconds: 300),
    Color? backgroundColor,
  }) async {
    Navigator.of(context).push(
      BottomUpPageRoute(
        builder: PhotoPickerWidget(
          builderDelegate: DefaultPhotoPickerBuilder(),
        ),
        transitionCurve: pageTransitionCurves,
        transitionDuration: pageTransitionDuration,
        settings: const RouteSettings(name: '/photo_picker/picker'),
      ),
    );
  }
}
