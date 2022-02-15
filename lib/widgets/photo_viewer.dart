import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_picker/controller/photo_picker_controller.dart';
import 'package:photo_picker/provider/photo_asset_image_provider.dart';

class PhotoViewer extends StatefulWidget {
  const PhotoViewer({
    Key? key,
    required this.currentEntity,
    required this.controller,
    this.topWidget,
    this.bottomWidget,
    required this.backgroundColor,
    this.currentSelectedChangedListener,
  }) : super(key: key);

  final AssetEntity currentEntity;
  final PhotoPickController controller;
  final Widget? Function(
    Function() clickBackListener,
    Function() clickSelectListener,
    ValueNotifier<int> currentIndexNotifier,
  )? topWidget;
  final Widget? Function(Function(AssetEntity item) selectFunc)? bottomWidget;
  final Color backgroundColor;
  final Function(int index)? currentSelectedChangedListener;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewState();
  }

  static void openViewer({
    required BuildContext context,
    required PhotoPickController controller,
    required AssetEntity currentEntity,
    Widget? Function(
      Function() clickBackListener,
      Function() clickSelectListener,
      ValueNotifier<int> currentIndexNotifier,
    )?
        topWidget,
    Widget? Function(Function(AssetEntity item) selectFunc)? bottomWidget,
    Color? backgroundColor,
    Function(int index)? currentSelectedChangedListener,
  }) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return PhotoViewer(
            currentEntity: currentEntity,
            controller: controller,
            topWidget: topWidget,
            bottomWidget: bottomWidget,
            backgroundColor: backgroundColor ?? Colors.black,
            currentSelectedChangedListener: currentSelectedChangedListener,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        opaque: false,
      ),
    );
  }
}

class _PhotoViewState extends State<PhotoViewer>
    with SingleTickerProviderStateMixin {
  /// 是否显示上下菜单
  ValueNotifier<bool> showMenu = ValueNotifier(false);

  /// 是否手动控制是否显示上下菜单
  var _manual = false;

  /// 滑动的页面key
  final slidePageKey = GlobalKey<ExtendedImageSlidePageState>();

  /// controller
  late final ExtendedPageController pageController = ExtendedPageController(
    initialPage: currentIndex.value,
  );

  // 双击放大
  late final _doubleClickAnimationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  );

  late Animation<double> _doubleClickAnimation;
  late final _doubleClickCurvesAnimation = CurvedAnimation(
    parent: _doubleClickAnimationController,
    curve: Curves.easeInOut,
  );
  Function()? _doubleClickListener;

  /// 当前的选中的位置
  late ValueNotifier<int> currentIndex = ValueNotifier(
    widget.controller.assetEntityList.value!.indexOf(widget.currentEntity),
  );

  @override
  void dispose() {
    if (_doubleClickListener != null) {
      _doubleClickAnimation.removeListener(_doubleClickListener!);
    }
    _doubleClickAnimationController
      ..stop()
      ..dispose();
    PhotoManager.clearFileCache();
    currentIndex.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300)).then(
      (value) => showMenu.value = true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        slidePageKey.currentState?.popPage();
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildSlideImages(),
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              child: _buildTopWidget(context, widget.topWidget),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomWidget(context, widget.bottomWidget),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopWidget(
    BuildContext context,
    Widget? Function(
      Function() clickBackListener,
      Function() selectedListener,
      ValueNotifier<int> currentIndexNotifier,
    )?
        topWidget,
  ) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return ValueListenableBuilder(
      valueListenable: showMenu,
      builder: (BuildContext context, bool value, Widget? child) {
        return AnimatedSlide(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: child!,
          offset: value ? Offset.zero : const Offset(0, -1),
        );
      },
      child: topWidget?.call(
            () {
              slidePageKey.currentState?.popPage();
              _jump2OriginPosition();
              Navigator.of(context).maybePop();
            },
            () {
              widget.controller.selectAsset(currentEntity);
            },
            currentIndex,
          ) ??
          Container(
            height: kToolbarHeight + statusBarHeight,
            color: Colors.black,
            padding: EdgeInsets.only(top: statusBarHeight),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    slidePageKey.currentState?.popPage();
                    _jump2OriginPosition();
                    Navigator.of(context).maybePop();
                  },
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Icon(
                      Icons.arrow_back_ios_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    widget.controller.selectAsset(currentEntity);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ValueListenableBuilder(
                      valueListenable: widget.controller.selectedAssetList,
                      builder: (context, _, child) {
                        return ValueListenableBuilder(
                          valueListenable: currentIndex,
                          builder: (context, _, child) {
                            if (widget.controller.selectedAssetList.value
                                .contains(currentEntity)) {
                              return const Icon(
                                Icons.check_circle_rounded,
                                size: 24,
                                color: Colors.white,
                              );
                            }
                            return const Icon(
                              Icons.radio_button_unchecked,
                              size: 24,
                              color: Colors.white,
                            );
                          },
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
    );
  }

  Widget _buildBottomWidget(
    BuildContext context,
    Widget? Function(Function(AssetEntity entity) selectFunc)? child,
  ) {
    return ValueListenableBuilder(
      valueListenable: showMenu,
      builder: (BuildContext context, bool value, Widget? child) {
        return AnimatedSlide(
          offset: value ? Offset.zero : const Offset(0, 1),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: child ?? const SizedBox.shrink(),
        );
      },
      child: child?.call((item) {
        final dataList = widget.controller.assetEntityList.value!;
        final index = dataList.indexOf(item);
        if (index == -1 || index >= dataList.length) {
          return;
        }
        var animate = (index - currentIndex.value).abs() < 5;
        if (animate) {
          pageController.animateToPage(
            index,
            duration: kThemeAnimationDuration,
            curve: Curves.easeIn,
          );
        } else {
          pageController.jumpToPage(index);
        }
      }),
    );
  }

  AssetEntity get currentEntity =>
      widget.controller.assetEntityList.value![currentIndex.value];

  Widget _buildSlideImages() {
    return ExtendedImageSlidePage(
      resetPageDuration: kThemeAnimationDuration,
      slidePageBackgroundHandler: (offset, size) {
        final opacity = offset.dy / (size.height / 2.0);
        final result = min(1.0, max(1.0 - opacity, 0.0));
        return widget.backgroundColor.withOpacity(result);
      },
      slideScaleHandler: (offset, {ExtendedImageSlidePageState? state}) {
        final pageSize = state!.pageSize;
        final scale =
            offset.dy / Offset(pageSize.width, pageSize.height).distance;
        return max(1.0 - scale, 0.8);
      },
      slideEndHandler: slideEndHandler,
      onSlidingPage: (state) {
        if (!_manual) {
          showMenu.value = state.offset.dy == 0;
        }
      },
      slideAxis: SlideAxis.vertical,
      key: slidePageKey,
      child: ExtendedImageGesturePageView.builder(
        itemBuilder: (context, index) {
          return _buildItemWidget(index);
        },
        physics: const BouncingScrollPhysics(),
        itemCount: widget.controller.pathNotifier.value!.assetCount,
        controller: pageController,
        onPageChanged: (index) {
          currentIndex.value = index;
          widget.currentSelectedChangedListener?.call(index);
        },
      ),
    );
  }

  Widget _buildItemWidget(int index) {
    final item = widget.controller.assetEntityList.value![index];
    return Hero(
      tag: item.id,
      child: _buildImageWidget(item),
      flightShuttleBuilder: (BuildContext flightContext,
          Animation<double> animation,
          HeroFlightDirection flightDirection,
          BuildContext fromHeroContext,
          BuildContext toHeroContext) {
        final hero = flightDirection == HeroFlightDirection.pop
            ? Hero(
                tag: item.id,
                child: ClipRect(
                  clipper: _PhotoCustomClip(),
                  child: ExtendedImage(
                    image: PhotoAssetImageProvider(item, isOriginal: false),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : (toHeroContext.widget) as Hero;
        final offsetTween = Tween<Offset>(
          begin: Offset.zero,
          end: slidePageKey.currentState?.offset,
        );
        final currentScale = slidePageKey.currentState?.scale;
        final scaleTween = Tween<double>(
          begin: 1,
          end: currentScale,
        );
        return AnimatedBuilder(
          animation: animation,
          builder: (BuildContext context, Widget? child) {
            return Transform.translate(
              offset: offsetTween.evaluate(animation),
              child: Transform.scale(
                scale: scaleTween.evaluate(animation),
                child: hero.child,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildImageWidget(AssetEntity assetEntity) {
    return GestureDetector(
      onTap: () {
        _manual = showMenu.value;
        showMenu.value = !showMenu.value;
      },
      child: ExtendedImage(
        image: PhotoAssetImageProvider(assetEntity),
        width: double.infinity,
        fit: BoxFit.contain,
        enableSlideOutPage: true,
        mode: ExtendedImageMode.gesture,
        initGestureConfigHandler: (ExtendedImageState state) {
          return GestureConfig(
            inPageView: true,
            initialScale: 1,
            maxScale: 3,
            animationMaxScale: 5,
            initialAlignment: InitialAlignment.center,
          );
        },
        loadStateChanged: (state) {
          if (state.extendedImageLoadState == LoadState.loading) {
            return const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.transparent,
                color: Colors.white,
                strokeWidth: 2,
              ),
            );
          }
        },
        // extendedImageGestureKey: gestureKeyList[index],
        onDoubleTap: (state) {
          final pointerDownPosition = state.pointerDownPosition;
          final begin = state.gestureDetails!.totalScale ?? 1.0;
          final maxScale = state.imageGestureConfig?.maxScale ?? 3.0;
          var target = begin;
          if (begin < maxScale) {
            target = maxScale;
          } else {
            target = 1;
          }
          if (_doubleClickListener != null) {
            _doubleClickAnimation.removeListener(_doubleClickListener!);
          }
          _doubleClickAnimationController
            ..stop()
            ..reset();
          _doubleClickListener = () {
            state.handleDoubleTap(
              scale: _doubleClickAnimation.value,
              doubleTapPosition: pointerDownPosition,
            );
          };
          _doubleClickAnimation = Tween(begin: begin, end: target)
              .animate(_doubleClickCurvesAnimation)
            ..addListener(_doubleClickListener!);
          _doubleClickAnimationController.forward();
        },
      ),
    );
  }

  bool slideEndHandler(
    Offset offset, {
    ExtendedImageSlidePageState? state,
    ScaleEndDetails? details,
  }) {
    final pageSize = state!.pageSize;
    final result = offset.dy
        .greaterThan(Offset(pageSize.width, pageSize.height).distance / 6);
    if (result) {
      _jump2OriginPosition();
    }
    return result;
  }

  void _jump2OriginPosition() {
    if (currentEntity != widget.currentEntity) {
      pageController.jumpToPage(
        widget.controller.assetEntityList.value!.indexOf(widget.currentEntity),
      );
    }
  }
}

class _PhotoCustomClip extends CustomClipper<Rect> {
  @override
  bool shouldReclip(covariant CustomClipper<dynamic> oldClipper) {
    return false;
  }

  @override
  Rect getClip(Size size) {
    final target = min(size.width, size.height);
    return Rect.fromLTWH(
      (target - size.width).abs() / 2,
      (target - size.height).abs() / 2,
      target,
      target,
    );
  }
}
