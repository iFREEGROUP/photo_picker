import 'package:flutter/material.dart';

abstract class PhotoTextDelegate {
  String get confirm;

  /// 请允许应用访问你的相册
  String get noPermissionTip;

  /// 去开启权限
  String get openSetting;

  /// 你只授权了应用访问你的部分资源
  String get permissionLimitedTip;

  /// 修改权限
  String get limitedPermissionAction;

  bool isChinese(BuildContext context) =>
      Localizations.localeOf(context).languageCode == 'zh';
}

class DefaultPhotoTextDelegateImpl extends PhotoTextDelegate {
  DefaultPhotoTextDelegateImpl({required this.context});

  final BuildContext context;

  @override
  String get confirm => isChinese(context) ? '确定' : 'Confirm';

  @override
  String get noPermissionTip =>
      isChinese(context) ? '请允许应用访问你的相册' : 'We need your photo permission';

  @override
  String get openSetting => isChinese(context) ? '去开启权限' : 'Go to Settings';

  @override
  String get permissionLimitedTip => isChinese(context)
      ? '你只授权了应用访问你的部分资源'
      : 'You only access app to select a number of photos.';

  @override
  String get limitedPermissionAction => isChinese(context) ? '修改权限' : 'Manage';
}
