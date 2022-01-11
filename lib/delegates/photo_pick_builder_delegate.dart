import 'dart:math';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_picker/controller/photo_picker_controller.dart';
import 'package:photo_picker/provider/photo_asset_image_provider.dart';
import 'package:photo_picker/util/photo_pick_util.dart';
import 'package:photo_picker/widgets/photo_picker.dart';
import 'package:photo_picker/widgets/photo_viewer.dart';

abstract class PhotoPickBuilderDelegate {
  PhotoPickBuilderDelegate({
    required this.backgroundColor,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.crossAxisSpacing,
    required this.controller,
    required this.key,
  }) {
    controller.onInit();
  }

  final Color backgroundColor;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  final PhotoPickController controller;
  final GlobalKey<PhotoPickerWidgetState> key;

  Widget buildAppbar(BuildContext context);

  Widget buildBack(BuildContext context);

  Widget buildCurrentCategory(BuildContext context);

  Widget buildBodyList(BuildContext context);

  Widget buildNoPhotoPermission(BuildContext context);

  Widget buildListImageItem(BuildContext context, AssetEntity assetEntity);

  Widget buildImageItemIndicator(BuildContext context);

  Widget buildBottomPanel(BuildContext context);

  Widget buildCategoryList(BuildContext context, bool switching);

  Widget buildCategoryListItem(BuildContext context, int index);

  Widget build(BuildContext context);

  Widget? buildViewerTopWidget(BuildContext context, Function backFunc);
}

class DefaultPhotoPickerBuilder extends PhotoPickBuilderDelegate {
  DefaultPhotoPickerBuilder({
    Color backgroundColor = Colors.black,
    int crossAxisCount = 4,
    double mainAxisSpacing = 2,
    double crossAxisSpacing = 2,
    int perPageSize = 200,
    PhotoPickController? controller,
    GlobalKey<PhotoPickerWidgetState>? key,
  }) : super(
          backgroundColor: backgroundColor,
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          controller: controller ?? PhotoPickController(),
          key: key ?? GlobalKey(),
        );

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
          Align(child: buildCurrentCategory(context)),
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
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
            ),
            itemBuilder: (context, index) {
              controller.loadMoreAssetData(index, crossAxisCount);
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
  Widget buildBottomPanel(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Spacer(),
          TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.resolveWith(
                (states) => const Color(0xFF6A00FF),
              ),
            ),
            onPressed: () {},
            child: const Text(
              '确认',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                height: 18 / 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget buildCategoryList(BuildContext context, bool switching) {
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
                return buildCategoryListItem(context, index);
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
  Widget buildCategoryListItem(BuildContext context, int index) {
    final path = controller.assetPathFirstPhotoThumbMap.keys.toList()[index];
    final data = controller.assetPathFirstPhotoThumbMap[path]!;
    return GestureDetector(
      onTap: () {
        controller.switchAssetPath(path);
        controller.switchingPath.value = false;
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
        width: double.infinity,
        color: Colors.transparent,
        child: Row(
          children: [
            Image(
              image: PhotoAssetImageProvider(
                data,
                isOriginal: false,
                thumbSize: [
                  controller.thumbPhotoSize,
                  controller.thumbPhotoSize,
                ],
              ),
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              width: 16,
            ),
            Text(
              PhotoPickerUtil.photoNameDelegate.rename(context, path.name),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 20 / 14,
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
  Widget buildCurrentCategory(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller.pathNotifier,
      builder: (BuildContext context, AssetPathEntity? value, Widget? child) {
        if (value == null) {
          return const SizedBox.shrink();
        }
        return GestureDetector(
          onTap: () {
            controller.switchingPath.value = !controller.switchingPath.value;
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                PhotoPickerUtil.photoNameDelegate.rename(context, value.name),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  height: 20 / 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(
                width: 4,
              ),
              ValueListenableBuilder(
                valueListenable: controller.switchingPath,
                builder: (BuildContext context, bool value, Widget? child) {
                  return AnimatedRotation(
                    alignment: Alignment.center,
                    duration: const Duration(milliseconds: 200),
                    turns: value ? 0 : 0.5,
                    child: const Icon(
                      Icons.arrow_drop_up_sharp,
                      size: 24,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget buildListImageItem(BuildContext context, AssetEntity assetEntity) {
    return GestureDetector(
      onTap: () {
        PhotoViewer.openViewer(
          context: context,
          controller: controller,
          currentEntity: assetEntity,
          currentSelectedChangedListener: (index) {
            key.currentState?.updateView();
          },
          topWidget: (func) => buildViewerTopWidget(context, func),
          bottomWidget: buildBottomPanel(context),
        );
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
                  controller.thumbPhotoSize,
                  controller.thumbPhotoSize,
                ],
              ),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: ValueListenableBuilder(
              builder: (BuildContext context, Set<AssetEntity> value,
                  Widget? child) {
                if (value.contains(assetEntity)) {
                  return Container(
                    color: const Color(0xFF19194B).withOpacity(0.7),
                  );
                }
                return const SizedBox.shrink();
              },
              valueListenable: controller.selectedAssetList,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
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
                    builder: (BuildContext context, Set<AssetEntity> value,
                        Widget? child) {
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
            ),
          ),
        ],
      ),
    );
    ;
  }

  @override
  Widget buildNoPhotoPermission(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '请允许EXPING使用你的相册权限',
          style: TextStyle(
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
            child: const Text(
              '去开启权限',
              style: TextStyle(
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
    return Scaffold(
      backgroundColor: backgroundColor,
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
                    Expanded(child: buildBodyList(context)),
                    buildBottomPanel(context),
                  ],
                ),
              ),
              ValueListenableBuilder(
                valueListenable: controller.switchingPath,
                builder: (BuildContext context, bool value, Widget? child) {
                  return buildCategoryList(context, value);
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
  Widget buildImageItemIndicator(BuildContext context) {
    return const SizedBox.shrink();
  }

  @override
  Widget? buildViewerTopWidget(BuildContext context, Function backFunc) {
    return null;
  }
}
