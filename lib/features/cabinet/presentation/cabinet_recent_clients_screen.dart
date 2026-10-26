part of '../../../app/komekci_app.dart';

class RecentClientsScreen extends StatefulWidget {
  const RecentClientsScreen({super.key, this.initialSelection = const [], this.forPush = true});
  final List<String> initialSelection;
  final bool forPush;

  @override
  State<RecentClientsScreen> createState() => _RecentClientsScreenState();
}

class _RecentClientsScreenState extends State<RecentClientsScreen> {
  int _period = 0; // 0:7d 1:30d 2:3m 3:6m
  late final _selected = Set<String>.of(widget.initialSelection);

  static const _periodDays = [7, 30, 90, 180];

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final periodLabels = switch (language) {
      AppLanguage.tk => ['7 gün', '30 gün', '3 aý', '6 aý'],
      AppLanguage.ru => ['7 дней', '30 дней', '3 мес.', '6 мес.'],
      AppLanguage.en => ['7 days', '30 days', '3 mo.', '6 mo.'],
    };
    final cutoff = DateTime.now().subtract(Duration(days: _periodDays[_period]));
    final clients = context.watch<CustomerProvider>().customers
        .where((c) => c.lastVisit != null && !c.lastVisit!.isBefore(cutoff))
        .toList();
    final eligibleIds = clients
        .where((c) => _canMessageCustomer(c, forPush: widget.forPush))
        .map((c) => c.id)
        .toSet();
    final selected = _selected.intersection(eligibleIds);
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(
          tk: 'Soňky müşderiler',
          ru: 'Недавние клиенты',
          en: 'Recent clients',
        ),
        action: _HelpIconButton(
          onTap: () =>
              Navigator.push(context, pageRoute(const SupportScreen())),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _InfoBanner(
                    icon: Icons.schedule_outlined,
                    text: t(
                      tk: 'Soňky haçan hyzmat alan müşderileriňize habar iberiň.',
                      ru: 'Отправьте сообщение клиентам, которые недавно получали услугу.',
                      en: 'Send a message to clients who recently received a service.',
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    t(
                      tk: 'Döwrüni saýlaň',
                      ru: 'Выберите период',
                      en: 'Choose a period',
                    ),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(periodLabels.length, (index) {
                      final selected = _period == index;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            right: index == periodLabels.length - 1 ? 0 : 8,
                          ),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _period = index;
                              _selected.clear();
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? tokens.textPrimary
                                    : tokens.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? tokens.textPrimary
                                      : tokens.border,
                                ),
                              ),
                              child: Text(
                                periodLabels[index],
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? tokens.surface
                                      : tokens.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    t(
                      tk: 'Soňky ${periodLabels[_period]} içinde hyzmat alanlar (${clients.length})',
                      ru: 'Клиенты за последние ${periodLabels[_period]} (${clients.length})',
                      en: 'Clients from the last ${periodLabels[_period]} (${clients.length})',
                    ),
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...clients.map((c) {
                    final canSend = _canMessageCustomer(c, forPush: widget.forPush);
                    final checked = canSend && selected.contains(c.id);
                    return _ClientListTile(
                      name: c.name,
                      phone: c.phone,
                      subtitle: !canSend
                          ? widget.forPush
                              ? t(tk: 'Push üçin elýeterli däl', ru: 'Push недоступен', en: 'Push unavailable')
                              : t(tk: 'Telefon belgisi ýok', ru: 'Нет номера телефона', en: 'No phone number')
                          : '${t(tk: "Soňky sapar", ru: "Последний визит", en: "Last visit")}: ${c.lastVisit!.day}.${c.lastVisit!.month}.${c.lastVisit!.year}',
                      checked: checked,
                      enabled: canSend,
                      onTap: canSend
                          ? () => setState(() {
                              if (checked) {
                                _selected.remove(c.id);
                              } else {
                                _selected.add(c.id);
                              }
                            })
                          : null,
                    );
                  }),
                  const SizedBox(height: 8),
                  _InfoBanner(
                    icon: Icons.info_outline,
                    text: t(
                      tk: 'Bir gezekde 50 müşdera çenli habar iberip bilersiňiz.',
                      ru: 'За раз можно отправить сообщение максимум 50 клиентам.',
                      en: 'You can message up to 50 clients at a time.',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label:
                    '${t(tk: "Dowam et", ru: "Продолжить", en: "Continue")} (${selected.length})',
                enabled: selected.isNotEmpty && selected.length <= 50,
                onTap: () => Navigator.pop(context, selected.toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
