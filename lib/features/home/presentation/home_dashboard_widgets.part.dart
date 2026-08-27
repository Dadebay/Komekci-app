part of '../../../app/komekci_app.dart';

/// Warm banner (avatar overlapping its lower edge) with the live clock and
/// date sitting below it — the master's "who am I, what time is it" panel.
class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.tk,
    required this.now,
    required this.today,
  });
  final bool tk;
  final DateTime now;
  final DateTime today;

  static const _avatarRadius = 34.0;
  static const _bannerHeight = 132.0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final balance = context.watch<BillingProvider>().balance;
    final masterName = context.watch<MasterProfileProvider>().name;
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: _bannerHeight,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xff5B3E24), Color(0xffB6803D)],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroChip(
                    icon: Icons.chat_bubble_outline,
                    label: t(tk: 'Habarlaşmak', ru: 'Написать', en: 'Message'),
                    onTap: () => Navigator.push(
                      context,
                      pageRoute(
                        SettingsScreen(
                          title: t(
                            tk: 'Goldaw',
                            ru: 'Поддержка',
                            en: 'Support',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: _HeroBalanceChip(
                        label: t(tk: 'Balans', ru: 'Баланс', en: 'Balance'),
                        amount: balance,
                        currency: t(tk: 'manat', ru: 'манат', en: 'TMT'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: -_avatarRadius,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: tokens.surface,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: _avatarRadius - 4,
                    backgroundColor: const Color(0xffE6D2B1),
                    child: AppIcon(
                      Icons.person_outline,
                      size: 28,
                      color: tokens.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _avatarRadius + 14),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$hh:$mm',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w800,
                color: tokens.accent,
                height: 1,
              ),
            ),
            Text(
              ':$ss',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: tokens.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '${today.day} ${_monthsFullTk[today.month - 1]} ${today.year}, $masterName',
          style: TextStyle(
            fontSize: 13,
            color: tokens.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// White pill action sitting on the hero banner — icon plus label, unlike
/// [IconActionButton] which is icon-only.
class _HeroChip extends StatelessWidget {
  const _HeroChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(30),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 15, color: const Color(0xff5B3E24)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xff5B3E24),
            ),
          ),
        ],
      ),
    ),
  );
}

/// White pill on the hero banner showing the wallet balance.
class _HeroBalanceChip extends StatelessWidget {
  const _HeroBalanceChip({
    required this.label,
    required this.amount,
    required this.currency,
  });
  final String label;
  final int amount;
  final String currency;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 9, color: Colors.black45),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '$amount.00 $currency',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff5B3E24),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xffFBF1D8),
            shape: BoxShape.circle,
          ),
          child: AppIcon(
            Icons.account_balance_wallet_outlined,
            size: 13,
            color: const Color(0xff5B3E24),
          ),
        ),
      ],
    ),
  );
}

class _HomeStatCard extends StatelessWidget {
  const _HomeStatCard({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.hint,
  });
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black.withValues(alpha: .05)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .06),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .14),
                shape: BoxShape.circle,
              ),
              child: AppIcon(icon, size: 15, color: color),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 11),
        Text(
          value,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: const TextStyle(fontSize: 10.5, color: Colors.black45),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

class _DayTimelineCard extends StatefulWidget {
  const _DayTimelineCard({
    required this.tk,
    required this.title,
    required this.dateLabel,
    required this.accent,
    required this.accentBg,
    required this.count,
    required this.child,
  });
  final bool tk;
  final String title;
  final String dateLabel;
  final Color accent;
  final Color accentBg;
  final int count;
  final Widget child;

  @override
  State<_DayTimelineCard> createState() => _DayTimelineCardState();
}

class _DayTimelineCardState extends State<_DayTimelineCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: context.appTokens.surfaceElevated,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: context.appTokens.border),
      boxShadow: [
        BoxShadow(
          color: context.appTokens.textPrimary.withValues(alpha: .03),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: widget.accentBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                AppIcon(
                  Icons.calendar_month_outlined,
                  size: 15,
                  color: widget.accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.title} · ${widget.dateLabel}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: widget.accent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${widget.count} ${pickTr(context.watch<LanguageProvider>().language, tk: "adam", ru: "человек", en: "people")}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: widget.accent,
                  ),
                ),
                const SizedBox(width: 6),
                AppIcon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 16,
                  color: widget.accent,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: widget.child,
          ),
      ],
    ),
  );
}

class _UpcomingDayRow extends StatelessWidget {
  const _UpcomingDayRow({
    required this.day,
    required this.count,
    required this.tk,
    required this.onTap,
  });
  final DateTime day;
  final int count;
  final bool tk;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: context.appTokens.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.appTokens.border),
      ),
      child: Row(
        children: [
          const AppIcon(
            Icons.calendar_today_outlined,
            size: 15,
            color: Colors.black45,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${formatDate(day)}, ${_weekdayFullName(day.weekday, context.watch<LanguageProvider>().language)}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '$count ${pickTr(context.watch<LanguageProvider>().language, tk: "adam", ru: "человек", en: "people")}',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          const AppIcon(Icons.chevron_right, size: 15, color: Colors.black26),
        ],
      ),
    ),
  );
}

String _weekdayFullName(int weekday, AppLanguage language) =>
    switch (language) {
      AppLanguage.tk => _weekdaysFullTk[weekday - 1],
      AppLanguage.ru => _weekdaysFullRu[weekday - 1],
      AppLanguage.en => _weekdaysFullEn[weekday - 1],
    };

/// One row of the home dashboard's "today" list — numbered, with the
/// client's avatar/nickname, service + note, time and a colored status
/// pill+icon, mirroring the columns of the reference table design.
// Column widths shared by the header and every data row so they line up
// while the table scrolls horizontally as one piece — a real "№ / Müşderi
// we nik / Hyzmat / Bellik / Wagt / Status" table instead of stacked cards,
// matching the original tablet mock this dashboard was adapted from.
const _apptColGap = 10.0;
const _apptColIndexWidth = 24.0;
const _apptColCustomerWidth = 146.0;
const _apptColServiceWidth = 96.0;
const _apptColNoteWidth = 112.0;
const _apptColTimeWidth = 56.0;
const _apptColStatusWidth = 108.0;
const _apptTableWidth =
    _apptColIndexWidth +
    _apptColCustomerWidth +
    _apptColServiceWidth +
    _apptColNoteWidth +
    _apptColTimeWidth +
    _apptColStatusWidth +
    _apptColGap * 5;

/// Today's timeline as a real multi-column table — scrolls horizontally so
/// every column keeps a fixed, readable width on a phone instead of
/// squeezing everything into a stacked card.
class _HomeApptTable extends StatelessWidget {
  const _HomeApptTable({
    required this.entries,
    required this.customers,
    required this.language,
    required this.onTap,
  });

  final List<_TimelineEntry> entries;
  final List<Customer> customers;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: SizedBox(
      width: _apptTableWidth,
      child: Column(
        children: [
          _ApptTableHeader(language: language),
          ...entries.asMap().entries.map((e) {
            final index = e.key + 1;
            final entry = e.value;
            final isLast = index == entries.length;
            if (entry is _ApptEntry) {
              final customer = entry.appointment.customerId == null
                  ? null
                  : _findCustomer(customers, entry.appointment.customerId!);
              return _HomeApptRow(
                index: index,
                appointment: entry.appointment,
                customer: customer,
                language: language,
                onTap: onTap,
                showDivider: !isLast,
              );
            }
            final free = entry as _FreeEntry;
            return _HomeFreeRow(
              index: index,
              start: free.start,
              end: free.end,
              language: language,
              onTap: onTap,
              showDivider: !isLast,
            );
          }),
        ],
      ),
    ),
  );
}

class _ApptTableHeader extends StatelessWidget {
  const _ApptTableHeader({required this.language});
  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    Widget cell(double width, String label, [IconData? icon]) => SizedBox(
      width: width,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            AppIcon(icon, size: 12, color: tokens.textSecondary),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: tokens.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: tokens.border)),
      ),
      child: Row(
        children: [
          cell(_apptColIndexWidth, '№'),
          const SizedBox(width: _apptColGap),
          cell(
            _apptColCustomerWidth,
            pickTr(language, tk: 'Müşderi we nik', ru: 'Клиент и ник', en: 'Customer & handle'),
            Icons.person_outline,
          ),
          const SizedBox(width: _apptColGap),
          cell(
            _apptColServiceWidth,
            pickTr(language, tk: 'Hyzmat', ru: 'Услуга', en: 'Service'),
            Icons.content_cut,
          ),
          const SizedBox(width: _apptColGap),
          cell(
            _apptColNoteWidth,
            pickTr(language, tk: 'Bellik', ru: 'Заметка', en: 'Note'),
            Icons.sticky_note_2_outlined,
          ),
          const SizedBox(width: _apptColGap),
          cell(
            _apptColTimeWidth,
            pickTr(language, tk: 'Wagt', ru: 'Время', en: 'Time'),
            Icons.schedule_outlined,
          ),
          const SizedBox(width: _apptColGap),
          cell(_apptColStatusWidth, pickTr(language, tk: 'Status', ru: 'Статус', en: 'Status')),
        ],
      ),
    );
  }
}

class _HomeApptRow extends StatelessWidget {
  const _HomeApptRow({
    required this.index,
    required this.appointment,
    required this.customer,
    required this.language,
    required this.onTap,
    required this.showDivider,
  });
  final int index;
  final Appointment appointment;
  final Customer? customer;
  final AppLanguage language;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final (statusColor, statusBg, statusIcon) = switch (appointment.status) {
      AppointmentStatus.completed => (
        freeSlotColorDark,
        freeSlotBg,
        Icons.check_circle,
      ),
      AppointmentStatus.arrived => (
        const Color(0xff2A5DB0),
        const Color(0xffE6EEFB),
        Icons.circle,
      ),
      AppointmentStatus.expected => (
        const Color(0xffB8720C),
        const Color(0xffFCEDD9),
        Icons.schedule_outlined,
      ),
      AppointmentStatus.cancelled ||
      AppointmentStatus.noShow => (
        const Color(0xffC0392B),
        const Color(0xffFBE3E0),
        Icons.close,
      ),
    };
    // Mirrors the reference table's single highlighted "in progress" row —
    // the client is on-site right now, so it's the one row worth calling out.
    final highlighted = appointment.status == AppointmentStatus.arrived;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: highlighted ? statusBg.withValues(alpha: .5) : null,
          border: showDivider
              ? Border(bottom: BorderSide(color: tokens.border))
              : null,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: _apptColIndexWidth,
                child: Text(
                  '$index',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: tokens.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: _apptColGap),
              SizedBox(
                width: _apptColCustomerWidth,
                child: Row(
                  children: [
                    customer == null
                        ? CircleAvatar(
                            radius: 15,
                            backgroundColor: const Color(0xffE6D2B1),
                            child: AppIcon(
                              Icons.person_outline,
                              size: 14,
                              color: tokens.textPrimary,
                            ),
                          )
                        : _CustomerAvatar(customer: customer!, radius: 15),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            appointment.clientName,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (customer != null)
                            Text(
                              '@${_handleFor(customer!)}',
                              style: TextStyle(fontSize: 10, color: tokens.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: _apptColGap),
              SizedBox(
                width: _apptColServiceWidth,
                child: Text(
                  appointment.serviceName,
                  style: TextStyle(fontSize: 11.5, color: tokens.textPrimary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: _apptColGap),
              SizedBox(
                width: _apptColNoteWidth,
                child: Text(
                  appointment.note.isEmpty ? '—' : appointment.note,
                  style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: _apptColGap),
              SizedBox(
                width: _apptColTimeWidth,
                child: Text(
                  formatTime(TimeOfDay.fromDateTime(appointment.startsAt)),
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                ),
              ),
              const SizedBox(width: _apptColGap),
              SizedBox(
                width: _apptColStatusWidth,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _apptStatusLabel(appointment.status, language),
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: statusColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(width: 5),
                      AppIcon(statusIcon, size: 12, color: statusColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A free-slot row on the home dashboard's table — same column layout as
/// [_HomeApptRow], with the "Boş aralyk" label spanning the customer/service
/// /note columns and an "Üýtgetmek" (edit) action in the status column.
class _HomeFreeRow extends StatelessWidget {
  const _HomeFreeRow({
    required this.index,
    required this.start,
    required this.end,
    required this.language,
    required this.onTap,
    required this.showDivider,
  });
  final int index;
  final DateTime start;
  final DateTime end;
  final AppLanguage language;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    const freeColor = Color(0xff2A5DB0);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: freeSlotBg.withValues(alpha: .5),
        border: showDivider ? Border(bottom: BorderSide(color: tokens.border)) : null,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: _apptColIndexWidth,
              child: Text(
                '$index',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: freeColor),
              ),
            ),
            const SizedBox(width: _apptColGap),
            SizedBox(
              width: _apptColCustomerWidth + _apptColGap + _apptColServiceWidth + _apptColGap + _apptColNoteWidth,
              child: Row(
                children: [
                  const AppIcon(Icons.schedule_outlined, size: 14, color: freeColor),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      pickTr(language, tk: 'Boş aralyk', ru: 'Свободно', en: 'Free slot'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: freeColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: _apptColGap),
            SizedBox(
              width: _apptColTimeWidth,
              child: Text(
                formatTime(TimeOfDay.fromDateTime(start)),
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: freeColor),
              ),
            ),
            const SizedBox(width: _apptColGap),
            SizedBox(
              width: _apptColStatusWidth,
              child: OutlinedButton.icon(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  foregroundColor: freeColor,
                  side: const BorderSide(color: freeColor),
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const AppIcon(Icons.edit_outlined, size: 12),
                label: Text(
                  pickTr(language, tk: 'Üýtgetmek', ru: 'Изменить', en: 'Edit'),
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
