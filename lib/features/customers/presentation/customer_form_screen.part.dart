part of '../../../app/komekci_app.dart';

/// Two jobs, because the API keeps clients and bookings together:
///
/// - **add** (no [customer]): collects a name and phone, then continues to the
///   booking screen. The client is created by the server together with their
///   first appointment (`POST /me/appointments`).
/// - **edit**: shows the client; the only thing the API lets a master change
///   is the private note (`PATCH /me/clients/{id}`), plus removing the client.
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
    text: widget.customer == null ? '' : displayPhone(widget.customer!.phone),
  );
  late final _noteController = TextEditingController(
    text: widget.customer?.note ?? '',
  );
  bool _showErrors = false;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.customer != null;
  bool get _nameOk {
    final length = _nameController.text.trim().length;
    return length >= 2 && length <= 50;
  }

  bool get _phoneOk =>
      _phoneController.text.replaceAll(RegExp(r'\D'), '').length >= 8;
  bool get _complete => _isEditing || (_nameOk && _phoneOk);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_complete) {
      setState(() => _showErrors = true);
      return;
    }
    if (!_isEditing) {
      // The client is created together with their first booking.
      final customer = Customer(
        id: 'new',
        name: _nameController.text.trim(),
        phone: toApiPhone(_phoneController.text),
        status: CustomerStatus.newClient,
      );
      await Navigator.pushReplacement(
        context,
        pageRoute(NewAppointmentScreen(customer: customer)),
      );
      return;
    }
    final provider = context.read<CustomerProvider>();
    final navigator = Navigator.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    final ok = await runApi(context, () => provider.saveNote(widget.customer!.id, _noteController.text.trim()));
    if (!mounted) return;
    if (ok) {
      navigator.pop();
    } else {
      setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final tk = context.read<LanguageProvider>().isTurkmen;
    final provider = context.read<CustomerProvider>();
    final customer = widget.customer!;
    final navigator = Navigator.of(context);
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
    if (!confirmed || !mounted) return;
    if (await runApi(context, () => provider.remove(customer.id))) {
      navigator.pop();
      // The detail screen under this one has nothing left to show.
      if (navigator.canPop()) navigator.pop();
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
            ? (tk ? 'Müşderi bellik' : 'Заметка о клиенте')
            : (tk ? 'Täze müşderi' : 'Новый клиент'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _FormBanner(
                    title: _isEditing
                        ? (tk ? 'Ýekelikde bellik' : 'Личная заметка')
                        : (tk ? 'Täze müşderi ýazgy bilen goşulýar.' : 'Новый клиент добавляется вместе с записью.'),
                    subtitle: _isEditing
                        ? (tk
                              ? 'Ady, telefon belgisi we suraty müşderiniň özünden gelýär. Diňe şahsy bellik üýtgedilýär.'
                              : 'Имя, телефон и фото берутся из профиля клиента. Изменить можно только личную заметку.')
                        : (tk
                              ? 'Adyny we telefon belgisini giriziň, soňra wagty saýlaň.'
                              : 'Введите имя и телефон, затем выберите время записи.'),
                  ),
                  const SizedBox(height: 22),
                  if (_isEditing)
                    Center(child: _CustomerAvatar(customer: widget.customer!, radius: 46)),
                  if (_isEditing) const SizedBox(height: 24),
                  _FieldLabel(text: tk ? 'Ady' : 'Имя', required: !_isEditing),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _nameController,
                    hint: tk ? 'Müşderiniň adyny ýazyň' : 'Введите имя клиента',
                    invalid: _showErrors && !_nameOk,
                    enabled: !_isEditing,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  _FieldLabel(
                    text: tk ? 'Telefon belgisi' : 'Номер телефона',
                    required: !_isEditing,
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _phoneController,
                    hint: '+993 .. ......',
                    keyboardType: TextInputType.phone,
                    invalid: _showErrors && !_phoneOk,
                    enabled: !_isEditing,
                    onChanged: () => setState(() {}),
                  ),
                  if (_isEditing) ...[
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
                      maxLength: 2000,
                      onChanged: () => setState(() {}),
                    ),
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
                  if (_error != null) _FieldError(_error!),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Column(
                children: [
                  _MasterActionButton(
                    label: _isEditing
                        ? (tk ? 'Ýatda sakla' : 'Сохранить')
                        : (tk ? 'Dowam et' : 'Продолжить'),
                    enabled: _complete && !_saving,
                    leading: _isEditing ? Icons.save_outlined : null,
                    trailingArrow: !_isEditing,
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

