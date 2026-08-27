part of '../../../app/komekci_app.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key, this.service});

  /// Null when adding, populated when editing an existing service.
  final SalonService? service;

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  late final _nameController = TextEditingController(
    text: widget.service?.name ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: widget.service?.description ?? '',
  );
  late final _priceController = TextEditingController(
    text: widget.service?.price.toString() ?? '',
  );
  late int? _minutes = widget.service?.minutes;
  File? _photo;
  bool _showErrors = false;

  bool get _isEditing => widget.service != null;
  bool get _hasImage =>
      _photo != null || (widget.service?.imagePath.isNotEmpty ?? false);
  bool get _nameOk => _nameController.text.trim().isNotEmpty;
  bool get _priceOk => (int.tryParse(_priceController.text.trim()) ?? 0) > 0;
  bool get _complete => _hasImage && _nameOk && _priceOk && _minutes != null;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    final provider = context.read<ServiceProvider>();
    final service = SalonService(
      id:
          widget.service?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      price: int.parse(_priceController.text.trim()),
      minutes: _minutes!,
      imagePath: _photo?.path ?? widget.service!.imagePath,
      imageIsAsset: _photo == null && (widget.service?.imageIsAsset ?? false),
      active: widget.service?.active ?? true,
    );
    _isEditing ? provider.update(service) : provider.add(service);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tk = language == AppLanguage.tk;
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: _isEditing
            ? t(tk: 'Hyzmaty üýtget', ru: 'Изменить услугу', en: 'Edit service')
            : t(tk: 'Täze hyzmat goş', ru: 'Новая услуга', en: 'New service'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _FieldLabel(
                    text: t(
                      tk: 'Hyzmatyň suraty',
                      ru: 'Фото услуги',
                      en: 'Service photo',
                    ),
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  if (_photo == null &&
                      (widget.service?.imagePath.isNotEmpty ?? false))
                    GestureDetector(
                      onTap: () async {
                        final picked = await pickCompressedImage(
                          context,
                          language: language,
                        );
                        if (picked != null) setState(() => _photo = picked);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: ServiceThumb(
                            service: widget.service!,
                            size: 150,
                          ),
                        ),
                      ),
                    )
                  else
                    PhotoUploadBox(
                      file: _photo,
                      onPicked: (file) => setState(() => _photo = file),
                      title: t(
                        tk: 'Surat saýlaň',
                        ru: 'Выберите фото',
                        en: 'Choose photo',
                      ),
                      hint: t(
                        tk: 'JPG ýa-da PNG format. Maksimum 5 MB.',
                        ru: 'JPG или PNG. Максимум 5 МБ.',
                        en: 'JPG or PNG format. Max 5 MB.',
                      ),
                    ),
                  if (_showErrors && !_hasImage) _ErrorText(tk: tk),
                  const SizedBox(height: 20),
                  _FieldLabel(
                    text: t(
                      tk: 'Hyzmatyň ady',
                      ru: 'Название услуги',
                      en: 'Service name',
                    ),
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _nameController,
                    hint: t(
                      tk: 'Mysal: Saç kesmek',
                      ru: 'Например: Стрижка',
                      en: 'Example: Haircut',
                    ),
                    invalid: _showErrors && !_nameOk,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(
                    text: t(
                      tk: 'Düşündiriş',
                      ru: 'Описание',
                      en: 'Description',
                    ),
                    optionalLabel: t(
                      tk: '(islege görä)',
                      ru: '(необязательно)',
                      en: '(optional)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _descriptionController,
                    hint: t(
                      tk: 'Hyzmat barada gysgaça düşündiriň...',
                      ru: 'Кратко опишите услугу...',
                      en: 'Briefly describe the service...',
                    ),
                    maxLines: 4,
                    maxLength: 200,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(
                    text: t(
                      tk: 'Bahasy (manat)',
                      ru: 'Цена (манат)',
                      en: 'Price (TMT)',
                    ),
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _priceController,
                    hint: t(
                      tk: 'Mysal: 80',
                      ru: 'Например: 80',
                      en: 'Example: 80',
                    ),
                    keyboardType: TextInputType.number,
                    invalid: _showErrors && !_priceOk,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(
                    text: t(
                      tk: 'Wagty (minut)',
                      ru: 'Длительность (мин)',
                      en: 'Duration (min)',
                    ),
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: tokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _showErrors && _minutes == null
                            ? const Color(0xffC0392B)
                            : tokens.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _minutes == null
                                ? t(
                                    tk: 'Wagty saýlaň',
                                    ru: 'Выберите время',
                                    en: 'Choose duration',
                                  )
                                : '$_minutes min',
                            style: TextStyle(
                              fontSize: 14,
                              color: _minutes == null
                                  ? Colors.black38
                                  : tokens.textPrimary,
                              fontWeight: _minutes == null
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                        const AppIcon(
                          Icons.expand_more,
                          color: Colors.black45,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _serviceDurations.map((minutes) {
                      final selected = _minutes == minutes;
                      return GestureDetector(
                        onTap: () => setState(() => _minutes = minutes),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 78,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: selected
                                ? tokens.textPrimary
                                : tokens.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? tokens.textPrimary
                                  : tokens.border,
                            ),
                          ),
                          child: Text(
                            '$minutes min',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? tokens.surface
                                  : tokens.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label: t(tk: 'Ýatda sakla', ru: 'Сохранить', en: 'Save'),
                enabled: _complete,
                leading: Icons.save_outlined,
                onTap: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.text,
    this.required = false,
    this.optionalLabel,
  });
  final String text;
  final bool required;
  final String? optionalLabel;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      ),
      if (required)
        const Padding(
          padding: EdgeInsets.only(left: 4),
          child: Text(
            '*',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xffC0392B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      if (optionalLabel != null)
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Text(
            optionalLabel!,
            style: const TextStyle(fontSize: 12.5, color: Colors.black38),
          ),
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
    child: Text(
      tk ? 'Bu meýdan hökmany' : 'Обязательное поле',
      style: const TextStyle(fontSize: 11.5, color: Color(0xffC0392B)),
    ),
  );
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.invalid = false,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;
  final int maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool invalid;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tokens = context.appTokens;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      onChanged: (_) => onChanged(),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.black38,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        errorText: invalid
            ? pickTr(
                language,
                tk: 'Bu meýdan hökmany',
                ru: 'Обязательное поле',
                en: 'This field is required',
              )
            : null,
        errorStyle: const TextStyle(fontSize: 11.5),
        counterStyle: const TextStyle(fontSize: 11, color: Colors.black38),
        filled: true,
        fillColor: tokens.surfaceElevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
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
