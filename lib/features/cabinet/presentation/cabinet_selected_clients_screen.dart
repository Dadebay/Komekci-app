part of '../../../app/komekci_app.dart';

class SelectedClientsScreen extends StatefulWidget {
  const SelectedClientsScreen({
    super.key,
    this.initialSelection = const [],
    this.forPush = true,
  });
  final List<String> initialSelection;
  final bool forPush;

  @override
  State<SelectedClientsScreen> createState() => _SelectedClientsScreenState();
}

class _SelectedClientsScreenState extends State<SelectedClientsScreen> {
  final _searchController = TextEditingController();
  late final _selected = Set<String>.of(widget.initialSelection);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final query = _searchController.text.trim().toLowerCase();
    final provider = context.watch<CustomerProvider>();
    final clients = provider.customers
        .where(
          (c) =>
              query.isEmpty ||
              c.name.toLowerCase().contains(query) ||
              c.phone.contains(query),
        )
        .toList();
    final eligible = clients
        .where((c) => _canMessageCustomer(c, forPush: widget.forPush))
        .toList();
    final eligibleIds = provider.customers
        .where((c) => _canMessageCustomer(c, forPush: widget.forPush))
        .map((c) => c.id)
        .toSet();
    final selected = _selected.intersection(eligibleIds);
    final allSelected =
        eligible.isNotEmpty && eligible.every((c) => selected.contains(c.id));
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: AppStrings.cabinetSelectedClients.select(language),
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
                    icon: Icons.groups_outlined,
                    text: AppStrings.cabinetChooseClientsToSendTo.select(
                      language,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: AppStrings.cabinetSearch.select(language),
                      hintStyle: TextStyle(
                        color: tokens.textSecondary,
                        fontSize: 14,
                      ),
                      prefixIcon: Padding(
                        padding: EdgeInsets.all(13),
                        child: AppIcon(
                          Icons.search,
                          color: tokens.textSecondary,
                          size: 18,
                        ),
                      ),
                      filled: true,
                      fillColor: tokens.surfaceElevated,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: tokens.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: tokens.accent,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (provider.loading && provider.customers.isEmpty)
                    const Center(child: CircularProgressIndicator()),
                  if (provider.error != null && provider.customers.isEmpty)
                    RetryErrorState(
                      title: AppStrings.cabinetCouldNotLoadClients.select(
                        language,
                      ),
                      text: AppStrings.cabinetPleaseTryAgain.select(language),
                      retryLabel: AppStrings.profileTryAgain.select(language),
                      onRetry: provider.load,
                    ),
                  Row(
                    children: [
                      Text(
                        AppStrings.cabinetSelected(
                          selected.length,
                        ).select(language),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() {
                          if (allSelected) {
                            for (final c in eligible) {
                              _selected.remove(c.id);
                            }
                          } else {
                            for (final c in eligible) {
                              _selected.add(c.id);
                            }
                          }
                        }),
                        child: Row(
                          children: [
                            Text(
                              AppStrings.cabinetSelectAll.select(language),
                              style: TextStyle(
                                fontSize: 12.5,
                                color: tokens.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _CheckboxDot(checked: allSelected),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...clients.map((c) {
                    final canSend = _canMessageCustomer(
                      c,
                      forPush: widget.forPush,
                    );
                    final checked = canSend && selected.contains(c.id);
                    return _ClientListTile(
                      name: c.name,
                      phone: c.phone,
                      subtitle: !canSend
                          ? widget.forPush
                                ? AppStrings.cabinetPushUnavailable.select(
                                    language,
                                  )
                                : AppStrings.cabinetNoPhoneNumber.select(
                                    language,
                                  )
                          : c.lastVisit == null
                          ? ''
                          : '${AppStrings.cabinetLastVisit.select(language)}: ${c.lastVisit!.day}.${c.lastVisit!.month}.${c.lastVisit!.year}',
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
