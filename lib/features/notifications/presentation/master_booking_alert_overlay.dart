import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../shared/widgets/app_icon.dart';
import '../application/master_booking_alert_controller.dart';
part 'master_booking_alert_actions.dart';

/// Shows new master bookings above the current route, including after a push
/// tap launches the app. The timer begins once the master home is visible.
class MasterBookingAlertOverlay extends StatefulWidget {
  const MasterBookingAlertOverlay({super.key, required this.child});

  final Widget child;

  @override
  State<MasterBookingAlertOverlay> createState() =>
      _MasterBookingAlertOverlayState();
}

class _MasterBookingAlertOverlayState extends State<MasterBookingAlertOverlay> {
  static const _displayDuration = Duration(seconds: 8);
  Timer? _dismissTimer;
  String? _visibleId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final controller = context.watch<MasterBookingAlertController>();
    final alert = controller.visibleAlert;
    if (_visibleId == alert?.id) return;
    _dismissTimer?.cancel();
    _visibleId = alert?.id;
    if (alert != null) {
      _dismissTimer = Timer(_displayDuration, () {
        if (mounted) controller.dismiss(alert.id);
      });
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<MasterBookingAlertController>();
    final alert = controller.visibleAlert;
    final tokens = context.appTokens;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return Stack(
      children: [
        widget.child,
        if (alert != null)
          // Keyed by id so a replacing alert replays the entrance.
          TweenAnimationBuilder<double>(
            key: ValueKey(alert.id),
            tween: Tween(begin: 0, end: 1),
            duration: reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            builder: (context, t, card) => Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => controller.dismiss(alert.id),
                    behavior: HitTestBehavior.opaque,
                    child: Opacity(
                      opacity: t,
                      child: ColoredBox(color: tokens.scrim),
                    ),
                  ),
                ),
                Center(
                  child: Opacity(
                    opacity: t,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - t)),
                      child: Transform.scale(scale: .94 + .06 * t, child: card),
                    ),
                  ),
                ),
              ],
            ),
            child: _BookingAlertCard(
              alert: alert,
              duration: _displayDuration,
              onDismiss: () => controller.dismiss(alert.id),
            ),
          ),
      ],
    );
  }
}

class _BookingAlertCard extends StatelessWidget {
  const _BookingAlertCard({
    required this.alert,
    required this.duration,
    required this.onDismiss,
  });

  final MasterBookingAlert alert;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    final language = context.watch<LanguageProvider>().language;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 380,
            maxHeight: MediaQuery.sizeOf(context).height * .75,
          ),
          child: Semantics(
            liveRegion: true,
            label: '${alert.title}. ${alert.body}',
            child: Material(
              color: tokens.surfaceElevated,
              elevation: 12,
              shadowColor: Colors.black.withValues(alpha: .22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(color: tokens.border.withValues(alpha: .6)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Soft accent wash behind the header.
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 140,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            tokens.accent.withValues(alpha: .14),
                            tokens.accent.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 28, 22, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _HeaderBadge(tokens: tokens),
                        const SizedBox(height: 16),
                        Text(
                          alert.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Gilroy',
                            fontSize: 22,
                            height: 1.15,
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          pickTr(
                            language,
                            tk: 'Müşderi size ýazyldy',
                            ru: 'Клиент записался к вам',
                            en: 'A client just booked you',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: tokens.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Flexible(
                          child: SingleChildScrollView(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                16,
                                14,
                              ),
                              decoration: BoxDecoration(
                                color: Color.alphaBlend(
                                  tokens.accent.withValues(alpha: .06),
                                  tokens.surfaceElevated,
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: tokens.accent.withValues(alpha: .18),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1),
                                    child: AppIcon(
                                      Icons.event_available_outlined,
                                      size: 18,
                                      color: tokens.accent,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      alert.body,
                                      style: TextStyle(
                                        fontSize: 14.5,
                                        height: 1.45,
                                        color: tokens.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _CountdownButton(
                          label: pickTr(
                            language,
                            tk: 'Düşnükli',
                            ru: 'Понятно',
                            en: 'Got it',
                          ),
                          duration: duration,
                          onTap: onDismiss,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Semantics(
                      label: pickTr(
                        language,
                        tk: 'Ýap',
                        ru: 'Закрыть',
                        en: 'Close',
                      ),
                      child: IconButton(
                        onPressed: onDismiss,
                        icon: AppIcon(
                          Icons.close,
                          color: tokens.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Accent disc with a soft halo, so the alert reads at a glance.
