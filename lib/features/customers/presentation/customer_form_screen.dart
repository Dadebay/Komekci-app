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
      _phoneController.text.replaceAll(RegExp(r'\D'), '').length == 8;
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
    final language = context.read<LanguageProvider>().language;
    final provider = context.read<CustomerProvider>();
    final customer = widget.customer!;
    final navigator = Navigator.of(context);
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.delete_outline,
      danger: true,
      title: pickTr(language, tk: 'Müşderini pozmaly?', ru: 'Удалить клиента?', en: 'Delete customer?'),
      message: pickTr(language,
        tk: '"${customer.name}" sanawdan aýrylar. Bu hereketi yzyna gaýtaryp bolmaýar.',
        ru: '«${customer.name}» будет удалён из списка без возможности восстановления.',
        en: '"${customer.name}" will be removed from your customer list. This cannot be undone.',
      ),
      confirmLabel: pickTr(language, tk: 'Poz', ru: 'Удалить', en: 'Delete'),
      cancelLabel: pickTr(language, tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel'),
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
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: _isEditing
            ? t(tk: 'Müşderi bellik', ru: 'Заметка о клиенте', en: 'Customer note')
            : t(tk: 'Täze müşderi', ru: 'Новый клиент', en: 'New customer'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _FormBanner(
                    title: _isEditing
                        ? t(tk: 'Ýekelikde bellik', ru: 'Личная заметка', en: 'Private note')
                        : t(tk: 'Täze müşderi ýazgy bilen goşulýar.', ru: 'Новый клиент добавляется вместе с записью.', en: 'A new customer is added with a booking.'),
                    subtitle: _isEditing
                        ? t(tk: 'Ady, telefon belgisi we suraty müşderiniň özünden gelýär. Diňe şahsy bellik üýtgedilýär.', ru: 'Имя, телефон и фото берутся из профиля клиента. Изменить можно только личную заметку.', en: 'Name, phone and photo come from the customer profile. You can only edit your private note.')
                        : t(tk: 'Adyny we telefon belgisini giriziň, soňra wagty saýlaň.', ru: 'Введите имя и телефон, затем выберите время записи.', en: 'Enter a name and phone number, then choose a booking time.'),
                  ),
                  const SizedBox(height: 22),
                  if (_isEditing)
                    Center(child: _CustomerAvatar(customer: widget.customer!, radius: 46)),
                  if (_isEditing) const SizedBox(height: 24),
                  _FieldLabel(text: t(tk: 'Ady', ru: 'Имя', en: 'Name'), required: !_isEditing),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _nameController,
                    hint: t(tk: 'Müşderiniň adyny ýazyň', ru: 'Введите имя клиента', en: 'Enter customer name'),
                    fillColor: tokens.surface,
                    invalid: _showErrors && !_nameOk,
                    enabled: !_isEditing,
                    onChanged: () => setState(() {}),
                  ),
                  const SizedBox(height: 18),
                  _FieldLabel(
                    text: t(tk: 'Telefon belgisi', ru: 'Номер телефона', en: 'Phone number'),
                    required: !_isEditing,
                  ),
                  const SizedBox(height: 8),
                  _FormField(
                    controller: _phoneController,
                    hint: '65 123456',
                    fillColor: tokens.surface,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    prefixIcon: _isEditing ? null : phonePrefix(context, fontSize: 14),
                    inputFormatters: _isEditing ? null : [_PhoneNumberFormatter()],
                    invalid: _showErrors && !_phoneOk,
                    enabled: !_isEditing,
                    onChanged: () => setState(() {}),
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 20),
                    _FieldLabel(
                      text: t(tk: 'Bellik', ru: 'Заметка', en: 'Note'),
                      optionalLabel: t(tk: '(islege görä)', ru: '(необязательно)', en: '(optional)'),
                    ),
                    const SizedBox(height: 8),
                    _FormField(
                      controller: _noteController,
                      hint: t(tk: 'Müşderi barada bellik goşuň...', ru: 'Добавьте заметку о клиенте...', en: 'Add a note about this customer...'),
                      fillColor: tokens.surface,
                      maxLines: 4,
                      maxLength: 2000,
                      onChanged: () => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: _confirmDelete,
                        child: Text(
                          t(tk: 'Müşderini poz', ru: 'Удалить клиента', en: 'Delete customer'),
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
      bottomNavigationBar: keyboardOpen
          ? null
          : SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MasterActionButton(
                      label: _isEditing
                          ? t(tk: 'Ýatda sakla', ru: 'Сохранить', en: 'Save')
                          : t(tk: 'Dowam et', ru: 'Продолжить', en: 'Continue'),
                      enabled: _complete && !_saving,
                      leading: _isEditing ? Icons.save_outlined : null,
                      trailingArrow: !_isEditing,
                      onTap: _save,
                    ),
                    const SizedBox(height: 2),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        t(tk: 'Ýatyrmazdan yzyna dön', ru: 'Вернуться без сохранения', en: 'Go back without saving'),
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
            ),
    );
  }
}
