import 'dart:math';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_picker/config/photo_pick_config.dart';
import 'package:photo_picker/controller/photo_picker_controller.dart';
import 'package:photo_picker/provider/photo_asset_image_provider.dart';
import 'package:photo_picker/widgets/photo_viewer.dart';

abstract class PhotoPickBuilderDelegate {
  PhotoPickBuilderDelegate();

  /// 业务控制器
  late final PhotoPickController controller =
      PhotoPickController(config: config)..onInit();

  /// 配置文件
  late final PhotoPickerConfig config;

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
  });

  /// 如果返回值不为空，则主页的底部使用该布局显示，否则使用[buildBottomPanel]显示
  /// 如果主页想不显示底部布局，设置[PhotoPickerConfig.onlyShowPreviewBottomPanel]为true即可
  Widget? buildRootBottomPanel(BuildContext context);

  /// 选择目录列表布局
  Widget buildPathList(BuildContext context, bool switching);

  /// 选择目录列表的子布局
  Widget buildPathListItem(BuildContext context, int index);

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

class DefaultPhotoPickerBuilder extends PhotoPickBuilderDelegate {
  DefaultPhotoPickerBuilder();

  @override
  Widget buildAppbar(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return Container(
      height: kToolbarHeight + statusBarHeight,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: Colors.black, boxShadow: [
        BoxShadow(
          color: const Color(0xFF8E8E93).withOpacity(0.2),
          offset: const Offset(0, 2),
          blurRadius: 5,
        ),
      ]),
      padding: EdgeInsets.only(top: statusBarHeight),
      child: Stack(
        children: [
          buildBack(context),
          Align(child: buildCurrentPath(context)),
        ],
      ),
    );
  }

  @override
  Widget buildBack(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).maybePop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: double.infinity,
        child: const Icon(
          Icons.close,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  @override
  Widget buildBodyList(BuildContext context) {
    return ValueListenableBuilder<List<AssetEntity>?>(
      builder: (BuildContext context, value, Widget? child) {
        if (value == null) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(
                height: 200,
              ),
              CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Colors.white,
                strokeWidth: 2,
              ),
            ],
          );
        }
        return MediaQuery.removePadding(
          removeTop: true,
          removeBottom: true,
          context: context,
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: config.crossAxisCount,
              mainAxisSpacing: config.mainAxisSpacing,
              crossAxisSpacing: config.crossAxisSpacing,
            ),
            itemBuilder: (context, index) {
              controller.loadMoreAssetData(index, config.crossAxisCount);
              final item = value[index];
              return buildListImageItem(context, item);
            },
            itemCount: value.length,
            physics: const BouncingScrollPhysics(),
          ),
        );
      },
      valueListenable: controller.assetEntityList,
    );
  }

  @override
  Widget buildBottomPanel(
    BuildContext context, {
    Function(AssetEntity item)? selectFunc,
  }) {
    return ValueListenableBuilder(
      valueListenable: controller.displayBottomWidget,
      builder: (context, bool display, Widget? child) {
        return AnimatedAlign(
          duration: kThemeAnimationDuration,
          alignment: Alignment.topCenter,
          heightFactor: display ? 1 : 0,
          child: Container(
            color: Colors.black,
            height: 116 + MediaQuery.of(context).padding.bottom,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: controller.selectedAssetList,
                  builder: (context, Set<AssetEntity> value, Widget? child) {
                    return UnconstrainedBox(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop(
                            controller.selectedAssetList.value.toList(),
                          );
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          margin: const EdgeInsets.only(right: 12),
                          decoration: const BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${config.getPhotoTextDelegate(context).confirm}(${value.length}/${config.maxSelectedCount})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder(
                  valueListenable: controller.selectedAssetList,
                  builder: (context, Set<AssetEntity> value, Widget? child) {
                    return buildBottomPanelList(
                      context,
                      value,
                      selectFunc: selectFunc,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildPathList(BuildContext context, bool switching) {
    return AnimatedAlign(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.bottomCenter,
      heightFactor: switching ? 1 : 0,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: switching ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          color: Colors.black,
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 12),
              itemBuilder: (context, index) {
                return buildPathListItem(context, index);
              },
              physics: const BouncingScrollPhysics(),
              itemCount: controller.assetPathFirstPhotoThumbMap.length,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildPathListItem(BuildContext context, int index) {
    final entries = controller.assetPathFirstPhotoThumbMap[index];
    final path = entries[0];
    final data = entries[1];
    return GestureDetector(
      onTap: () {
        controller.switchAssetPath(path);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        width: double.infinity,
        color: Colors.transparent,
        child: Row(
          children: [
            data == null
                ? const SizedBox.shrink()
                : Image.memory(
                    data,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
            const SizedBox(
              width: 16,
            ),
            Flexible(
              child: Text(
                config.getPhotoNameDelegate.rename(context, path.name),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 20 / 14,
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              '${path.assetCount}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8791AA),
                height: 18 / 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildCurrentPath(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.pathNotifier,
      builder: (BuildContext context, AssetPathEntity? value, Widget? child) {
        if (value == null) {
          return const SizedBox.shrink();
        }
        final indicator = buildCurrentPathIndicator(context);
        return GestureDetector(
          onTap: () {
            controller.switchingPath.value = !controller.switchingPath.value;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 100),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    config.getPhotoNameDelegate.rename(context, value.name),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 20 / 14,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (indicator != null) const SizedBox(width: 4),
                indicator ?? const SizedBox.shrink(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildListImageItem(BuildContext context, AssetEntity assetEntity) {
    return GestureDetector(
      onTap: () {
        if (controller.disableClickListener.value &&
            !controller.selectedAssetList.value.contains(assetEntity)) {
          return;
        }
        toViewer(context, assetEntity);
      },
      child: Stack(
        children: [
          Hero(
            tag: assetEntity.id,
            child: Image(
              image: PhotoAssetImageProvider(
                assetEntity,
                isOriginal: false,
                thumbSize: [
                  config.thumbPhotoSize,
                  config.thumbPhotoSize,
                ],
              ),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: buildImageItemSelectedCover(context, assetEntity),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: buildImageItemIndicator(context, assetEntity),
          ),
          Positioned(
            bottom: 0,
            child: buildVideoItemIndicator(context, assetEntity),
          ),
          Positioned.fill(
            child: buildImageItemLimitedCover(context, assetEntity),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildNoPhotoPermission(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          config.getPhotoTextDelegate(context).noPermissionTip,
          style: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            height: 20 / 14,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 24,
        ),
        GestureDetector(
          onTap: () {
            PhotoManager.openSetting();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFF6A00FF),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: Text(
              config.getPhotoTextDelegate(context).openSetting,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                height: 20 / 14,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildStatusBar(
      context: context,
      child: Scaffold(
        backgroundColor: config.backgroundColor,
        body: Stack(
          children: [
            Positioned.fill(
              child: _buildBody(),
              top: MediaQuery.of(context).padding.top + kToolbarHeight,
            ),
            Positioned(
              child: buildAppbar(context),
              left: 0,
              right: 0,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder(
      valueListenable: controller.photoPermissionState,
      builder: (BuildContext context, PermissionState value, Widget? child) {
        if (value == PermissionState.limited ||
            value == PermissionState.authorized) {
          return Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    value == PermissionState.limited
                        ? buildPermissionLimited(context)
                        : const SizedBox.shrink(),
                    Expanded(child: buildBodyList(context)),
                    config.onlyShowPreviewBottomPanel
                        ? const SizedBox.shrink()
                        : buildRootBottomPanel(context) ??
                            buildBottomPanel(context),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: controller.switchingPath,
                builder: (BuildContext context, bool value, Widget? child) {
                  return buildPathList(context, value);
                },
              )
            ],
          );
        }
        return buildNoPhotoPermission(context);
      },
    );
  }

  @override
  Widget buildImageItemIndicator(
      BuildContext context, AssetEntity assetEntity) {
    return GestureDetector(
      onTap: () {
        controller.selectAsset(assetEntity);
      },
      child: Container(
        height: 40,
        width: 40,
        color: Colors.transparent,
        alignment: Alignment.topRight,
        padding: const EdgeInsets.all(4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF001E32).withOpacity(0.1),
                offset: const Offset(1, 1),
                blurRadius: 2,
              ),
            ],
            borderRadius: const BorderRadius.all(
              Radius.circular(100),
            ),
          ),
          child: ValueListenableBuilder(
            valueListenable: controller.selectedAssetList,
            builder: (context, Set<AssetEntity> value, Widget? child) {
              return Icon(
                value.contains(assetEntity)
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 24,
                color: Colors.white,
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget? buildPreviewTopWidget(
    BuildContext context,
    Function backFunc,
    Function selectFunc,
    ValueNotifier<int> currentIndexNotifier,
  ) {
    return null;
  }

  @override
  Widget buildImageItemLimitedCover(BuildContext context, AssetEntity entity) {
    return ValueListenableBuilder(
      builder: (context, bool value, Widget? child) {
        if (!value) {
          return const SizedBox.shrink();
        }
        if (!controller.selectedAssetList.value.contains(entity)) {
          return Container(
            color: config.limitedCoverColor ?? Colors.black.withOpacity(0.8),
          );
        }
        return const SizedBox.shrink();
      },
      valueListenable: controller.disableClickListener,
    );
  }

  @override
  Widget buildImageItemSelectedCover(BuildContext context, AssetEntity entity) {
    return ValueListenableBuilder(
      builder: (context, Set<AssetEntity> value, Widget? child) {
        if (value.contains(entity)) {
          return Container(
            color: config.selectedCoverColor ??
                const Color(0xFF19194B).withOpacity(0.7),
          );
        }
        return const SizedBox.shrink();
      },
      valueListenable: controller.selectedAssetList,
    );
  }

  @override
  Widget buildBottomPanelList(
    BuildContext context,
    Set<AssetEntity> value, {
    Function(AssetEntity item)? selectFunc,
  }) {
    return SizedBox(
      height: 60,
      child: ReorderableListView.builder(
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return buildBottomPanelListItem(
            context,
            value.elementAt(index),
            selectFunc: selectFunc,
          );
        },
        itemCount: value.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        proxyDecorator: (child, int index, Animation<double> animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) {
              final animValue = Curves.easeInOut.transform(animation.value);
              final elevation = lerpDouble(0, 6, animValue)!;
              return Material(
                color: Colors.black38,
                elevation: elevation,
                child: child,
              );
            },
            child: child,
          );
        },
        onReorder: (int oldIndex, int newIndex) {
          if (newIndex > controller.selectedAssetList.value.length) {
            newIndex = controller.selectedAssetList.value.length;
          }
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          var selectedAssets = List.of(controller.selectedAssetList.value);
          var asset = selectedAssets.removeAt(oldIndex);
          selectedAssets.insert(newIndex, asset);
          controller.selectedAssetList.value = selectedAssets.toSet();
        },
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  @override
  Widget buildBottomPanelListItem(
    BuildContext context,
    AssetEntity item, {
    Function(AssetEntity item)? selectFunc,
  }) {
    return Stack(
      key: ValueKey(item),
      children: [
        Align(
          child: GestureDetector(
            onTap: () {
              if (selectFunc != null) {
                selectFunc.call(item);
              } else {
                toViewer(context, item);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: RepaintBoundary(
                child: ExtendedImage(
                  image: PhotoAssetImageProvider(item, isOriginal: false),
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(
          top: -40,
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                controller.selectAsset(item);
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(2, 2),
                    blurRadius: 20,
                  ),
                ]),
                child: const Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget? buildRootBottomPanel(BuildContext context) {
    return null;
  }

  @override
  Widget buildVideoItemIndicator(BuildContext context, AssetEntity entity) {
    if (entity.type == AssetType.video) {
      return Container(
        margin: const EdgeInsets.all(4),
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(color: Colors.black26, offset: Offset(2, 2), blurRadius: 20)
        ]),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_rounded,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 4),
            Text(
              _durationIndicatorBuilder(Duration(seconds: entity.duration)),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: Colors.white,
              ),
            )
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  String _durationIndicatorBuilder(Duration duration) {
    const String separator = ':';
    final String minute = duration.inMinutes.toString().padLeft(2, '0');
    final String second =
        ((duration - Duration(minutes: duration.inMinutes)).inSeconds)
            .toString()
            .padLeft(2, '0');
    return '$minute$separator$second';
  }

  @override
  Widget buildPermissionLimited(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(170, 166, 170, 0.4), // #AAA6AA66 40%
            offset: Offset(1, 1),
            blurRadius: 2,
          )
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              config.getPhotoTextDelegate(context).permissionLimitedTip,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              PhotoManager.openSetting();
            },
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF6A00FF),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                config.getPhotoTextDelegate(context).limitedPermissionAction,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget buildStatusBar(
      {required BuildContext context, required Widget child}) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: child,
    );
  }

  @override
  Widget? buildCurrentPathIndicator(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.switchingPath,
      builder: (BuildContext context, bool value, Widget? child) {
        return Transform.rotate(
          angle: value ? pi / 180 : pi,
          child: const Icon(
            Icons.arrow_drop_up_sharp,
            size: 24,
            color: Colors.white,
          ),
        );
      },
    );
  }

  void toViewer(BuildContext context, AssetEntity item) {
    if (!config.canPreview || item.type != AssetType.image) return;
    PhotoViewer.openViewer(
      context: context,
      controller: controller,
      currentEntity: item,
      topWidget: (backFunc, selectFunc, notifier) => buildPreviewTopWidget(
        context,
        backFunc,
        selectFunc,
        notifier,
      ),
      bottomWidget: (selectFunc) => buildBottomPanel(
        context,
        selectFunc: selectFunc,
      ),
    );
  }
}
