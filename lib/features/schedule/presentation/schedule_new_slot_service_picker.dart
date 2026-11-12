part of '../../../app/komekci_app.dart';

extension _NewSlotServicePicker on _NewSlotAppointmentSheetState {
  Future<void> _showServicePicker(
    List<SalonService> services, {
    required StateSetter update,
  }) async {
    final language = context.read<LanguageProvider>().language;
    final tokens = context.appTokens;
    final picked = await showModalBottomSheet<SalonService>(
      context: context,
      backgroundColor: tokens.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 16),
              Text(
                AppStrings.scheduleChooseAService.select(language),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              if (services.isEmpty)
                EmptyState(
                  icon: Icons.content_cut,
                  title: AppStrings.bookingNoServices.select(language),
                  text: AppStrings.scheduleAddAServiceFirst.select(language),
                )
              else
                ...services.map((s) {
                  final fits = _serviceFits(s);
                  return ListTile(
                    enabled: fits,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      s.name,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      fits
                          ? '${s.minutes} ${AppStrings.bookingMin2.select(language)} · ${s.price} ${context.read<AppSettingsProvider>().currencyLabel(language)}'
                          : AppStrings.scheduleNotEnoughTimeForThis.select(
                              language,
                            ),
                      style: TextStyle(
                        fontSize: 12,
                        color: fits ? tokens.textSecondary : tokens.danger,
                      ),
                    ),
                    trailing: _selectedService?.id == s.id
                        ? AppIcon(Icons.check, color: tokens.accent)
                        : null,
                    onTap: fits ? () => Navigator.pop(sheetContext, s) : null,
                  );
                }),
            ],
          ),
        ),
      ),
    );
    if (picked != null) update(() => _selectedService = picked);
  }
}
