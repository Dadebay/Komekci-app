part of '../../../app/komekci_app.dart';

/// Durations offered as quick-pick chips on the service form.
const _serviceDurations = [15, 20, 30, 45, 60, 90, 120, 150];

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final provider = context.watch<ServiceProvider>();
    final services = provider.services;
    final hidden = services.where((s) => !s.active).length;
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(title: t(tk: 'Hyzmatlar', ru: 'Услуги', en: 'Services')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, pageRoute(const ServiceFormScreen())),
        backgroundColor: tokens.accent,
        foregroundColor: tokens.accentOn,
        elevation: 4,
        icon: const AppIcon(Icons.add, size: 22),
        label: Text(
          t(tk: 'Täze hyzmat goş', ru: 'Добавить услугу', en: 'Add service'),
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          // Bottom room so the last card is not hidden behind the button.
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
          children: [
            if (services.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ServicesPill(
                    label: t(
                      tk: '${services.length} hyzmat',
                      ru: 'Услуг: ${services.length}',
                      en: '${services.length} services',
                    ),
                    color: tokens.accent,
                  ),
                  _ServicesPill(
                    label: t(
                      tk: '${services.length - hidden} görünýär',
                      ru: 'Видно: ${services.length - hidden}',
                      en: '${services.length - hidden} visible',
                    ),
                    color: tokens.success,
                  ),
                  if (hidden > 0)
                    _ServicesPill(
                      label: t(tk: '$hidden gizlin', ru: 'Скрыто: $hidden', en: '$hidden hidden'),
                      color: tokens.textSecondary,
                    ),
                ],
              ),
            ],
            if (services.isNotEmpty) const SizedBox(height: 14),
            if (services.isEmpty && provider.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
              )
            else if (services.isEmpty)
              EmptyState(
                icon: Icons.content_cut,
                title: t(tk: 'Heniz hyzmat ýok', ru: 'Услуг пока нет', en: 'No services yet'),
                text: t(
                  tk: 'Aşakdaky "Täze hyzmat goş" düwmesine basyp ilkinji hyzmatyňyzy goşuň.',
                  ru: 'Нажмите «Добавить услугу» внизу, чтобы создать первую услугу.',
                  en: 'Tap "Add service" below to create your first one.',
                ),
              )
            else
              ...services.map((service) => _ServiceCard(service: service)),
          ],
        ),
      ),
    );
  }
}

class _ServicesPill extends StatelessWidget {
  const _ServicesPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
  );
}
