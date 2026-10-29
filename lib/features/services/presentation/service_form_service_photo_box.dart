part of '../../../app/komekci_app.dart';

class _ServicePhotoBox extends StatelessWidget {
  const _ServicePhotoBox({
    required this.file,
    required this.existing,
    required this.invalid,
    required this.title,
    required this.hint,
    required this.changeLabel,
    required this.errorText,
    required this.onPicked,
  });

  final File? file;
  final SalonService? existing;
  final bool invalid;
  final String title;
  final String hint;
  final String changeLabel;
  final String errorText;
  final ValueChanged<File> onPicked;

  static const _height = 190.0;
  static const _radius = 22.0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final existingService = existing;
    final hasExisting = existingService != null && existingService.imagePath.isNotEmpty;
    final hasImage = file != null || hasExisting;

    Future<void> pick() async {
      final picked = await pickCompressedImage(context, language: context.read<LanguageProvider>().language);
      if (picked != null) onPicked(picked);
    }

    // The "change photo" pill that sits on top of a loaded picture.
    Widget withChangePill(Widget picture) => Stack(
      fit: StackFit.expand,
      children: [
        picture,
        Positioned(
          right: 10,
          bottom: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: .55), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppIcon(Icons.photo_camera_outlined, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  changeLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    // What an empty box (or a picture that failed to load) shows.
    final prompt = Container(
      decoration: BoxDecoration(color: tokens.surface),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: tokens.accent.withValues(alpha: .2)),
            child: AppIcon(Icons.photo_camera_outlined, size: 26, color: tokens.accent),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: tokens.textPrimary),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              hint,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: tokens.textSecondary),
            ),
          ),
        ],
      ),
    );

    Widget picture() {
      if (file != null) return withChangePill(Image.file(file!, fit: BoxFit.cover));
      if (!hasExisting) return prompt;
      final service = existingService;
      if (service.imageIsNetwork) {
        // A picture that cannot be loaded falls back to the empty prompt
        // instead of a stretched placeholder icon.
        return Image.network(service.imagePath, fit: BoxFit.cover, errorBuilder: (_, _, _) => prompt, frameBuilder: (_, child, frame, sync) => sync || frame != null ? withChangePill(child) : prompt);
      }
      return withChangePill(ServiceThumb(service: service, size: _height));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: pick,
          child: Container(
            height: _height,
            width: double.infinity,
            // Clipped to the same rounded shape as the border, so the picture
            // gets rounded corners too ...
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(_radius), color: tokens.surface),
            // ... and the border is painted on top of it, so the picture can
            // never cover it.
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_radius),
              border: Border.all(
                color: invalid
                    ? tokens.danger
                    : hasImage
                    ? tokens.accent.withValues(alpha: .7)
                    : tokens.border,
                width: invalid ? 1.6 : 1.2,
              ),
            ),
            child: picture(),
          ),
        ),
        if (invalid) _FieldError(errorText),
      ],
    );
  }
}

/// Duration quick-picks in a 4-column grid, plus an "Other" chip that opens a
/// number field for anything the chips do not cover.
class _DurationPicker extends StatelessWidget {
  const _DurationPicker({
    required this.label,
    required this.otherLabel,
    required this.customFieldLabel,
    required this.customHint,
    required this.selected,
    required this.custom,
    required this.customController,
    required this.errorText,
    required this.onPreset,
    required this.onCustom,
    required this.onCustomChanged,
  });

  final String label;
  final String otherLabel;
  final String customFieldLabel;
  final String customHint;

  /// The chosen preset, or null when none (or a custom value) is chosen.
  final int? selected;
  final bool custom;
  final TextEditingController customController;
  final String? errorText;
  final ValueChanged<int> onPreset;
  final VoidCallback onCustom;
  final ValueChanged<String> onCustomChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    Widget chip({required double width, required String text, required bool isSelected, required VoidCallback onTap}) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? tokens.accent : tokens.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? tokens.accent
                : errorText != null
                ? tokens.danger.withValues(alpha: .6)
                : tokens.border,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: isSelected ? tokens.accentOn : tokens.textPrimary),
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary),
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            const gap = 8.0;
            final width = (constraints.maxWidth - gap * 3) / 4;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final minutes in _serviceDurations) chip(width: width, text: '$minutes min', isSelected: !custom && selected == minutes, onTap: () => onPreset(minutes)),
                chip(width: width, text: otherLabel, isSelected: custom, onTap: onCustom),
              ],
            );
          },
        ),
        if (custom) ...[
          const SizedBox(height: 14),
          _ProfileField(
            controller: customController,
            label: customFieldLabel,
            icon: Icons.timer_outlined,
            hint: customHint,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
            onChanged: onCustomChanged,
          ),
        ],
        if (errorText != null) _FieldError(errorText!),
      ],
    );
  }
}

/// Fixed bar under the form: a server error (if any) and the save button.
class _ServiceSaveBar extends StatelessWidget {
  const _ServiceSaveBar({required this.error, required this.saving, required this.label, required this.onSave});

  final String? error;
  final bool saving;
  final String label;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: tokens.surface,
        border: Border(top: BorderSide(color: tokens.border)),
        boxShadow: [BoxShadow(color: tokens.textPrimary.withValues(alpha: .05), blurRadius: 14, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (error != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: tokens.danger.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: tokens.danger.withValues(alpha: .35)),
              ),
              child: Row(
                children: [
                  AppIcon(Icons.warning_amber_rounded, size: 16, color: tokens.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(error!, style: TextStyle(fontSize: 12.5, color: tokens.danger)),
                  ),
                ],
              ),
            ),
          MasterActionButton(label: label, enabled: !saving, leading: saving ? null : Icons.save_outlined, onTap: onSave),
        ],
      ),
    );
  }
}

