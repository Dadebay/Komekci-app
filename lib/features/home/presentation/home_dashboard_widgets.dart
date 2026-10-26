part of '../../../app/komekci_app.dart';

/// Warm banner (avatar overlapping its lower edge) with the live clock and
/// date sitting below it — the master's "who am I, what time is it" panel.
class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.tk,
    required this.now,
    required this.today,
    required this.refreshingNumbers,
    required this.numberShimmer,
    required this.numberCountUp,
  });
  final bool tk;
  final DateTime now;
  final DateTime today;
  final bool refreshingNumbers;
  final Animation<double> numberShimmer;
  final Animation<double> numberCountUp;

  static const _avatarRadius = 30.0;
  static const _bannerHeight = 144.0;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final balance = context.watch<BillingProvider>().balance;
    final profile = context.watch<MasterProfileProvider>();
    final masterName = profile.name;
    final banner = profile.banner;
    final bannerUrl = profile.bannerUrl;
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final months = switch (language) {
      AppLanguage.tk => _monthsFullTk,
      AppLanguage.ru => _monthsFullRu,
      AppLanguage.en => _monthsFullEn,
    };
    final weekdays = switch (language) {
      AppLanguage.tk => _weekdaysFullTk,
      AppLanguage.ru => _weekdaysFullRu,
      AppLanguage.en => _weekdaysFullEn,
    };

    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: double.infinity,
              height: _bannerHeight,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tokens.brightness == Brightness.dark
                        ? tokens.surfaceElevated
                        : Color.lerp(tokens.textPrimary, tokens.accent, .25)!,
                    tokens.brightness == Brightness.dark
                        ? Color.lerp(tokens.surfaceElevated, tokens.accent, .5)!
                        : tokens.accent,
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (banner != null)
                    Image.file(banner, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink())
                  else if (bannerUrl != null)
                    Image.network(bannerUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroChip(
                          icon: Icons.chat_bubble_outline,
                          label: t(tk: 'Habarlaşmak', ru: 'Связаться', en: 'Contact us'),
                          onTap: () => Navigator.push(
                            context,
                            pageRoute(const SupportScreen()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Align(
                            alignment: Alignment.topRight,
                            child: _HeroBalanceChip(
                              refreshingNumbers: refreshingNumbers,
                              numberShimmer: numberShimmer,
                              numberCountUp: numberCountUp,
                              amount: balance,
                              currency: context
                                  .watch<AppSettingsProvider>()
                                  .currencyLabel(language),
                              onTap: () => Navigator.push(
                                context,
                                pageRoute(const BillingScreen()),
                              ),
                            ),
                          ),
                        ),
                      ],
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
                  child: RoundPhoto(
                    file: profile.avatar,
                    url: profile.avatarUrl,
                    radius: _avatarRadius - 4,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: _avatarRadius + 5),
        Text(
          masterName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: tokens.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '$hh:$mm',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: tokens.textPrimary, height: 1),
                ),
              ),
            ),
            Container(
              width: 1,
              height: 38,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: tokens.border,
            ),
            Expanded(
              child: Row(
                children: [
                  AppIcon(Icons.calendar_today_outlined, size: 18, color: tokens.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${today.day} ${months[today.month - 1]} ${today.year}',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: tokens.textPrimary),
                        ),
                        Text(
                          weekdays[today.weekday - 1],
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: tokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
        color: context.appTokens.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(icon, size: 15, color: context.appTokens.textPrimary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: context.appTokens.textPrimary,
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
    required this.refreshingNumbers,
    required this.numberShimmer,
    required this.numberCountUp,
    required this.amount,
    required this.currency,
    required this.onTap,
  });
  final bool refreshingNumbers;
  final Animation<double> numberShimmer;
  final Animation<double> numberCountUp;
  final String amount;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: context.appTokens.surface,
    borderRadius: BorderRadius.circular(30),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: _DashboardNumber(
                loading: refreshingNumbers,
                shimmer: numberShimmer,
                countUp: numberCountUp,
                value: amount,
                suffix: ' $currency',
                color: context.appTokens.textPrimary,
                placeholderWidth: 56,
                placeholderHeight: 14,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: context.appTokens.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 4),
            AppIcon(
              Icons.account_balance_wallet_outlined,
              size: 15,
              color: context.appTokens.textPrimary,
            ),
          ],
        ),
      ),
    ),
  );
}

class _HomeStatCard extends StatelessWidget {
  const _HomeStatCard({
    required this.refreshingNumbers,
    required this.numberShimmer,
    required this.numberCountUp,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.hint,
  });
  final bool refreshingNumbers;
  final Animation<double> numberShimmer;
  final Animation<double> numberCountUp;
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(11),
    decoration: BoxDecoration(
      color: context.appTokens.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: context.appTokens.border),
      boxShadow: [
        BoxShadow(
          color: context.appTokens.textPrimary.withValues(alpha: .06),
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
              width: 28,
              height: 28,
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
                style: TextStyle(
                  fontSize: 11,
                  color: context.appTokens.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        _DashboardNumber(
          loading: refreshingNumbers,
          shimmer: numberShimmer,
          countUp: numberCountUp,
          value: value,
          color: color,
          placeholderWidth: 56,
          placeholderHeight: 24,
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          hint,
          style: TextStyle(fontSize: 10.5, color: context.appTokens.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    ),
  );
}

/// Hides the old value during refresh, then counts up to the latest API value.
class _DashboardNumber extends StatelessWidget {
  const _DashboardNumber({
    required this.loading,
    required this.shimmer,
    required this.countUp,
    required this.value,
    required this.color,
    required this.style,
    required this.placeholderWidth,
    required this.placeholderHeight,
    this.suffix = '',
  });

  final bool loading;
  final Animation<double> shimmer;
  final Animation<double> countUp;
  final String value;
  final String suffix;
  final Color color;
  final TextStyle style;
  final double placeholderWidth;
  final double placeholderHeight;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: placeholderWidth,
        minHeight: placeholderHeight,
      ),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          ExcludeSemantics(
            child: Opacity(
              opacity: 0,
              child: Text(
                '$value$suffix',
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (loading)
            AnimatedBuilder(
              animation: shimmer,
              builder: (context, _) => ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    color.withValues(alpha: .12),
                    color.withValues(alpha: .38),
                    color.withValues(alpha: .12),
                  ],
                ).createShader(
                  Rect.fromLTWH(
                    bounds.left + (shimmer.value * 2 - 1) * bounds.width,
                    bounds.top,
                    bounds.width,
                    bounds.height,
                  ),
                ),
                child: Container(
                  width: placeholderWidth,
                  height: placeholderHeight,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            )
          else
            AnimatedBuilder(
              animation: countUp,
              builder: (context, _) => Text(
                '${_countedValue(value, countUp.value)}$suffix',
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  static String _countedValue(String target, double progress) {
    if (progress >= 1) return target;
    final fraction = Curves.easeOutCubic.transform(progress.clamp(0.0, 1.0));
    final time = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(target);
    if (time != null) {
      final minutes = int.parse(time[1]!) * 60 + int.parse(time[2]!);
      final current = (minutes * fraction).round();
      return '${(current ~/ 60).toString().padLeft(2, '0')}:${(current % 60).toString().padLeft(2, '0')}';
    }
    final number = double.tryParse(target);
    if (number == null) return target;
    final decimals = target.contains('.') ? target.split('.').last.length : 0;
    final current = number * fraction;
    return decimals == 0 ? current.round().toString() : current.toStringAsFixed(decimals);
  }
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
      color: context.appTokens.surface,
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
                color: context.appTokens.brightness == Brightness.dark
                    ? Color.alphaBlend(widget.accent.withValues(alpha: .14), context.appTokens.surfaceElevated)
                    : widget.accentBg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  AppIcon(
                    Icons.calendar_month_outlined,
                    size: 15,
                    color: context.appTokens.brightness == Brightness.dark
                        ? context.appTokens.success
                        : widget.accent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${widget.title} · ${widget.dateLabel}',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: context.appTokens.brightness == Brightness.dark
                            ? context.appTokens.success
                            : widget.accent,
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
                        color: context.appTokens.brightness == Brightness.dark
                            ? context.appTokens.success
                            : widget.accent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  AppIcon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: context.appTokens.brightness == Brightness.dark
                        ? context.appTokens.success
                        : widget.accent,
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
    required this.onTapClosed,
  });

  final List<_TimelineEntry> entries;
  final List<Customer> customers;
  final AppLanguage language;

  /// Tapping a customer row opens the same actions sheet the Senenama
  /// (schedule) screen uses — it no longer navigates away from home.
  final void Function(Appointment appointment, Customer? customer)
  onTapAppointment;
  final void Function(DateTime start, DateTime end, DateTime availableEnd) onTapFree;
  final void Function(ClosedTime closed) onTapClosed;

  @override
  Widget build(BuildContext context) {
    final busy = entries.whereType<_ApptEntry>().length;
    final free = entries.whereType<_FreeEntry>().length;
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
          if (entry is _ClosedEntry) {
            return _HomeFreeRow(
              index: index,
              start: entry.closed.startsAt,
              end: entry.closed.endsAt,
              closed: entry.closed,
              language: language,
              onTap: () => onTapClosed(entry.closed),
              showDivider: !isLast,
            );
          }
          final gap = entry as _FreeEntry;
          return _HomeFreeRow(
            index: index,
            start: gap.start,
            end: gap.end,
            language: language,
            onTap: () => onTapFree(gap.start, gap.end, gap.availableEnd),
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
          color: tokens.surface,
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
    final (lightStatusColor, lightStatusBg, statusIcon) = switch (appointment.status) {
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
    final statusColor = tokens.brightness == Brightness.dark
        ? _apptStatusColor(appointment.status, tokens)
        : lightStatusColor;
    final statusBg = tokens.brightness == Brightness.dark
        ? _apptStatusBg(appointment.status, tokens)
        : lightStatusBg;
    // Mirrors the reference design's single highlighted "in progress" row —
    // the client is on-site right now, so it's the one row worth calling out.
    final highlighted = appointment.status == AppointmentStatus.arrived;
    final minutesLabel = pickTr(language, tk: 'min', ru: 'мин', en: 'min');

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 9,
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
                              backgroundColor: tokens.accent.withValues(alpha: .18),
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
                  const SizedBox(height: 6),
                  // The service is what the master is actually about to do,
                  // so it gets its own tinted chip instead of a narrow column
                  // that used to clip after two lines.
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: tokens.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: tokens.border),
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
    this.closed,
  });
  final int index;
  final DateTime start;
  final DateTime end;
  final AppLanguage language;
  final VoidCallback onTap;
  final bool showDivider;
  final ClosedTime? closed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final freeColor = closed != null ? tokens.warning : tokens.brightness == Brightness.dark
        ? tokens.success
        : const Color(0xff2A5DB0);
    final minutes = end.difference(start).inMinutes;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: _apptRowInset,
      ),
      decoration: BoxDecoration(
        color: closed != null ? tokens.surfaceElevated : tokens.brightness == Brightness.dark
            ? freeSlotSurface(tokens)
            : freeSlotBg.withValues(alpha: .5),
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
                  style: TextStyle(
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
                    AppIcon(
                      closed == null ? Icons.schedule_outlined : Icons.lock_clock_outlined,
                      size: 14,
                      color: freeColor,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        closed == null
                            ? pickTr(language, tk: 'Boş aralyk', ru: 'Свободно', en: 'Free slot')
                            : pickTr(language, tk: 'Ýapyk wagt', ru: 'Закрытое время', en: 'Blocked time'),
                        style: TextStyle(
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
                if (closed?.note.isNotEmpty == true)
                  Text(
                    closed!.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: tokens.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: freeColor,
              side: BorderSide(color: freeColor),
              backgroundColor: context.appTokens.surface,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              visualDensity: VisualDensity.compact,
            ),
            icon: AppIcon(closed == null ? Icons.edit_outlined : Icons.lock_open_outlined, size: 12),
            label: Text(
              closed == null
                  ? pickTr(language, tk: 'Üýtgetmek', ru: 'Изменить', en: 'Edit')
                  : pickTr(language, tk: 'Açmak', ru: 'Открыть', en: 'Reopen'),
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
