part of '../../../app/komekci_app.dart';

/// Durations offered as quick-pick chips on the service form.
const _serviceDurations = [15, 20, 30, 45, 60, 90, 120, 150];

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final services = context.watch<ServiceProvider>().services;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(title: tk ? 'Hyzmatlar' : 'Услуги'),
      body: SafeArea(
        bottom: false,
        child: ListView(
          // Extra bottom room clears the floating nav bar when shown as a tab.
          padding: EdgeInsets.fromLTRB(20, 8, 20, Navigator.of(context).canPop() ? 28 : 110),
          children: [
            _MasterActionButton(
              label: tk ? 'Täze hyzmat goş' : 'Добавить услугу',
              enabled: true,
              leading: Icons.add,
              onTap: () => Navigator.push(context, _pageRoute(const ServiceFormScreen())),
            ),
            const SizedBox(height: 22),
            Text(
              tk ? 'Goşulan hyzmatlar (${services.length})' : 'Добавленные услуги (${services.length})',
              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            if (services.isEmpty)
              _EmptyState(
                icon: Icons.content_cut,
                title: tk ? 'Heniz hyzmat ýok' : 'Услуг пока нет',
                text: tk ? 'Ilkinji hyzmatyňyzy goşuň.' : 'Добавьте первую услугу.',
              )
            else
              ...services.map((service) => _ServiceCard(service: service)),
          ],
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final SalonService service;

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final provider = context.read<ServiceProvider>();
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 240),
      opacity: service.active ? 1 : .55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: line),
          boxShadow: [BoxShadow(color: ink.withValues(alpha: .04), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ServiceThumb(service: service, size: 74),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(service.name, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, height: 1.25)),
                  if (service.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11.5, color: Colors.black45, height: 1.35),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('${service.price} ${tk ? "manat" : "манат"}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 14),
                      const AppIcon(Icons.schedule_outlined, color: Colors.black45, size: 14),
                      const SizedBox(width: 4),
                      Text('${service.minutes} min', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                SizedBox(
                  height: 30,
                  child: FittedBox(
                    child: Switch(
                      value: service.active,
                      activeThumbColor: Colors.white,
                      activeTrackColor: ink,
                      onChanged: (_) => provider.toggleActive(service.id),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _SquareIconButton(
                  icon: Icons.edit_outlined,
                  onTap: () => Navigator.push(context, _pageRoute(ServiceFormScreen(service: service))),
                ),
                const SizedBox(height: 6),
                _SquareIconButton(
                  icon: Icons.delete_outline,
                  danger: true,
                  onTap: () => _confirmDelete(context, service),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, SalonService service) async {
    final tk = context.read<LanguageProvider>().isTurkmen;
    final provider = context.read<ServiceProvider>();
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.delete_outline,
      danger: true,
      title: tk ? 'Hyzmaty pozmaly?' : 'Удалить услугу?',
      message: tk ? '"${service.name}" hyzmaty sanawdan aýrylar.' : '«${service.name}» будет удалена из списка.',
      confirmLabel: tk ? 'Poz' : 'Удалить',
      cancelLabel: tk ? 'Ýatyr' : 'Отмена',
    );
    if (confirmed) provider.remove(service.id);
  }
}

/// Renders a service picture from either a bundled asset or a picked file.
class ServiceThumb extends StatelessWidget {
  const ServiceThumb({super.key, required this.service, required this.size});
  final SalonService service;
  final double size;

  @override
  Widget build(BuildContext context) => service.imageIsAsset
      ? Image.asset(service.imagePath, width: size, height: size, fit: BoxFit.cover)
      : Image.file(File(service.imagePath), width: size, height: size, fit: BoxFit.cover);
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap, this.danger = false});
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: danger ? const Color(0xffFDF0EE) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: danger ? const Color(0xffF3D6D1) : line),
      ),
      child: AppIcon(icon, color: danger ? const Color(0xffC0392B) : ink, size: 15),
    ),
  );
}

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key, this.service});

  /// Null when adding, populated when editing an existing service.
  final SalonService? service;

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  late final _nameController = TextEditingController(text: widget.service?.name ?? '');
  late final _descriptionController = TextEditingController(text: widget.service?.description ?? '');
  late final _priceController = TextEditingController(text: widget.service?.price.toString() ?? '');
  late int? _minutes = widget.service?.minutes;
  File? _photo;
  bool _showErrors = false;

  bool get _isEditing => widget.service != null;
  bool get _hasImage => _photo != null || (widget.service?.imagePath.isNotEmpty ?? false);
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
      id: widget.service?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
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
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: _isEditing ? (tk ? 'Hyzmaty üýtget' : 'Изменить услугу') : (tk ? 'Täze hyzmat goş' : 'Новая услуга'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _FieldLabel(text: tk ? 'Hyzmatyň suraty' : 'Фото услуги', required: true),
                  const SizedBox(height: 8),
                  if (_photo == null && (widget.service?.imagePath.isNotEmpty ?? false))
                    GestureDetector(
                      onTap: () async {
                        final picked = await pickCompressedImage(context, turkmen: tk);
                        if (picked != null) setState(() => _photo = picked);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: SizedBox(
                          height: 150,
                          width: double.infinity,
                          child: ServiceThumb(service: widget.service!, size: 150),
                        ),
                      ),
                    )
                  else
                    PhotoUploadBox(
                      file: _photo,
                      onPicked: (file) => setState(() => _photo = file),
                      title: tk ? 'Surat saýlaň' : 'Выберите фото',
                      hint: tk ? 'JPG ýa-da PNG format. Maksimum 5 MB.' : 'JPG или PNG. Максимум 5 МБ.',
                    ),
                  if (_showErrors && !_hasImage) _ErrorText(tk: tk),
                  const SizedBox(height: 20),
                  _FieldLabel(text: tk ? 'Hyzmatyň ady' : 'Название услуги', required: true),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _nameController,
                    hint: tk ? 'Mysal: Saç kesmek' : 'Например: Стрижка',
                    invalid: _showErrors && !_nameOk,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(text: tk ? 'Düşündiriş' : 'Описание', optionalLabel: tk ? '(islege görä)' : '(необязательно)'),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _descriptionController,
                    hint: tk ? 'Hyzmat barada gysgaça düşündiriň...' : 'Кратко опишите услугу...',
                    maxLines: 4,
                    maxLength: 200,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  _FieldLabel(text: tk ? 'Bahasy (manat)' : 'Цена (манат)', required: true),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _priceController,
                    hint: tk ? 'Mysal: 80' : 'Например: 80',
                    keyboardType: TextInputType.number,
                    invalid: _showErrors && !_priceOk,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(text: tk ? 'Wagty (minut)' : 'Длительность (мин)', required: true),
                  const SizedBox(height: 8),
                  Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _showErrors && _minutes == null ? const Color(0xffC0392B) : line),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _minutes == null ? (tk ? 'Wagty saýlaň' : 'Выберите время') : '$_minutes min',
                            style: TextStyle(
                              fontSize: 14,
                              color: _minutes == null ? Colors.black38 : ink,
                              fontWeight: _minutes == null ? FontWeight.w400 : FontWeight.w600,
                            ),
                          ),
                        ),
                        const AppIcon(Icons.expand_more, color: Colors.black45, size: 18),
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
                            color: selected ? ink : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: selected ? ink : line),
                          ),
                          child: Text(
                            '$minutes min',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : ink,
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
                label: tk ? 'Ýatda sakla' : 'Сохранить',
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
          child: Text('*', style: TextStyle(fontSize: 14, color: Color(0xffC0392B), fontWeight: FontWeight.w700)),
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
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      keyboardType: keyboardType,
      onChanged: (_) => onChanged(),
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14, fontWeight: FontWeight.w400),
        errorText: invalid ? (tk ? 'Bu meýdan hökmany' : 'Обязательное поле') : null,
        errorStyle: const TextStyle(fontSize: 11.5),
        counterStyle: const TextStyle(fontSize: 11, color: Colors.black38),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: gold, width: 1.5),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.title, required this.text});
  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
    decoration: BoxDecoration(
      color: const Color(0xffFAF8F4),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: line),
    ),
    child: Column(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          child: AppIcon(icon, color: gold, size: 24),
        ),
        const SizedBox(height: 14),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: Colors.black45, height: 1.4)),
      ],
    ),
  );
}
