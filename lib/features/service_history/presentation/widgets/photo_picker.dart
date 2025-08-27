import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoSelection {
  final XFile? file;
  final Uint8List? bytes;

  const PhotoSelection({this.file, this.bytes});
}

class PhotoPicker extends StatefulWidget {
  final Uint8List? initialBytes;
  final ValueChanged<PhotoSelection?> onChanged;
  final String buttonLabel;

  const PhotoPicker({
    super.key,
    this.initialBytes,
    required this.onChanged,
    this.buttonLabel = 'Fotoğraf Ekle',
  });

  @override
  State<PhotoPicker> createState() => _PhotoPickerState();
}

class _PhotoPickerState extends State<PhotoPicker> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _bytes = widget.initialBytes;
  }

  Future<void> _selectSourceAndPick() async {
    final source = await showModalBottomSheet<ImageSource?>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Kamera'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Galeri'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 85);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      setState(() {
         _bytes = bytes;
      });
      widget.onChanged(PhotoSelection(file: picked, bytes: bytes));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fotoğraf seçilirken hata: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF23408E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            elevation: 0,
          ),
          onPressed: _selectSourceAndPick,
          icon: const Icon(
            Icons.add_a_photo_outlined,
            color: Colors.white,
          ),
          label: Text(
            widget.buttonLabel,
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        if (_bytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.memory(
              _bytes!,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  const SizedBox(width: 70, height: 70),
            ),
          ),
      ],
    );
  }
}