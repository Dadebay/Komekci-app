import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/localization/language_provider.dart';
import '../../core/theme/app_theme_tokens.dart';
import '../utils/image_compress.dart';
import 'app_icon.dart';
import 'app_toast.dart';

/// Photos are downscaled (longest edge 1440 px) and re-encoded at 70% JPEG
/// quality by the picker, then squeezed under 1 MB by [compressImageUnder]
/// if that was not enough. Both edges are bounded so a tall screenshot cannot
/// slip through at 1440 px wide and 3000 px high.
const _pickedImageQuality = 70;
const _pickedImageMaxEdge = 1440.0;

Future<File?> pickCompressedImage(BuildContext context, {AppLanguage language = AppLanguage.tk}) async {
  final tokens = context.appTokens;
  final toast = AppToast.of(context);
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: tokens.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(color: tokens.border, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 14),
          ListTile(
            leading: AppIcon(Icons.photo_camera_outlined, color: tokens.textPrimary, size: 21),
            title: Text(pickTr(language, tk: 'Surat düşür', ru: 'Сделать фото', en: 'Take a photo')),
            onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
          ),
          ListTile(
            leading: AppIcon(Icons.image_outlined, color: tokens.textPrimary, size: 21),
            title: Text(pickTr(language, tk: 'Galereýadan saýla', ru: 'Выбрать из галереи', en: 'Choose from gallery')),
            onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (source == null) return null;
  final picked = await ImagePicker().pickImage(source: source, imageQuality: _pickedImageQuality, maxWidth: _pickedImageMaxEdge, maxHeight: _pickedImageMaxEdge);
  if (picked == null) return null;
  // The picker already downsizes; this guarantees the upload fits in 1 MB.
  final file = await compressImageUnder(File(picked.path));
  if (await file.length() > uploadLimitBytes) {
    // Could not be decoded, so it could not be shrunk: do not hand a big
    // file on to an upload that the server will turn down.
    toast.error(
      pickTr(
        language,
        tk: 'Surat gaty uly ýa-da okalmady. Başga surat saýlaň.',
        ru: 'Фото слишком большое или не читается. Выберите другое.',
        en: 'The photo is too large or cannot be read. Choose another one.',
      ),
    );
    return null;
  }
  return file;
}

/// Round photo: a just-picked local [file] wins over the server [url];
/// with neither — or when the download fails (a missing file on the server
/// answers 500) — it shows a placeholder icon instead of throwing.
class RoundPhoto extends StatelessWidget {
  const RoundPhoto({super.key, this.file, this.url, this.radius = 24, this.placeholder = Icons.person_outline, this.backgroundColor = const Color(0xffE6D2B1)});

  final File? file;
  final String? url;
  final double radius;
  final IconData placeholder;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    Widget icon() => Center(
      child: AppIcon(placeholder, size: radius * .85, color: tokens.textPrimary),
    );
    final Widget content;
    if (file != null) {
      content = Image.file(file!, fit: BoxFit.cover, errorBuilder: (_, _, _) => icon());
    } else if (url != null) {
      content = Image.network(url!, fit: BoxFit.cover, errorBuilder: (_, _, _) => icon(), frameBuilder: (_, child, frame, sync) => sync || frame != null ? child : icon());
    } else {
      content = icon();
    }
    return SizedBox(
      width: radius * 2,
      height: radius * 2,
      child: ClipOval(
        child: ColoredBox(color: backgroundColor, child: content),
      ),
    );
  }
}

/// Round avatar with a camera badge, used on profile screens.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({super.key, required this.file, required this.onPicked, this.radius = 44, this.networkUrl});

  final File? file;
  final ValueChanged<File> onPicked;
  final double radius;

  /// Photo already stored on the server; shown until a new [file] is picked.
  final String? networkUrl;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: () async {
        final picked = await pickCompressedImage(context, language: context.read<LanguageProvider>().language);
        if (picked != null) onPicked(picked);
      },
      child: Stack(
        children: [
          RoundPhoto(file: file, url: networkUrl, radius: radius, backgroundColor: const Color(0xffF1EDE4)),
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
              child: AppIcon(Icons.photo_camera_outlined, color: tokens.accentOn, size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dashed-looking upload box used by the registration and service forms.
class PhotoUploadBox extends StatelessWidget {
  const PhotoUploadBox({super.key, required this.file, required this.onPicked, required this.title, this.hint, this.height = 150, this.radius = 18, this.networkUrl});

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
        final picked = await pickCompressedImage(context, language: context.read<LanguageProvider>().language);
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
          border: Border.all(color: _hasImage ? tokens.accent : tokens.border, width: _hasImage ? 1.5 : 1),
        ),
        child: _hasImage
            ? Stack(
                fit: StackFit.expand,
                children: [
                  file != null
                      ? Image.file(file!, fit: BoxFit.cover)
                      : Image.network(
                          networkUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Center(child: AppIcon(Icons.image_outlined, color: tokens.textSecondary, size: 28)),
                        ),
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
                  AppIcon(Icons.photo_camera_outlined, color: tokens.textPrimary, size: 28),
                  const SizedBox(height: 10),
                  Text(title, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                  if (hint != null) ...[const SizedBox(height: 5), Text(hint!, style: const TextStyle(fontSize: 11.5, color: Colors.black45))],
                ],
              ),
      ),
    );
  }
}
