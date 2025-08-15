import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mighty_delivery/extensions/extension_util/widget_extensions.dart';
import 'package:signature/signature.dart';
import 'CameraScreen.dart';
import 'package:permission_handler/permission_handler.dart';

class EPODScreen extends StatefulWidget {
  const EPODScreen({Key? key}) : super(key: key);

  @override
  State<EPODScreen> createState() => _EPODScreenState();
}

class _EPODScreenState extends State<EPODScreen> {
  String? imagePath;
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  int step = 1; // 1: 拍照, 2: 签名

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    // iOS: 先请求权限，避免直接崩溃
    final statuses = await [
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
      Navigator.pop(context, {
        'photoPath': imagePath,
        'signature': signature, // Uint8List
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先签名')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('电子签收（EPOD）')),
      body: step == 1
          ? Center(
              child: ElevatedButton(
                onPressed: _takePhoto,
                child: const Text('拍照'),
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
                const Text('请签名：'),
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
                      child: const Text('重签'),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text('完成'),
                    ),
                  ],
                ).paddingAll(16),
              ],
            ),
    );
  }
}
