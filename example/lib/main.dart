import 'package:flutter/material.dart';
import 'package:photo_picker/photo_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _MyTestPage(),
    );
  }
}

class _MyTestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyTestState();
  }
}

class _MyTestState extends State<_MyTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: GestureDetector(
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('获取图片'),
          ),
          onTap: () async {
            await PhotoPicker.pick(
              context: context,
              config: PhotoPickerConfig(),
            );

            // PhotoPicker.singlePick(
            //   context: context,
            //   config: PhotoPickerConfig(canPreview: true),
            //   selectedFunc: (assetEntity) async {
            //     debugPrint('我选择了${assetEntity.id}的图片');
            //     await Future.delayed(const Duration(milliseconds: 2000));
            //     debugPrint('倒计时完成');
            //   },
            // );
          },
        ),
      ),
    );
  }
}
