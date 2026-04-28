import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final List<String> _imagePaths = [];
  final TextEditingController _notesController = TextEditingController();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  @override
  void dispose() {
    _notesController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _requestPhotoPermissions() async {
    await [
      Permission.camera,
      if (Platform.isIOS) Permission.photosAddOnly,
    ].request();
  }

  Future<void> _addPhotoFromCamera() async {
    await _requestPhotoPermissions();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CameraScreen()),
    );
    if (result != null) {
      setState(() {
        _imagePaths.add(result.toString());
      });
    }
  }

  Future<void> _addPhotoFromGallery() async {
    final photos = await ImagePicker().pickMultiImage(imageQuality: 85);
    if (photos.isEmpty) return;
    setState(() {
      _imagePaths.addAll(photos.map((photo) => photo.path));
    });
  }

  Future<void> _showAddPhotoOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text(language.takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  _addPhotoFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Upload from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _addPhotoFromGallery();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_signatureController.isNotEmpty) {
      final signature = await _signatureController.toPngBytes();
      if (signature == null || _imagePaths.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(language.needPhotoAndSignature)),
        );
        return;
      }
      Navigator.pop(context, {
        'photoPaths': List<String>.from(_imagePaths),
        'photoPath': _imagePaths.first,
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
              padding: const EdgeInsets.all(16),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _imagePaths.length + 1,
              itemBuilder: (context, index) {
                if (index == _imagePaths.length) {
                  return InkWell(
                    onTap: _showAddPhotoOptions,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined, size: 32),
                    ),
                  );
                }

                final path = _imagePaths[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(path), fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 4,
                      top: 4,
                      child: InkWell(
                        onTap: () {
                          setState(() => _imagePaths.removeAt(index));
                        },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.pleaseSign,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFCF7),
                      border: Border.all(color: Colors.black87, width: 1.6),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Signature(
                        controller: _signatureController,
                        height: 260,
                        backgroundColor: const Color(0xFFFFFCF7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign inside the box above',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
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
      ),
    );
  }
}
