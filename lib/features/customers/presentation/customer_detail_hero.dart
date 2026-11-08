part of '../../../app/komekci_app.dart';

class _CustomerDetailHero extends StatelessWidget {
  const _CustomerDetailHero({required this.customer, required this.language});

  final Customer customer;
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final statusColor = _statusColor(customer.status, tokens);
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _statusBg(customer.status, tokens),
                          tokens.surfaceElevated,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: tokens.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: statusColor,
                                  width: 2,
                                ),
                              ),
                              child: _CustomerAvatar(
                                customer: customer,
                                radius: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    customer.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      AppIcon(
                                        Icons.phone_outlined,
                                        size: 12,
                                        color: tokens.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        customer.phone.isEmpty
                                            ? '—'
                                            : displayPhone(customer.phone),
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: tokens.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  _StatusPill(
                                    status: customer.status,
                                    language: language,
                                  ),
                                ],
                              ),
                            ),
                            _SquareIconButton(
                              icon: Icons.edit_outlined,
                              onTap: () => Navigator.push(
                                context,
                                pageRoute(
                                  CustomerFormScreen(customer: customer),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          height: 1,
                          color: tokens.surfaceElevated.withValues(alpha: .7),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _HeaderStat(
                                value: '${customer.totalVisits}',
                                label: t(tk: 'Sapar', ru: 'Визитов', en: 'Visits'),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: tokens.surfaceElevated.withValues(
                                alpha: .7,
                              ),
                            ),
                            Expanded(
                              child: _HeaderStat(
                                value: '${customer.totalSpent}',
                                label: t(tk: 'Manat', ru: 'Манат', en: 'Manat'),
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 30,
                              color: tokens.surfaceElevated.withValues(
                                alpha: .7,
                              ),
                            ),
                            Expanded(
                              child: _HeaderStat(
                                value: customer.lastVisitDate == null
                                    ? '—'
                                    : formatDate(customer.lastVisitDate!),
                                label: t(tk: 'Soňky sapar', ru: 'Последний визит', en: 'Last visit'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
  }
}
