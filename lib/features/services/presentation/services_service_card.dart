part of '../../../app/komekci_app.dart';

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});
  final SalonService service;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final provider = context.read<ServiceProvider>();
    final currency = context.watch<AppSettingsProvider>().currencyLabel(language);
    final tokens = context.appTokens;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 240),
      opacity: service.active ? 1 : .72,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: tokens.border),
          boxShadow: [
            BoxShadow(color: tokens.textPrimary.withValues(alpha: .04), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: ServiceThumb(service: service, size: 88),
                      ),
                      if (!service.active)
                        Positioned(
                          left: 6,
                          bottom: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              t(tk: 'Gizlin', ru: 'Скрыта', en: 'Hidden'),
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.25, color: tokens.textPrimary),
                        ),
                        if (service.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            service.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: tokens.textSecondary, height: 1.35),
                          ),
                        ],
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: tokens.accent.withValues(alpha: .16),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${service.price} $currency',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: tokens.textPrimary),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: tokens.border),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppIcon(Icons.timer_outlined, size: 13, color: tokens.textSecondary),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${service.minutes} min',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: tokens.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: tokens.border.withValues(alpha: .7)),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  SizedBox(
                    height: 30,
                    child: FittedBox(
                      child: Switch(
                        value: service.active,
                        activeThumbColor: tokens.accentOn,
                        activeTrackColor: tokens.accent,
                        onChanged: (_) => _toggle(context, provider),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      service.active
                          ? t(tk: 'Görünýär', ru: 'Видна', en: 'Visible')
                          : t(tk: 'Gizlin', ru: 'Скрыта', en: 'Hidden'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: service.active ? tokens.success : tokens.textSecondary,
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(context, pageRoute(ServiceFormScreen(service: service))),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tokens.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppIcon(Icons.edit_outlined, size: 14, color: tokens.textPrimary),
                          const SizedBox(width: 6),
                          Text(
                            t(tk: 'Üýtget', ru: 'Изменить', en: 'Edit'),
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _confirmDelete(context, service),
                    child: Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tokens.danger.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: tokens.danger.withValues(alpha: .3)),
                      ),
                      child: AppIcon(Icons.delete_outline, size: 16, color: tokens.danger),
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

  Future<void> _confirmDelete(BuildContext context, SalonService service) async {
    final language = context.read<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final provider = context.read<ServiceProvider>();
    final toast = AppToast.of(context);
    final confirmed = await _showConfirmDialog(
      context,
      icon: Icons.delete_outline,
      danger: true,
      title: t(tk: 'Hyzmaty pozmaly?', ru: 'Удалить услугу?', en: 'Delete this service?'),
      message: t(
        tk: '"${service.name}" hyzmaty sanawdan aýrylar.',
        ru: '«${service.name}» будет удалена из списка.',
        en: '"${service.name}" will be removed from the list.',
      ),
      confirmLabel: t(tk: 'Poz', ru: 'Удалить', en: 'Delete'),
      cancelLabel: t(tk: 'Ýatyr', ru: 'Отмена', en: 'Cancel'),
    );
    if (!confirmed) return;
    try {
      await provider.remove(service.id);
    } catch (error) {
      toast.error(apiErrorMessage(error, language));
    }
  }

  Future<void> _toggle(BuildContext context, ServiceProvider provider) async {
    final toast = AppToast.of(context);
    final language = context.read<LanguageProvider>().language;
    try {
      await provider.toggleActive(service.id);
    } catch (error) {
      toast.error(apiErrorMessage(error, language));
    }
  }
}

/// Renders a service picture from either a bundled asset or a picked file.
class ServiceThumb extends StatelessWidget {
  const ServiceThumb({super.key, required this.service, required this.size});
  final SalonService service;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (service.imageIsNetwork) {
      return Image.network(service.imagePath, width: size, height: size, fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholder(context));
    }
    if (service.imageIsAsset) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(service.imagePath, width: size, height: size, fit: BoxFit.cover),
      );
    }
    if (service.imagePath.isEmpty) return _placeholder(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.file(File(service.imagePath), width: size, height: size, fit: BoxFit.cover),
    );
  }

  // Centred and sized from the box: inside a tight box a bare icon would
  // stretch to fill all of it.
  Widget _placeholder(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    color: context.appTokens.surfaceElevated,
    child: AppIcon(Icons.image_outlined, size: (size * .4).clamp(16.0, 32.0), color: context.appTokens.disabled),
  );
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

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
          color: tokens.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tokens.border),
        ),
        child: AppIcon(icon, color: tokens.textPrimary, size: 15),
      ),
    );
  }
}
