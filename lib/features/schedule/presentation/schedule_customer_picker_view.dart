part of '../../../app/komekci_app.dart';

class _CustomerPickerSheet extends StatefulWidget {
  const _CustomerPickerSheet({required this.customers, required this.language});
  final List<Customer> customers;
  final AppLanguage language;

  @override
  State<_CustomerPickerSheet> createState() => _CustomerPickerSheetState();
}

class _CustomerPickerSheetState extends State<_CustomerPickerSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = widget.language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final query = _controller.text.trim().toLowerCase();
    final digits = query.replaceAll(RegExp(r'\D'), '');
    final results = query.isEmpty
        ? widget.customers
        : widget.customers
              .where(
                (c) =>
                    c.name.toLowerCase().contains(query) ||
                    (digits.isNotEmpty &&
                        c.phone.replaceAll(RegExp(r'\D'), '').contains(digits)),
              )
              .toList();
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: SizedBox(
          height: (MediaQuery.sizeOf(context).height - keyboardInset) * .82,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: tokens.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 12, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(
                              tk: 'Müşderi saýlaň',
                              ru: 'Выберите клиента',
                              en: 'Choose a customer',
                            ),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t(
                              tk: 'Ýazgy üçin müşderini tapyň',
                              ru: 'Найдите клиента для записи',
                              en: 'Find a customer for this booking',
                            ),
                            style: TextStyle(
                              fontSize: 12.5,
                              color: tokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: t(tk: 'Ýap', ru: 'Закрыть', en: 'Close'),
                      onPressed: () => Navigator.pop(context),
                      icon: AppIcon(
                        Icons.close,
                        size: 20,
                        color: tokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 52,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: tokens.surfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: tokens.border),
                  ),
                  child: TextField(
                    controller: _controller,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    style: TextStyle(fontSize: 14, color: tokens.textPrimary),
                    decoration: InputDecoration(
                      filled: false,
                      hintText: t(
                        tk: 'Ady ýa-da telefon belgisi',
                        ru: 'Имя или номер телефона',
                        en: 'Name or phone number',
                      ),
                      hintStyle: TextStyle(color: tokens.textSecondary),
                      prefixIcon: Center(
                        widthFactor: 1,
                        heightFactor: 1,
                        child: SizedBox.square(
                          dimension: 18,
                          child: AppIcon(
                            Icons.search,
                            size: 18,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                      suffixIcon: query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: t(
                                tk: 'Arassala',
                                ru: 'Очистить',
                                en: 'Clear',
                              ),
                              onPressed: () {
                                _controller.clear();
                                setState(() {});
                              },
                              icon: AppIcon(
                                Icons.close,
                                size: 18,
                                color: tokens.textSecondary,
                              ),
                            ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                child: Row(
                  children: [
                    Text(
                      query.isEmpty
                          ? t(
                              tk: 'Ähli müşderiler',
                              ru: 'Все клиенты',
                              en: 'All customers',
                            )
                          : t(
                              tk: 'Gözleg netijeleri',
                              ru: 'Результаты поиска',
                              en: 'Search results',
                            ),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: tokens.surfaceElevated,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Text(
                        '${results.length}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: tokens.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _CustomerPickerResults(results: results, query: query, language: language),
            ],
          ),
        ),
      ),
    );
  }
}
