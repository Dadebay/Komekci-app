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
                    backgroundColor: tokens.surface,
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
                    backgroundColor: tokens.surface,
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
