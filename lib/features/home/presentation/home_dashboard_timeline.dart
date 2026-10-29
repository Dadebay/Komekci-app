part of '../../../app/komekci_app.dart';

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
                    ? Color.alphaBlend(
                        widget.accent.withValues(alpha: .14),
                        context.appTokens.surfaceElevated,
                      )
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
  final void Function(DateTime start, DateTime end, DateTime availableEnd)
  onTapFree;
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
