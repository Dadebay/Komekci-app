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
    final periodLabels = switch (language) {
      AppLanguage.tk => AppStrings.recentPeriodLabelsTk,
      AppLanguage.ru => AppStrings.recentPeriodLabelsRu,
      AppLanguage.en => AppStrings.recentPeriodLabelsEn,
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
        title: AppStrings.cabinetRecentClients.select(language),
        action: AppHelpButton(
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
                    text: AppStrings.cabinetSendAMessageToClients.select(language),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AppStrings.cabinetChooseAPeriod.select(language),
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
                    AppStrings.cabinetClientsFromTheLast(periodLabels[_period], clients.length).select(language),
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
                              ? AppStrings.cabinetPushUnavailable.select(language)
                              : AppStrings.cabinetNoPhoneNumber.select(language)
                          : '${AppStrings.cabinetLastVisit2.select(language)}: ${c.lastVisit!.day}.${c.lastVisit!.month}.${c.lastVisit!.year}',
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
                    text: AppStrings.cabinetYouCanMessageUpTo.select(language),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: MasterActionButton(
                label:
                    '${AppStrings.cabinetContinue.select(language)} (${selected.length})',
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
