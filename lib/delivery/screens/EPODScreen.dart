import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:signature/signature.dart';
import 'CameraScreen.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../main.dart';

class EPODScreen extends StatefulWidget {
  const EPODScreen({Key? key}) : super(key: key);

  @override
  State<EPODScreen> createState() => _EPODScreenState();
}

class _EPODScreenState extends State<EPODScreen> {
  String? imagePath;
  final TextEditingController _notesController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  int step = 1; // 1: Take photo, 2: Sign

  @override
  void dispose() {
    _notesController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    // iOS: 先请求权限，避免直接崩溃
    await [
      Permission.camera,
      // iOS 11+ 保存到相册需要 add-only 权限；permission_handler 11 起提供 photosAddOnly
      if (Platform.isIOS) Permission.photosAddOnly,
    ].request();

    // if (!statuses[Permission.camera]!.isGranted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('相机权限被拒绝，请到系统设置中开启')),
    //   );
    //   openAppSettings();
    //   return;
    // }
    // if (Platform.isIOS &&
    //     !(statuses[Permission.photosAddOnly]?.isGranted ?? true)) {
    //   // 如果要保存到相册，最好确保这个权限
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('相册写入权限被拒绝，请到系统设置中开启')),
    //   );
    //   openAppSettings();
    //   return;
    // }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
    if (result != null) {
      setState(() {
        imagePath = result;
        step = 2;
      });
    }
  }

  Future<void> _submit() async {
    if (_signatureController.isNotEmpty) {
      final signature = await _signatureController.toPngBytes();
      if (signature == null || imagePath == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(language.needPhotoAndSignature)),
        );
        return;
      }
      Navigator.pop(context, {
        'photoPath': imagePath,
        'signature': signature, // Uint8List
        'notes': _notesController.text.trim(),
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(language.pleaseSignFirst)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(language.epodTitle)),
      body: step == 1
          ? Center(
              child: ElevatedButton(
                onPressed: _takePhoto,
                child: Text(language.takePhoto),
              ),
            )
          : Column(
              children: [
                if (imagePath != null)
                  Image.file(
                    File(imagePath!),
                    height: 200,
                  ),
                const SizedBox(height: 16),
                Text(language.pleaseSign),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  child: Signature(
                    controller: _signatureController,
                    height: 200,
                    backgroundColor: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => _signatureController.clear(),
                      child: Text(language.reSign),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text(language.done),
                    ),
                  ],
                ).paddingAll(16),
              ],
            ),
    );
  }
}
