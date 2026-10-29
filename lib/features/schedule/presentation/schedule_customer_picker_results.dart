part of '../../../app/komekci_app.dart';

class _CustomerPickerResults extends StatelessWidget {
  const _CustomerPickerResults({required this.results, required this.query, required this.language});

  final List<Customer> results;
  final String query;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return Expanded(
                child: results.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: tokens.surfaceElevated,
                                  shape: BoxShape.circle,
                                ),
                                child: AppIcon(
                                  query.isEmpty
                                      ? Icons.people_outline
                                      : Icons.person_search_outlined,
                                  size: 27,
                                  color: tokens.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                t(
                                  tk: 'Müşderi tapylmady',
                                  ru: 'Клиенты не найдены',
                                  en: 'No customers found',
                                ),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: tokens.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                query.isEmpty
                                    ? t(
                                        tk: 'Entek müşderi goşulmady',
                                        ru: 'Клиенты ещё не добавлены',
                                        en: 'No customers added yet',
                                      )
                                    : t(
                                        tk: 'Başga at ýa-da belgi bilen gözläň',
                                        ru: 'Попробуйте другое имя или номер',
                                        en: 'Try another name or number',
                                      ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          16 + MediaQuery.paddingOf(context).bottom,
                        ),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        itemCount: results.length,
                        itemBuilder: (_, i) {
                          final c = results[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: tokens.surfaceElevated,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: BorderSide(color: tokens.border),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () => Navigator.pop(context, c),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 11,
                                  ),
                                  child: Row(
                                    children: [
                                      _CustomerAvatar(customer: c, radius: 22),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              c.name,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w700,
                                                color: tokens.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              c.phone,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: tokens.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _StatusBadge2(
                                        label: _statusLabel(c.status, language),
                                        color: _statusColor(c.status, tokens),
                                        bg: _statusBg(c.status, tokens),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              );
  }
}
