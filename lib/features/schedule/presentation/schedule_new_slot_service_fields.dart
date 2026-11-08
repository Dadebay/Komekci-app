part of '../../../app/komekci_app.dart';

extension _NewSlotServiceFields on _NewSlotAppointmentSheetState {
  List<Widget> _serviceFields({required AppLanguage language, required List<SalonService> services}) {
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return [
                          _NewBookingSectionTitle(
                            number: 2,
                            title: t(
                              tk: 'Hyzmat saýlaň',
                              ru: 'Выберите услугу',
                              en: 'Choose a service',
                            ),
                          ),
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () => _pickService(services),
                            child: Container(
                              height: 66,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              decoration: BoxDecoration(
                                color: tokens.surfaceElevated,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _showErrors && _selectedService == null
                                      ? tokens.danger
                                      : _selectedService == null
                                      ? tokens.border
                                      : tokens.accent,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: tokens.accent.withValues(
                                        alpha: .12,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: AppIcon(
                                      Icons.content_cut,
                                      size: 18,
                                      color: tokens.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _selectedService?.name ??
                                              t(
                                                tk: 'Hyzmat saýlaň',
                                                ru: 'Выберите услугу',
                                                en: 'Choose a service',
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: tokens.textPrimary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (_selectedService != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            '${_selectedService!.minutes} ${t(tk: "min", ru: "мин", en: "min")} · ${_selectedService!.price} ${context.watch<AppSettingsProvider>().currencyLabel(language)}',
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: tokens.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  AppIcon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: tokens.textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (_showErrors && _selectedService == null)
                            _ErrorText(language: language),
                          const SizedBox(height: 22),
    ];
  }
}
