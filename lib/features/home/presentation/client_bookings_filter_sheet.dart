part of '../../../app/komekci_app.dart';

extension _ClientBookingsFilterSheet on _ClientBookingsScreenState {
  void _showFilterSheet(BuildContext context, {required AppLanguage language, required List<String> masters, required StateSetter update}) {
    final tokens = context.appTokens;
    showDialog(
      context: context,
      barrierColor: tokens.scrim,
      // StatefulBuilder gives the dialog its own setState so tapping a chip
      // repaints it as selected immediately, while still writing into the
      // parent's state (via the outer setState) so the list behind it updates too.
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
          void select(VoidCallback change) {
            update(change);
            setDialogState(() {});
          }

          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 420, maxHeight: 560),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              decoration: BoxDecoration(color: tokens.surfaceElevated, borderRadius: BorderRadius.circular(26)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t(tk: 'Süzgüç', ru: 'Фильтр', en: 'Filter'),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: AppIcon(Icons.close, size: 18, color: tokens.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t(tk: 'Master', ru: 'Мастер', en: 'Master'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChipButton(
                                label: t(tk: 'Ähli', ru: 'Все', en: 'All'),
                                selected: _filterMaster == null,
                                onTap: () => select(() {
                                  _filterMaster = null;
                                  _visibleCount = _ClientBookingsScreenState._pageSize;
                                }),
                              ),
                              ...masters.map(
                                (m) => _FilterChipButton(
                                  label: m,
                                  selected: _filterMaster == m,
                                  onTap: () => select(() {
                                    _filterMaster = m;
                                    _visibleCount = _ClientBookingsScreenState._pageSize;
                                  }),
                                ),
                              ),
                            ],
                          ),
                          if (_showPast) ...[
                          const SizedBox(height: 18),
                          Text(
                            t(tk: 'Ýagdaý', ru: 'Статус', en: 'Status'),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _FilterChipButton(
                                label: t(tk: 'Ähli', ru: 'Все', en: 'All'),
                                selected: _filterStatus == null,
                                onTap: () => select(() {
                                  _filterStatus = null;
                                  _visibleCount = _ClientBookingsScreenState._pageSize;
                                }),
                              ),
                              _FilterChipButton(
                                label: t(tk: 'Tassyklanan', ru: 'Подтверждено', en: 'Confirmed'),
                                selected: _filterStatus == ClientBookingStatus.expected,
                                onTap: () => select(() {
                                  _filterStatus = ClientBookingStatus.expected;
                                  _visibleCount = _ClientBookingsScreenState._pageSize;
                                }),
                              ),
                              _FilterChipButton(
                                label: t(tk: 'Tamamlandy', ru: 'Завершено', en: 'Completed'),
                                selected: _filterStatus == ClientBookingStatus.completed,
                                onTap: () => select(() {
                                  _filterStatus = ClientBookingStatus.completed;
                                  _visibleCount = _ClientBookingsScreenState._pageSize;
                                }),
                              ),
                              _FilterChipButton(
                                label: t(tk: 'Ýatyryldy', ru: 'Отменено', en: 'Cancelled'),
                                selected: _filterStatus == ClientBookingStatus.cancelled,
                                onTap: () => select(() {
                                  _filterStatus = ClientBookingStatus.cancelled;
                                  _visibleCount = _ClientBookingsScreenState._pageSize;
                                }),
                              ),
                            ],
                          ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: tokens.border),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () => select(() {
                              _filterMaster = null;
                              _filterStatus = null;
                              _visibleCount = _ClientBookingsScreenState._pageSize;
                            }),
                            child: Text(
                              t(tk: 'Arassala', ru: 'Сбросить', en: 'Clear'),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tokens.textPrimary),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SizedBox(
                          height: 46,
                          child: FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: tokens.textPrimary, shape: const StadiumBorder()),
                            onPressed: () => Navigator.pop(dialogContext),
                            child: Text(
                              t(tk: 'Ulan', ru: 'Применить', en: 'Apply'),
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.surface),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
