import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/localization/language_provider.dart';
import '../../core/theme/app_theme_tokens.dart';
import 'app_icon.dart';

/// Photos are downscaled and re-encoded at 70% JPEG quality before they ever
/// reach the app, so uploads stay small without a separate compression step.
const _pickedImageQuality = 70;
const _pickedImageMaxWidth = 1440.0;

Future<File?> pickCompressedImage(
  BuildContext context, {
  AppLanguage language = AppLanguage.tk,
}) async {
  final tokens = context.appTokens;
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: tokens.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: tokens.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),
          ListTile(
            leading: AppIcon(
              Icons.photo_camera_outlined,
              color: tokens.textPrimary,
              size: 21,
            ),
            title: Text(
              pickTr(
                language,
                tk: 'Surat düşür',
                ru: 'Сделать фото',
                en: 'Take a photo',
              ),
            ),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: AppIcon(
              Icons.image_outlined,
              color: tokens.textPrimary,
              size: 21,
            ),
            title: Text(
              pickTr(
                language,
                tk: 'Galereýadan saýla',
                ru: 'Выбрать из галереи',
                en: 'Choose from gallery',
              ),
            ),
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

/// A just-picked local file wins over the photo stored on the server.
ImageProvider? profileImage({File? file, String? url}) {
  if (file != null) return FileImage(file);
  if (url != null) return NetworkImage(url);
  return null;
}

/// Round avatar with a camera badge, used on profile screens.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.file,
    required this.onPicked,
    this.radius = 44,
    this.fallback,
    this.networkUrl,
  });

  final File? file;
  final ValueChanged<File> onPicked;
  final double radius;
  final ImageProvider? fallback;

  /// Photo already stored on the server; shown until a new [file] is picked.
  final String? networkUrl;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: () async {
        final picked = await pickCompressedImage(context);
        if (picked != null) onPicked(picked);
      },
      child: Stack(
        children: [
          CircleAvatar(
            radius: radius,
            backgroundColor: const Color(0xffF1EDE4),
            backgroundImage: file != null
                ? FileImage(file!)
                : (networkUrl != null ? NetworkImage(networkUrl!) : fallback),
            child: file == null && fallback == null && networkUrl == null
                ? AppIcon(
                    Icons.person_outline,
                    color: tokens.textPrimary,
                    size: radius * .8,
                  )
                : null,
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
                color: tokens.accent,
                border: Border.all(color: tokens.surface, width: 2.5),
              ),
              child: AppIcon(
                Icons.photo_camera_outlined,
                color: tokens.accentOn,
                size: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
    this.networkUrl,
  });

  final File? file;
  final ValueChanged<File> onPicked;
  final String title;
  final String? hint;
  final double height;
  final double radius;

  /// Image already stored on the server; shown until a new [file] is picked.
  final String? networkUrl;

  bool get _hasImage => file != null || networkUrl != null;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
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
          border: Border.all(
            color: _hasImage ? tokens.accent : tokens.border,
            width: _hasImage ? 1.5 : 1,
          ),
        ),
        child: _hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  file != null
                      ? Image.file(file!, fit: BoxFit.cover)
                      : Image.network(networkUrl!, fit: BoxFit.cover),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const AppIcon(
                        Icons.edit_outlined,
                        color: Colors.white,
                        size: 15,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppIcon(
                    Icons.photo_camera_outlined,
                    color: tokens.textPrimary,
                    size: 28,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (hint != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      hint!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
