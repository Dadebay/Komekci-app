part of '../../../app/komekci_app.dart';

// ── Step 1 — service selection ──────────────────────────────────────────────

class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key,
    this.masterName = 'Aida Saparova',
    this.preselectedServiceName,
  });
  final String masterName;
  final String? preselectedServiceName;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String? _selectedId;
  bool _preselectApplied = false;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final services = context
        .watch<ServiceProvider>()
        .services
        .where((s) => s.active)
        .toList();
    if (!_preselectApplied && widget.preselectedServiceName != null) {
      _preselectApplied = true;
      for (final s in services) {
        if (s.name == widget.preselectedServiceName) {
          _selectedId = s.id;
          break;
        }
      }
    }
    SalonService? selected;
    for (final s in services) {
      if (s.id == _selectedId) selected = s;
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const AppIcon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 18),
              child: _WizardSteps(
                current: 1,
                labels: [
                  t(tk: 'Hyzmat', ru: 'Услуга', en: 'Service'),
                  t(tk: 'Wagt', ru: 'Время', en: 'Time'),
                  t(tk: 'Tassykla', ru: 'Подтв.', en: 'Confirm'),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  Text(
                    t(
                      tk: 'Hyzmaty saýlaň',
                      ru: 'Выберите услугу',
                      en: 'Select a service',
                    ),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.masterName,
                    style: TextStyle(color: tokens.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  if (services.isEmpty)
                    EmptyState(
                      icon: Icons.content_cut,
                      title: t(
                        tk: 'Hyzmat ýok',
                        ru: 'Услуг нет',
                        en: 'No services',
                      ),
                      text: t(
                        tk: 'Bu master heniz hyzmat goşmady.',
                        ru: 'Мастер пока не добавил услуги.',
                        en: 'This master hasn’t added any services yet.',
                      ),
                    )
                  else
                    ...services.map(
                      (s) => _ServiceOption(
                        service: s,
                        selected: s.id == _selectedId,
                        tk: language == AppLanguage.tk,
                        onTap: () => setState(() => _selectedId = s.id),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 10, 24, 14),
          child: SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: tokens.textPrimary,
                shape: const StadiumBorder(),
              ),
              onPressed: selected == null
                  ? null
                  : () => Navigator.push(
                      context,
                      pageRoute(
                        BookingDateTimeScreen(
                          service: selected!,
                          masterName: widget.masterName,
                        ),
                      ),
                    ),
              child: Text(
                t(tk: 'Dowam et', ru: 'Далее', en: 'Continue'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServiceOption extends StatelessWidget {
  const _ServiceOption({
    required this.service,
    required this.selected,
    required this.tk,
    required this.onTap,
  });
  final SalonService service;
  final bool selected;
  final bool tk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? t.surfaceElevated : t.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? t.accent : t.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ServiceThumb(service: service, size: 66),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (service.description.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: t.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      AppIcon(
                        Icons.schedule_outlined,
                        size: 13,
                        color: t.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.minutes} ${pickTr(context.watch<LanguageProvider>().language, tk: "min", ru: "мин", en: "min")}',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: t.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${service.price} ${pickTr(context.watch<LanguageProvider>().language, tk: "manat", ru: "манат", en: "TMT")}',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppIcon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? t.accent : t.disabled,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

