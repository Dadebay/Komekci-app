import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import 'app_icon.dart';

/// Photos are downscaled and re-encoded at 70% JPEG quality before they ever
/// reach the app, so uploads stay small without a separate compression step.
const _pickedImageQuality = 70;
const _pickedImageMaxWidth = 1440.0;

Future<File?> pickCompressedImage(BuildContext context, {bool turkmen = true}) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(width: 42, height: 4, decoration: BoxDecoration(color: line, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          ListTile(
            leading: const AppIcon(Icons.photo_camera_outlined, color: ink, size: 21),
            title: Text(turkmen ? 'Surat düşür' : 'Сделать фото'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: const AppIcon(Icons.image_outlined, color: ink, size: 21),
            title: Text(turkmen ? 'Galereýadan saýla' : 'Выбрать из галереи'),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (source == null) return null;
  final picked = await ImagePicker().pickImage(
    source: source,
    imageQuality: _pickedImageQuality,
    maxWidth: _pickedImageMaxWidth,
  );
  return picked == null ? null : File(picked.path);
}

/// Round avatar with a camera badge, used on profile screens.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({super.key, required this.file, required this.onPicked, this.radius = 44, this.fallback});

  final File? file;
  final ValueChanged<File> onPicked;
  final double radius;
  final ImageProvider? fallback;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final picked = await pickCompressedImage(context);
      if (picked != null) onPicked(picked);
    },
    child: Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: const Color(0xffF1EDE4),
          backgroundImage: file != null ? FileImage(file!) : fallback,
          child: file == null && fallback == null ? AppIcon(Icons.person_outline, color: ink, size: radius * .8) : null,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: gold,
              border: Border.all(color: Colors.white, width: 2.5),
            ),
            child: const AppIcon(Icons.photo_camera_outlined, color: Colors.white, size: 14),
          ),
        ),
      ],
    ),
  );
}

/// Dashed-looking upload box used by the registration and service forms.
class PhotoUploadBox extends StatelessWidget {
  const PhotoUploadBox({
    super.key,
    required this.file,
    required this.onPicked,
    required this.title,
    this.hint,
    this.height = 150,
    this.radius = 18,
  });

  final File? file;
  final ValueChanged<File> onPicked;
  final String title;
  final String? hint;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () async {
      final picked = await pickCompressedImage(context);
      if (picked != null) onPicked(picked);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: height,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xffFAF8F4),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: file == null ? line : gold, width: file == null ? 1 : 1.5),
      ),
      child: file != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.file(file!, fit: BoxFit.cover),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                    child: const AppIcon(Icons.edit_outlined, color: Colors.white, size: 15),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppIcon(Icons.photo_camera_outlined, color: ink, size: 28),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                if (hint != null) ...[
                  const SizedBox(height: 5),
                  Text(hint!, style: const TextStyle(fontSize: 11.5, color: Colors.black45)),
                ],
              ],
            ),
    ),
  );
}
