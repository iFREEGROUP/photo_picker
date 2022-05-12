# photo_picker

一款可以完全自定义UI的图片资源选择器，相册10万+照片也能快速稳定加载。

## 特点
- 基于[`photo_manager`](https://pub.flutter-io.cn/packages/photo_manager "photo_manager")实现资源相关功能，
- 使用[`extended_image`](https://pub.flutter-io.cn/packages/extended_image "extended_image")来实现图片加载动画，
- [`keframe`](https://pub.flutter-io.cn/packages/keframe "keframe")实现分帧加载提高性能的图片资源选择器。

## 注意（来自photo_manager）
受支持的最低版本 **Android 16**, **iOS 9.0**, **macOS 10.15**。

**Android:**
1. 如果您的 **compileSdkVersion** 高于 29，则必须将 **android:requestLegacyExternalStorage="true"** 添加到您的 AndroidManifest.xml 以获取资源：
```java
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <application
      	...
        android:icon="@mipmap/ic_launcher"
        android:requestLegacyExternalStorage="true">
    </application>
</manifest>
```

2. 如果你发现一些 Glide 出现的警告日志，这意味着主项目需要一个 AppGlideModule 的实现。有关实现，请参阅[Glide API](https://bumptech.github.io/glide/doc/generatedapi.html "Glide API")。

**iOS：**
在 ios/Runner/Info.plist 中定义 NSPhotoLibraryUsageDescription 键值：
```objective-c
<key>NSPhotoLibraryUsageDescription</key>
<string>In order to access your photo library</string>
```

更多的注意事项请查阅[`photo_manager`](https://pub.flutter-io.cn/packages/photo_manager "photo_manager")

## 开始使用
1. 将 **photo_picker** 添加到 **pubspec.yaml**
```dart
dependencies:
    	photo_picker:
        	git:
          		url: https://github.com/iFREEGROUP/photo_picker.git
```

2. 在你的代码中导入：
```dart
import 'package:photo_picker/photo_picker.dart';
```

3. 使用方法

如果只是选择单张：
```dart
final res = await PhotoPicker.singlePick(context: context);
```

当然可以用通用的方法：
```dart
await PhotoPicker.pick(
    context: context,
    config: PhotoPickerConfig(singleType: true),
);
```

如果想自定义你的UI风格：
```dart
await PhotoPicker.pick(
      context: context,
      builderDelegate: CustomPhotoPickerBuildDelegate()
    );
```

## PhotoPickerConfig 参数说明

| 参数名  | 类型   | 说明  | 默认值   |
| ------------ | ------------ | ------------ | ------------ |
| backgroundColor  |  Color |  背景颜色 |  Colors.black |
|  crossAxisCount |  int | 一行显示多少张图片  |  4 |
|mainAxisSpacing | double | 主轴方向的间距 |2.0 |
|crossAxisSpacing | double | 副轴方向的间距 |2.0 |
|perPageSize | int | 分页加载时每页请求多少长图片| 200|
|thumbPhotoSize|int |显示的缩略图大小|200|
|maxSelectedCount|int|最大可选的数量|9|
|limitedCoverColor|Color?|选择上限后的图片蒙板颜色|Colors.black.withOpacity(0.8)|
|selectedCoverColor|Color?|选中图片所覆盖的颜色|Color(0xFF19194B).withOpacity(0.7)|
|requestType|RequestType|请求图片的类型，如图片、视频、音频等|目前只能是图片|
|selectedAssets|List<AssetEntity>|已经选择了的资源|[]|
|hasAll|bool|是否包含所有图片|true|
|onlyAll|bool|只显示所有图片？不显示目录分类|false|
|filterOption|FilterOptionGroup?|资源筛选|null|
|canPreview|bool|是否可以预览图片|true|
|pageTransitionCurves|Curve|打开选择器时的过渡效果|Curves.easeIn|
|pageTransitionDuration|Duration|打开选择器时的时长|const Duration(milliseconds: 300)|
|onlyShowPreviewBottomPanel|bool|只显示预览时底部的容器，在主页不显示|false|
|singleType|bool|单选模式,没有右上角的圈圈和选择后的覆盖层|false|


## 自定义布局

- 只是需要修改某些部分的UI，直接继承 **` DefaultPhotoPickerBuilder `**，并重写对应方法即可。
- 如果只需要逻辑部分，UI可以完全自定义，可参考**` DefaultPhotoPickerBuilder `**重写所有方法即可。
```dart
abstract class PhotoPickBuilderDelegate {
  PhotoPickBuilderDelegate();

  /// 标题栏整个布局
  Widget buildAppbar(BuildContext context);

  /// 返回按钮
  Widget buildBack(BuildContext context);

  /// 顶部当前的目录
  Widget buildCurrentPath(BuildContext context);

  /// 顶部当前目录的指示器
  Widget? buildCurrentPathIndicator(BuildContext context);

  /// 中间内容的列表布局
  Widget buildBodyList(BuildContext context);

  /// 没有权限时的布局
  Widget buildNoPhotoPermission(BuildContext context);

  /// 列表图片的子布局
  Widget buildListImageItem(BuildContext context, AssetEntity assetEntity);

  /// 单选模式的子布局
  Widget buildListImageSingleItem(BuildContext context, AssetEntity item);

  /// 列表图片右上角的指示器
  Widget buildImageItemIndicator(BuildContext context, AssetEntity assetEntity);

  /// 当选择图片数量等于[PhotoPickerConfig.maxSelectedCount]时，剩余的图片会覆盖一层颜色
  Widget buildImageItemLimitedCover(BuildContext context, AssetEntity entity);

  /// 当选中图片后，会覆盖一层颜色
  Widget buildImageItemSelectedCover(BuildContext context, AssetEntity entity);

  Widget buildVideoItemIndicator(BuildContext context, AssetEntity entity);

  /// 底部布局，可用于显示所选的图片
  Widget buildBottomPanel(
    BuildContext context, {
    Function(AssetEntity item)? selectFunc,
    Function()? cancelAnimateFunc,
  });

  /// 如果返回值不为空，则主页的底部使用该布局显示，否则使用[buildBottomPanel]显示
  /// 如果主页想不显示底部布局，设置[PhotoPickerConfig.onlyShowPreviewBottomPanel]为true即可
  Widget? buildRootBottomPanel(BuildContext context);

  /// 选择目录列表布局
  Widget buildPathList(BuildContext context, bool switching);

  /// 选择目录列表的子布局
  Widget buildPathListItem(BuildContext context, int index);

  /// 选择目录列表页面的权限提示
  Widget buildPathListPermissionLimited(BuildContext context);

  /// 你懂的，入口
  Widget build(BuildContext context);

  /// 状态栏
  Widget buildStatusBar({required BuildContext context, required Widget child});

  /// 查看图片顶部的布局
  Widget? buildPreviewTopWidget(
    BuildContext context,
    Function backFunc,
    Function selectFunc,
    ValueNotifier<int> currentIndexNotifier,
  );

  /// 底部所选图片列表
  Widget buildBottomPanelList(
    BuildContext context,
    Set<AssetEntity> value, {
    Function(AssetEntity item)? selectFunc,
  });

  /// 底部所选图片列表子布局
  Widget buildBottomPanelListItem(
    BuildContext context,
    AssetEntity item, {
    Function(AssetEntity item)? selectFunc,
  });

  /// 只允许访问部分相片权限提示，内嵌在body中的
  Widget buildPermissionLimited(BuildContext context);
}
```

## 致谢
感谢[wechat_assets_picker](https://pub.flutter-io.cn/packages/wechat_assets_picker "wechat_assets_picker")提供参考。












