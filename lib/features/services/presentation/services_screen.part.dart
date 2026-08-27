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
    final services = context.watch<ServiceProvider>().services;
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Hyzmatlar', ru: 'Услуги', en: 'Services'),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          // Extra bottom room clears the floating nav bar when shown as a tab.
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            Navigator.of(context).canPop() ? 28 : 110,
          ),
          children: [
            _MasterActionButton(
              label: t(
                tk: 'Täze hyzmat goş',
                ru: 'Добавить услугу',
                en: 'Add service',
              ),
              enabled: true,
              leading: Icons.add,
              onTap: () => Navigator.push(
                context,
                pageRoute(const ServiceFormScreen()),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              t(
                tk: 'Goşulan hyzmatlar (${services.length})',
                ru: 'Добавленные услуги (${services.length})',
                en: 'Added services (${services.length})',
              ),
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            if (services.isEmpty)
              EmptyState(
                icon: Icons.content_cut,
                title: t(
                  tk: 'Heniz hyzmat ýok',
                  ru: 'Услуг пока нет',
                  en: 'No services yet',
                ),
                text: t(
                  tk: 'Ilkinji hyzmatyňyzy goşuň.',
                  ru: 'Добавьте первую услугу.',
                  en: 'Add your first service.',
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

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final SalonService service;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final provider = context.read<ServiceProvider>();
    final tokens = context.appTokens;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 240),
      opacity: service.active ? 1 : .55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: tokens.border),
          boxShadow: [
            BoxShadow(
              color: tokens.textPrimary.withValues(alpha: .04),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ServiceThumb(service: service, size: 74),
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
                      height: 1.25,
                    ),
                  ),
                  if (service.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Colors.black45,
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${service.price} ${t(tk: "manat", ru: "манат", en: "TMT")}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const AppIcon(
                        Icons.schedule_outlined,
                        color: Colors.black45,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${service.minutes} min',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                SizedBox(
                  height: 30,
                  child: FittedBox(
                    child: Switch(
                      value: service.active,
                      activeThumbColor: tokens.surface,
                      activeTrackColor: tokens.textPrimary,
                      onChanged: (_) => provider.toggleActive(service.id),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _SquareIconButton(
                  icon: Icons.edit_outlined,
                  onTap: () => Navigator.push(
                    context,
                    pageRoute(ServiceFormScreen(service: service)),
                  ),
                ),
                const SizedBox(height: 6),
                _SquareIconButton(
                  icon: Icons.delete_outline,
                  danger: true,
                  onTap: () => _confirmDelete(context, service),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SalonService service,
  ) async {
    final language = context.read<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final provider = context.read<ServiceProvider>();
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.delete_outline,
      danger: true,
      title: t(
        tk: 'Hyzmaty pozmaly?',
        ru: 'Удалить услугу?',
        en: 'Delete this service?',
      ),
      message: t(
        tk: '"${service.name}" hyzmaty sanawdan aýrylar.',
        ru: '«${service.name}» будет удалена из списка.',
        en: '"${service.name}" will be removed from the list.',
      ),
      confirmLabel: t(tk: 'Poz', ru: 'Удалить', en: 'Delete'),
      cancelLabel: t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel'),
    );
    if (confirmed) provider.remove(service.id);
  }
}

/// Renders a service picture from either a bundled asset or a picked file.
class ServiceThumb extends StatelessWidget {
  const ServiceThumb({super.key, required this.service, required this.size});
  final SalonService service;
  final double size;

  @override
  Widget build(BuildContext context) => service.imageIsAsset
      ? Image.asset(
          service.imagePath,
          width: size,
          height: size,
          fit: BoxFit.cover,
        )
      : Image.file(
          File(service.imagePath),
          width: size,
          height: size,
          fit: BoxFit.cover,
        );
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.icon,
    required this.onTap,
    this.danger = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: danger ? const Color(0xffFDF0EE) : tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: danger ? const Color(0xffF3D6D1) : tokens.border,
          ),
        ),
        child: AppIcon(
          icon,
          color: danger ? const Color(0xffC0392B) : tokens.textPrimary,
          size: 15,
        ),
      ),
    );
  }
}

