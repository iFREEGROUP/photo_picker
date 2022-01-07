import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_picker/delegates/photo_pick_builder_delegate.dart';

class PhotoPickerWidget extends StatefulWidget {
  const PhotoPickerWidget({
    Key? key,
    required this.builderDelegate,
  }) : super(key: key);

  final PhotoPickBuilderDelegate builderDelegate;

  @override
  State<StatefulWidget> createState() {
    return _PhotoPickerWidgetState();
  }
}

class _PhotoPickerWidgetState extends State<PhotoPickerWidget>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return widget.builderDelegate.build(context);
  }

  @override
  void initState() {
    WidgetsBinding.instance?.addObserver(this);
    PhotoManager.setIgnorePermissionCheck(true);
    PhotoManager.addChangeCallback(_photoChangedListener);
    PhotoManager.startChangeNotify();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    PhotoManager.removeChangeCallback(_photoChangedListener);
    PhotoManager.stopChangeNotify();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      widget.builderDelegate.controller.onPhotoChangeListener();
    }
  }

  /// 相册的图片变化了
  void _photoChangedListener([MethodCall? methodCall]) async {
    widget.builderDelegate.controller.onPhotoChangeListener();
  }
}
