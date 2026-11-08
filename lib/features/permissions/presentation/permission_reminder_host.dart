import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/language_provider.dart';
import '../../../core/theme/app_theme_tokens.dart';
import '../../../shared/widgets/app_icon.dart';
import '../application/required_permissions.dart';
part 'permission_reminder_row.dart';

enum _PermissionAction { later, allow, settings }

/// Reminds signed-in users about missing permissions while the app is open.
/// Closing the dialog starts a fresh 30-second wait.
class PermissionReminderHost extends StatefulWidget {
  const PermissionReminderHost({
    super.key,
    required this.child,
    required this.needsCalendar,
    this.permissions = const DeviceRequiredPermissions(),
  });

  final Widget child;
  final bool needsCalendar;
  final RequiredPermissions permissions;

  @override
  State<PermissionReminderHost> createState() => _PermissionReminderHostState();
}

class _PermissionReminderHostState extends State<PermissionReminderHost>
    with WidgetsBindingObserver {
  static const _interval = Duration(seconds: 30);
  Timer? _timer;
  bool _checking = false;
  bool _foreground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _schedule();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    if (!_foreground || !mounted) return;
    _timer = Timer(_interval, () => unawaited(_check()));
  }

  bool get _canPrompt => mounted && _foreground;

  Future<void> _check() async {
    if (_checking) return;
    _checking = true;
    try {
      if (!_canPrompt) return;
      final missing = await widget.permissions.missing(
        needsCalendar: widget.needsCalendar,
      );
      if (!_canPrompt || !missing.any) return;
      final action = await _showReminder(missing);
      if (!mounted) return;
      switch (action) {
        case _PermissionAction.allow:
          await widget.permissions.request(missing);
        case _PermissionAction.settings:
          await widget.permissions.openSettings();
        case _PermissionAction.later || null:
          break;
      }
    } catch (error) {
      debugPrint('Checking required permissions failed: $error');
    } finally {
      _checking = false;
      if (mounted) _schedule();
    }
  }

  Future<_PermissionAction?> _showReminder(MissingAppPermissions missing) {
    final language = context.read<LanguageProvider>().language;
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return showDialog<_PermissionAction>(
      context: context,
      barrierColor: tokens.scrim,
      builder: (dialogContext) => Dialog(
        backgroundColor: tokens.surface,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.sizeOf(dialogContext).height * .92,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tokens.accent.withValues(alpha: .12),
                          ),
                          child: AppIcon(
                            Icons.shield_outlined,
                            size: 27,
                            color: tokens.accent,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Semantics(
                          header: true,
                          child: Text(
                            t(
                              tk: 'Rugsatlar gerek',
                              ru: 'Нужны разрешения',
                              en: 'Permissions needed',
                            ),
                            style: TextStyle(
                              fontFamily: 'Gilroy',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: tokens.textPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (missing.notifications)
                          _PermissionRow(
                            icon: Icons.notifications_none,
                            title: t(
                              tk: 'Bildirişlere rugsat beriň',
                              ru: 'Разрешите уведомления',
                              en: 'Allow notifications',
                            ),
                            detail: t(
                              tk: 'Täze ýazgylar we ýatlatmalar wagtynda geler.',
                              ru: 'Новые записи и напоминания придут вовремя.',
                              en: 'New bookings and reminders arrive on time.',
                            ),
                          ),
                        if (missing.notifications && missing.calendar) ...[
                          const SizedBox(height: 14),
                          Divider(height: 1, color: tokens.border),
                          const SizedBox(height: 14),
                        ],
                        if (missing.calendar)
                          _PermissionRow(
                            icon: Icons.calendar_month_outlined,
                            title: t(
                              tk: 'Senenama rugsat beriň',
                              ru: 'Разрешите доступ к календарю',
                              en: 'Allow calendar access',
                            ),
                            detail: t(
                              tk: 'Ýazgylar we 1 sagat öňki ýatlatmalar senenamada saklanar.',
                              ru: 'Записи и напоминания за час сохранятся в календаре.',
                              en: 'Bookings and one-hour reminders stay in your calendar.',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: tokens.button,
                      foregroundColor: tokens.buttonText,
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => Navigator.of(
                      dialogContext,
                    ).pop(_PermissionAction.allow),
                    child: Text(
                      t(tk: 'Rugsat ber', ru: 'Разрешить', en: 'Allow'),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(
                          dialogContext,
                        ).pop(_PermissionAction.settings),
                        child: Text(
                          t(tk: 'Sazlamalar', ru: 'Настройки', en: 'Settings'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: tokens.textSecondary,
                        ),
                        onPressed: () => Navigator.of(
                          dialogContext,
                        ).pop(_PermissionAction.later),
                        child: Text(t(tk: 'Soňra', ru: 'Позже', en: 'Later')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
