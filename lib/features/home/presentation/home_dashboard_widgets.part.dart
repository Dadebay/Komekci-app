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
                        currency: context
                            .watch<AppSettingsProvider>()
                            .currencyLabel(language),
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
  final String amount;
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
                '$amount $currency',
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
    this.showHeader = true,
  });
  final bool tk;
  final String title;
  final String dateLabel;
  final Color accent;
  final Color accentBg;
  final int count;
  final Widget child;

  /// Whether to show the collapsible "TITLE · date, N people" band above the
  /// table. The home dashboard's "today" card hides it — the day is already
  /// implied by the screen, so the band would just repeat "today".
  final bool showHeader;

  @override
  State<_DayTimelineCard> createState() => _DayTimelineCardState();
}

class _DayTimelineCardState extends State<_DayTimelineCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      // Explicit white, not the theme's surfaceElevated token — the header
      // band above (explicit `cream`) needs a color it visibly differs from
      // in every theme, not just the ones where surfaceElevated isn't cream.
      color: Colors.white,
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
        if (widget.showHeader)
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
        // No inset around the table: the header band and the rows run
        // edge to edge inside the day card, like a real table.
        if (!widget.showHeader || _expanded) widget.child,
      ],
    ),
  );
}

String _weekdayFullName(int weekday, AppLanguage language) =>
    switch (language) {
      AppLanguage.tk => _weekdaysFullTk[weekday - 1],
      AppLanguage.ru => _weekdaysFullRu[weekday - 1],
      AppLanguage.en => _weekdaysFullEn[weekday - 1],
    };

/// Today's queue as a plain vertical list — one full-width row per entry.
///
/// This used to be a literal six-column table ("№ / Müşderi we nik / Hyzmat /
/// Bellik / Wagt / Status") that had to scroll sideways on a phone, with
/// every cell squeezed into ~90px. Nothing was dropped in the rewrite: the
/// order number, customer + handle, service, note, time and status are all
/// still here — stacked into one card-like row that fits a phone's width, so
/// the master can scan the queue top-to-bottom with a thumb instead of
/// dragging the table left and right.

/// Left rail width — holds the order chip with the start time under it, so
/// the numbers and times line up straight down the list.
const _apptRailWidth = 46.0;

/// Horizontal inset every row (and the list's head band) applies, so the
/// content keeps a little air from the day card's edge.
const _apptRowInset = 14.0;

class _HomeApptTable extends StatelessWidget {
  const _HomeApptTable({
    required this.entries,
    required this.customers,
    required this.language,
    required this.onTapAppointment,
    required this.onTapFree,
  });

  final List<_TimelineEntry> entries;
  final List<Customer> customers;
  final AppLanguage language;

  /// Tapping a customer row opens the same actions sheet the Senenama
  /// (schedule) screen uses — it no longer navigates away from home.
  final void Function(Appointment appointment, Customer? customer)
  onTapAppointment;
  final VoidCallback onTapFree;

  @override
  Widget build(BuildContext context) {
    final busy = entries.whereType<_ApptEntry>().length;
    final free = entries.length - busy;
    return Column(
      children: [
        _ApptListHead(language: language, people: busy, freeSlots: free),
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
              onTap: () => onTapAppointment(entry.appointment, customer),
              showDivider: !isLast,
            );
          }
          final gap = entry as _FreeEntry;
          return _HomeFreeRow(
            index: index,
            start: gap.start,
            end: gap.end,
            language: language,
            onTap: onTapFree,
            showDivider: !isLast,
          );
        }),
      ],
    );
  }
}

/// Slim cream band above the queue — replaces the old 64px six-column header
/// row. There are no columns left to label, so it carries the one thing a
/// label row can't: how the day actually looks (N clients, M free gaps).
class _ApptListHead extends StatelessWidget {
  const _ApptListHead({
    required this.language,
    required this.people,
    required this.freeSlots,
  });
  final AppLanguage language;
  final int people;
  final int freeSlots;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Semantics(
      container: true,
      header: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: _apptRowInset,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: cream,
          border: Border(
            bottom: BorderSide(
              color: tokens.accent.withValues(alpha: .55),
              width: 2,
            ),
          ),
        ),
        child: Row(
          children: [
            AppIcon(Icons.format_list_numbered, size: 14, color: tokens.accent),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                pickTr(
                  language,
                  tk: 'NOBAT TERTIBI',
                  ru: 'ПОРЯДОК ОЧЕРЕДИ',
                  en: 'QUEUE ORDER',
                ).toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .3,
                  color: tokens.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '$people ${pickTr(language, tk: 'adam', ru: 'чел.', en: 'people')}'
              '${freeSlots == 0 ? '' : ' · $freeSlots ${pickTr(language, tk: 'boş', ru: 'своб.', en: 'free')}'}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: tokens.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// The numbered badge at the head of every row — a soft, tinted chip rather
/// than a bare digit. Rows tint it with their own status colours, so the
/// number doubles as a status cue you can scan straight down the queue.
class _ApptIndexChip extends StatelessWidget {
  const _ApptIndexChip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  static const _size = 28.0;

  @override
  Widget build(BuildContext context) => Container(
    width: _size,
    height: _size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

/// One booked slot: order chip + start time in the left rail, then the
/// customer, the service and (only when there is one) the note, with the
/// status pill on the right.
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
      AppointmentStatus.cancelled || AppointmentStatus.noShow => (
        const Color(0xffC0392B),
        const Color(0xffFBE3E0),
        Icons.close,
      ),
    };
    // Mirrors the reference design's single highlighted "in progress" row —
    // the client is on-site right now, so it's the one row worth calling out.
    final highlighted = appointment.status == AppointmentStatus.arrived;
    final minutesLabel = pickTr(language, tk: 'min', ru: 'мин', en: 'min');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: _apptRowInset,
        ),
        decoration: BoxDecoration(
          color: highlighted ? statusBg.withValues(alpha: .5) : null,
          border: showDivider
              ? Border(bottom: BorderSide(color: tokens.border))
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left rail: the queue position, with the slot's start and end
            // time under it — the two things the master scans for first.
            SizedBox(
              width: _apptRailWidth,
              child: Column(
                children: [
                  _ApptIndexChip(
                    label: '$index',
                    color: statusColor,
                    background: statusBg,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatTime(TimeOfDay.fromDateTime(appointment.startsAt)),
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: tokens.textPrimary,
                    ),
                  ),
                  Text(
                    formatTime(TimeOfDay.fromDateTime(appointment.endsAt)),
                    style: TextStyle(
                      fontSize: 10.5,
                      color: tokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      customer == null
                          ? CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xffE6D2B1),
                              child: AppIcon(
                                Icons.person_outline,
                                size: 15,
                                color: tokens.textPrimary,
                              ),
                            )
                          : _CustomerAvatar(customer: customer!, radius: 16),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              appointment.clientName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (customer != null)
                              Text(
                                _handleFor(customer!),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: tokens.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _ApptStatusPill(
                        label: _apptStatusLabel(appointment.status, language),
                        icon: statusIcon,
                        color: statusColor,
                        background: statusBg,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // The service is what the master is actually about to do,
                  // so it gets its own tinted chip instead of a narrow column
                  // that used to clip after two lines.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.accent.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        AppIcon(
                          Icons.content_cut,
                          size: 13,
                          color: tokens.accent,
                        ),
                        const SizedBox(width: 7),
                        Flexible(
                          child: Text(
                            appointment.serviceName,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: tokens.accent,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 7),
                        Text(
                          '${appointment.minutes} $minutesLabel',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tokens.accent.withValues(alpha: .75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (appointment.note.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: AppIcon(
                            Icons.sticky_note_2_outlined,
                            size: 13,
                            color: tokens.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            appointment.note,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: tokens.textSecondary,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status pill — label plus its icon, sized to its text so it can sit beside
/// the customer's name on any phone width.
class _ApptStatusPill extends StatelessWidget {
  const _ApptStatusPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppIcon(icon, size: 11, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

/// A free gap between two bookings — same left rail as [_HomeApptRow] so the
/// numbering and times stay in one line down the list, with the "Üýtgetmek"
/// action that opens the day in Senenama.
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
    final minutes = end.difference(start).inMinutes;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: _apptRowInset,
      ),
      decoration: BoxDecoration(
        color: freeSlotBg.withValues(alpha: .5),
        border: showDivider
            ? Border(bottom: BorderSide(color: tokens.border))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: _apptRailWidth,
            child: Column(
              children: [
                _ApptIndexChip(
                  label: '$index',
                  color: freeColor,
                  background: freeColor.withValues(alpha: .12),
                ),
                const SizedBox(height: 6),
                Text(
                  formatTime(TimeOfDay.fromDateTime(start)),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: freeColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppIcon(
                      Icons.schedule_outlined,
                      size: 14,
                      color: freeColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        pickTr(
                          language,
                          tk: 'Boş aralyk',
                          ru: 'Свободно',
                          en: 'Free slot',
                        ),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: freeColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${formatTime(TimeOfDay.fromDateTime(start))} – ${formatTime(TimeOfDay.fromDateTime(end))} · $minutes ${pickTr(language, tk: 'min', ru: 'мин', en: 'min')}',
                  style: TextStyle(
                    fontSize: 11,
                    color: freeColor.withValues(alpha: .8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: freeColor,
              side: const BorderSide(color: freeColor),
              backgroundColor: Colors.white,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              visualDensity: VisualDensity.compact,
            ),
            icon: const AppIcon(Icons.edit_outlined, size: 12),
            label: Text(
              pickTr(language, tk: 'Üýtgetmek', ru: 'Изменить', en: 'Edit'),
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
