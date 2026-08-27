part of '../../../app/komekci_app.dart';

class CustomerFormScreen extends StatefulWidget {
  const CustomerFormScreen({super.key, this.customer});

  /// Null when adding, populated when editing an existing customer.
  final Customer? customer;

  @override
  State<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends State<CustomerFormScreen> {
  late final _nameController = TextEditingController(
    text: widget.customer?.name ?? '',
  );
  late final _phoneController = TextEditingController(
    text: widget.customer?.phone ?? '',
  );
  late final _nicknameController = TextEditingController(
    text: widget.customer?.nickname ?? '',
  );
  late final _noteController = TextEditingController(
    text: widget.customer?.note ?? '',
  );
  late CustomerStatus _status =
      widget.customer?.status ?? CustomerStatus.newClient;
  File? _photo;
  bool _showErrors = false;

  bool get _isEditing => widget.customer != null;
  bool get _nameOk => _nameController.text.trim().isNotEmpty;
  bool get _phoneOk => _phoneController.text.trim().length >= 8;
  bool get _complete => _nameOk && _phoneOk;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nicknameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    final provider = context.read<CustomerProvider>();
    final photoPath = _photo?.path ?? widget.customer?.photoPath ?? '';
    if (_isEditing) {
      provider.update(
        widget.customer!.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          nickname: _nicknameController.text.trim(),
          status: _status,
          note: _noteController.text.trim(),
          photoPath: photoPath,
        ),
      );
    } else {
      provider.add(
        Customer(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          nickname: _nicknameController.text.trim(),
          status: _status,
          note: _noteController.text.trim(),
          photoPath: photoPath,
        ),
      );
    }
    Navigator.pop(context);
  }

  Future<void> _confirmDelete() async {
    final tk = context.read<LanguageProvider>().isTurkmen;
    final provider = context.read<CustomerProvider>();
    final customer = widget.customer!;
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.delete_outline,
      danger: true,
      title: tk ? 'Müşderini pozmaly?' : 'Удалить клиента?',
      message: tk
          ? '"${customer.name}" sanawdan aýrylar. Bu hereketi yzyna gaýtaryp bolmaýar.'
          : '«${customer.name}» будет удалён из списка без возможности восстановления.',
      confirmLabel: tk ? 'Poz' : 'Удалить',
      cancelLabel: tk ? 'Ýatyr' : 'Отмена',
    );
    if (confirmed && mounted) {
      provider.remove(customer.id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: _isEditing
            ? (tk ? 'Müşderini üýtget' : 'Изменить клиента')
            : (tk ? 'Müşderi goşmak' : 'Добавить клиента'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _FormBanner(
                    title: tk
                        ? 'Täze müşderi goşuň.'
                        : 'Добавьте нового клиента.',
                    subtitle: tk
                        ? 'Esasy maglumatlary dolduryň.'
                        : 'Заполните основные данные.',
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: Column(
                      children: [
                        AvatarPicker(
                          file: _photo,
                          radius: 46,
                          fallback:
                              !_isEditing ||
                                  (widget.customer?.photoPath ?? '').isEmpty
                              ? null
                              : FileImage(File(widget.customer!.photoPath)),
                          onPicked: (f) => setState(() => _photo = f),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tk
                              ? 'Surat goşmak (islege görä)'
                              : 'Добавить фото (необязательно)',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Colors.black45,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _FieldLabel(text: tk ? 'Ady' : 'Имя', required: true),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _nameController,
                    hint: tk ? 'Müşderiniň adyny ýazyň' : 'Введите имя клиента',
                    invalid: _showErrors && !_nameOk,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  _FieldLabel(
                    text: tk ? 'Telefon belgisi' : 'Номер телефона',
                    required: true,
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _phoneController,
                    hint: '+993 .. ... .. ..',
                    keyboardType: TextInputType.phone,
                    invalid: _showErrors && !_phoneOk,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Text(
                        tk ? 'Lakamy (Nickname)' : 'Никнейм',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message: tk
                            ? 'Müşderiniň Instagram ýa-da başga ulgamdaky lakamy. Islege görä.'
                            : 'Никнейм клиента в Instagram или другой сети. Необязательно.',
                        child: const AppIcon(
                          Icons.help_outline,
                          size: 14,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _nicknameController,
                    hint: tk
                        ? 'Müşderiniň lakamyny ýazyň (islege görä)'
                        : 'Введите никнейм клиента (необязательно)',
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(text: tk ? 'Status' : 'Статус', required: true),
                  const SizedBox(height: 10),
                  Row(
                    children: CustomerStatus.values
                        .map(
                          (status) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: status == CustomerStatus.values.last
                                    ? 0
                                    : 8,
                              ),
                              child: _StatusOptionCard(
                                status: status,
                                tk: tk,
                                selected: _status == status,
                                onTap: () => setState(() => _status = status),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(
                    text: tk ? 'Bellik' : 'Заметка',
                    optionalLabel: tk ? '(islege görä)' : '(необязательно)',
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _noteController,
                    hint: tk
                        ? 'Müşderi barada bellik goşuň...'
                        : 'Добавьте заметку о клиенте...',
                    maxLines: 4,
                    maxLength: 200,
                    onChanged: () => setState(() {}),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: _confirmDelete,
                        child: Text(
                          tk ? 'Müşderini poz' : 'Удалить клиента',
                          style: TextStyle(
                            color: tokens.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Column(
                children: [
                  _MasterActionButton(
                    label: tk ? 'Ýatda sakla' : 'Сохранить',
                    enabled: _complete,
                    leading: Icons.save_outlined,
                    onTap: _save,
                  ),
                  const SizedBox(height: 2),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      tk ? 'Ýatyrmazdan yzyna dön' : 'Вернуться без сохранения',
                      style: TextStyle(
                        color: tokens.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormBanner extends StatelessWidget {
  const _FormBanner({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xffEEF0FB),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: const AppIcon(
            Icons.info_outline,
            size: 15,
            color: Color(0xff5B5FC7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: context.appTokens.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _StatusOptionCard extends StatelessWidget {
  const _StatusOptionCard({
    required this.status,
    required this.tk,
    required this.selected,
    required this.onTap,
  });
  final CustomerStatus status;
  final bool tk;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            height: 78,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: .06)
                  : tokens.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? color : tokens.border,
                width: selected ? 1.6 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcon(
                  _statusIcon(status),
                  size: 20,
                  color: selected ? color : Colors.black45,
                ),
                const SizedBox(height: 6),
                Text(
                  _statusLabel(status, tk),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : tokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (selected)
            Positioned(
              top: -6,
              right: -6,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(color: tokens.accentOn, width: 2),
                ),
                child: AppIcon(Icons.check, size: 11, color: tokens.accentOn),
              ),
            ),
        ],
      ),
    );
  }
}

