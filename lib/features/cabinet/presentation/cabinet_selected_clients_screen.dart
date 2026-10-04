part of '../../../app/komekci_app.dart';

class SelectedClientsScreen extends StatefulWidget {
  const SelectedClientsScreen({super.key, this.initialSelection = const []});
  final List<String> initialSelection;

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
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final query = _searchController.text.trim().toLowerCase();
    final clients = _mockClients
        .where(
          (c) =>
              query.isEmpty ||
              c.name.toLowerCase().contains(query) ||
              c.phone.contains(query),
        )
        .toList();
    final allSelected =
        clients.isNotEmpty && clients.every((c) => _selected.contains(c.name));
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(
          tk: 'Saýlanan müşderiler',
          ru: 'Выбранные клиенты',
          en: 'Selected clients',
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
                    icon: Icons.groups_outlined,
                    text: t(
                      tk: 'Habar ibermek üçin müşderileri saýlaň. Soňra habar tekstini ýazyň we iberiň.',
                      ru: 'Выберите клиентов для отправки. Затем напишите текст сообщения и отправьте.',
                      en: 'Choose clients to send to. Then write the message text and send it.',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: t(tk: 'Gözleg', ru: 'Поиск', en: 'Search'),
                      hintStyle: const TextStyle(
                        color: Colors.black38,
                        fontSize: 14,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(13),
                        child: AppIcon(
                          Icons.search,
                          color: Colors.black38,
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
                  Row(
                    children: [
                      Text(
                        t(
                          tk: 'Saýlananlar: ${_selected.length}',
                          ru: 'Выбрано: ${_selected.length}',
                          en: 'Selected: ${_selected.length}',
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() {
                          if (allSelected) {
                            for (final c in clients) {
                              _selected.remove(c.name);
                            }
                          } else {
                            for (final c in clients) {
                              _selected.add(c.name);
                            }
                          }
                        }),
                        child: Row(
                          children: [
                            Text(
                              t(
                                tk: 'Ählisini saýlamak',
                                ru: 'Выбрать всех',
                                en: 'Select all',
                              ),
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Colors.black54,
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
                    final checked = _selected.contains(c.name);
                    return _ClientListTile(
                      name: c.name,
                      phone: c.phone,
                      subtitle:
                          '${t(tk: "Soňky gezek", ru: "Последний визит", en: "Last visit")}: ${c.lastVisitDate}',
                      checked: checked,
                      onTap: () => setState(() {
                        if (checked) {
                          _selected.remove(c.name);
                        } else {
                          _selected.add(c.name);
                        }
                      }),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label:
                    '${t(tk: "Dowam et", ru: "Продолжить", en: "Continue")} (${_selected.length})',
                enabled: _selected.isNotEmpty,
                onTap: () => Navigator.pop(context, _selected.toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
