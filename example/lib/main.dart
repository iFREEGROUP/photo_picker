
import 'package:flutter/material.dart';
import 'package:photo_picker/main/photo_picker.dart';

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
          child: const Text('Running'),
          onTap: () {
            PhotoPicker.pick(context: context);
          },
        ),
      ),
    );
  }
}
