part of '../../../app/komekci_app.dart';

class _MasterNotificationToggle extends StatefulWidget {
  const _MasterNotificationToggle({required this.prefs});
  final Map<String, bool> prefs;

  @override
  State<_MasterNotificationToggle> createState() => _MasterNotificationToggleState();
}

class _MasterNotificationToggleState extends State<_MasterNotificationToggle> {
  static final _codes = [
    for (var i = 1; i <= 19; i++) 'N-${i.toString().padLeft(2, '0')}',
  ];
  bool? _pendingValue;
  bool _saving = false;

  Future<void> _setAll(bool value) async {
    if (_saving) return;
    setState(() {
      _pendingValue = value;
      _saving = true;
    });
    final updated = {
      ...widget.prefs,
      for (final code in _codes) code: value,
    };
    await runApi(
      context,
      () => context.read<AuthProvider>().updateNotificationPrefs(updated),
    );
    if (!mounted) return;
    setState(() {
      _pendingValue = null;
      _saving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return _NotificationPrefRow(
      icon: Icons.notifications_active_outlined,
      title: t(
        tk: 'Ähli bildiriş görnüşleri',
        ru: 'Все типы уведомлений',
        en: 'All notification types',
      ),
      subtitle: t(
        tk: 'Hemmesini bir wagtda aç ýa-da öçür',
        ru: 'Включить или выключить все сразу',
        en: 'Turn every type on or off at once',
      ),
      value: _pendingValue ?? _codes.every((code) => widget.prefs[code] ?? true),
      onChanged: _saving ? null : _setAll,
    );
  }
}
