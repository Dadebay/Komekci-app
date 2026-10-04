part of '../../../app/komekci_app.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key, this.service});

  /// Null when adding, populated when editing an existing service.
  final SalonService? service;

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  /// Backend limits (`POST /me/services`).
  static const _nameMax = 60;
  static const _descriptionMax = 300;
  static const _priceMax = 999999;
  static const _minMinutes = 5;
  static const _maxMinutes = 480;

  late final _nameController = TextEditingController(text: widget.service?.name ?? '');
  late final _descriptionController = TextEditingController(text: widget.service?.description ?? '');
  late final _priceController = TextEditingController(text: widget.service?.price.toString() ?? '');
  late int? _minutes = widget.service?.minutes;

  /// A duration that is not one of the quick-pick chips is typed in.
  late bool _customDuration = widget.service != null && !_serviceDurations.contains(widget.service!.minutes);
  late final _customController = TextEditingController(text: _customDuration ? '${widget.service!.minutes}' : '');
  File? _photo;
  bool _showErrors = false;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.service != null;
  bool get _hasImage => _photo != null || (widget.service?.imagePath.isNotEmpty ?? false);
  bool get _nameOk => _nameController.text.trim().length >= 2;
  bool get _priceOk {
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    return price > 0 && price <= _priceMax;
  }

  bool get _durationOk => _minutes != null && _minutes! >= _minMinutes && _minutes! <= _maxMinutes;
  bool get _complete => _hasImage && _nameOk && _priceOk && _durationOk;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _customController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    FocusScope.of(context).unfocus();
    final provider = context.read<ServiceProvider>();
    final language = context.read<LanguageProvider>().language;
    final navigator = Navigator.of(context);
    final service = SalonService(
      id: widget.service?.id ?? '0',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      minutes: _minutes!,
      imagePath: widget.service?.imagePath ?? '',
      active: widget.service?.active ?? true,
    );
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      if (_isEditing) {
        await provider.update(service, photoPath: _photo?.path);
      } else {
        await provider.add(name: service.name, description: service.description, price: service.price, minutes: service.minutes, photoPath: _photo!.path);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = apiErrorMessage(error, language);
      });
      return;
    }
    navigator.pop();
  }

  void _pickPreset(int minutes) => setState(() {
    _customDuration = false;
    _minutes = minutes;
  });

  void _chooseCustom() => setState(() {
    _customDuration = true;
    _minutes = int.tryParse(_customController.text.trim());
  });

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final currency = context.watch<AppSettingsProvider>().currencyLabel(language);
    final required = t(tk: 'Bu meýdan hökmany', ru: 'Обязательное поле', en: 'This field is required');

    String? nameError() {
      if (!_showErrors || _nameOk) return null;
      return _nameController.text.trim().isEmpty ? required : t(tk: 'Iň az 2 harp', ru: 'Минимум 2 символа', en: 'At least 2 characters');
    }

    String? durationError() {
      if (!_showErrors || _durationOk) return null;
      return _minutes == null
          ? t(tk: 'Wagty saýlaň', ru: 'Выберите длительность', en: 'Choose a duration')
          : t(tk: '$_minMinutes–$_maxMinutes minut aralygynda', ru: 'От $_minMinutes до $_maxMinutes минут', en: 'Between $_minMinutes and $_maxMinutes minutes');
    }

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: _isEditing ? t(tk: 'Hyzmaty üýtget', ru: 'Изменить услугу', en: 'Edit service') : t(tk: 'Täze hyzmat goş', ru: 'Новая услуга', en: 'New service'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  _ServicePhotoBox(
                    file: _photo,
                    existing: widget.service,
                    invalid: _showErrors && !_hasImage,
                    title: t(tk: 'Hyzmatyň suraty', ru: 'Фото услуги', en: 'Service photo'),
                    hint: t(tk: 'JPG ýa-da PNG. Surat awtomatiki kiçeldiler.', ru: 'JPG или PNG. Фото уменьшится автоматически.', en: 'JPG or PNG. The photo is resized automatically.'),
                    changeLabel: t(tk: 'Suraty üýtget', ru: 'Изменить фото', en: 'Change photo'),
                    errorText: required,
                    onPicked: (file) => setState(() => _photo = file),
                  ),
                  const SizedBox(height: 14),
                  _ProfileSection(
                    icon: Icons.content_cut,
                    title: t(tk: 'Hyzmat barada', ru: 'Об услуге', en: 'About the service'),
                    children: [
                      _ProfileField(
                        controller: _nameController,
                        label: t(tk: 'Hyzmatyň ady', ru: 'Название услуги', en: 'Service name'),
                        icon: Icons.content_cut,
                        hint: t(tk: 'Mysal: Saç kesmek', ru: 'Например: Стрижка', en: 'Example: Haircut'),
                        errorText: nameError(),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [LengthLimitingTextInputFormatter(_nameMax)],
                        onChanged: (_) => setState(() {}),
                      ),
                      _ProfileField(
                        controller: _descriptionController,
                        label: t(tk: 'Düşündiriş (islege görä)', ru: 'Описание (необязательно)', en: 'Description (optional)'),
                        icon: Icons.sticky_note_2_outlined,
                        hint: t(tk: 'Hyzmat barada gysgaça düşündiriň...', ru: 'Кратко опишите услугу...', en: 'Briefly describe the service...'),
                        maxLines: 4,
                        minLines: 3,
                        keyboardType: TextInputType.multiline,
                        maxLength: _descriptionMax,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ProfileSection(
                    icon: Icons.payments_outlined,
                    title: t(tk: 'Baha we wagt', ru: 'Цена и время', en: 'Price & time'),
                    children: [
                      _ProfileField(
                        controller: _priceController,
                        label: t(tk: 'Bahasy', ru: 'Цена', en: 'Price'),
                        icon: Icons.payments_outlined,
                        hint: t(tk: 'Mysal: 80', ru: 'Например: 80', en: 'Example: 80'),
                        errorText: _showErrors && !_priceOk ? required : null,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6)],
                        statusIcon: Text(
                          currency,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.textSecondary),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      _DurationPicker(
                        label: t(tk: 'Wagty (minut)', ru: 'Длительность (мин)', en: 'Duration (min)'),
                        otherLabel: t(tk: 'Başga', ru: 'Другое', en: 'Other'),
                        customFieldLabel: t(tk: 'Başga wagt (minut)', ru: 'Своя длительность (мин)', en: 'Custom duration (min)'),
                        customHint: '$_minMinutes–$_maxMinutes',
                        selected: _customDuration ? null : _minutes,
                        custom: _customDuration,
                        customController: _customController,
                        errorText: durationError(),
                        onPreset: _pickPreset,
                        onCustom: _chooseCustom,
                        onCustomChanged: (value) => setState(() => _minutes = int.tryParse(value.trim())),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _ServiceSaveBar(
              error: _error,
              saving: _saving,
              label: _saving
                  ? t(tk: 'Saklanýar...', ru: 'Сохранение...', en: 'Saving...')
                  : _isEditing
                  ? t(tk: 'Ýatda sakla', ru: 'Сохранить', en: 'Save')
                  : t(tk: 'Hyzmaty goş', ru: 'Добавить услугу', en: 'Add service'),
              onSave: _save,
            ),
          ],
        ),
      ),
    );
  }
}

/// Large tappable photo area: shows the picked file, else the service's
/// current picture, else an empty prompt. A red outline marks a missing photo
/// once the form has been submitted.
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
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [tokens.accent.withValues(alpha: .16), tokens.accent.withValues(alpha: .05)]),
      ),
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
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(_radius), color: tokens.surfaceElevated),
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
          _MasterActionButton(label: label, enabled: !saving, leading: saving ? null : Icons.save_outlined, onTap: onSave),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text, this.required = false, this.optionalLabel});
  final String text;
  final bool required;
  final String? optionalLabel;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
      if (required)
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '*',
            style: TextStyle(fontSize: 14, color: Color(0xffC0392B), fontWeight: FontWeight.w700),
          ),
        ),
      if (optionalLabel != null)
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(optionalLabel!, style: const TextStyle(fontSize: 12.5, color: Colors.black38)),
        ),
    ],
  );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText({required this.tk});
  final bool tk;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 7, left: 4),
    child: Text(tk ? 'Bu meýdan hökmany' : 'Обязательное поле', style: const TextStyle(fontSize: 11.5, color: Color(0xffC0392B))),
  );
}

class _FormField extends StatelessWidget {
  const _FormField({required this.controller, required this.hint, required this.onChanged, this.maxLines = 1, this.maxLength, this.keyboardType, this.invalid = false, this.enabled = true});

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool invalid;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      onChanged: (_) => onChanged(),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w400),
        errorText: invalid ? pickTr(language, tk: 'Bu meýdan hökmany', ru: 'Обязательное поле', en: 'This field is required') : null,
        errorStyle: const TextStyle(fontSize: 11.5),
        counterStyle: const TextStyle(fontSize: 11, color: Colors.black38),
        filled: true,
        fillColor: tokens.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: tokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: tokens.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffC0392B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xffC0392B), width: 1.5),
        ),
      ),
    );
  }
}
