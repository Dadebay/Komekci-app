part of '../../../app/komekci_app.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return AppScaffold(
      title: title,
      child: ListView(
        children: [
          Text(
            t(
              tk: 'Sazlamalaryňyzy dolandyryň.',
              ru: 'Управляйте своими настройками.',
              en: 'Manage your preferences.',
            ),
            style: TextStyle(color: context.appTokens.textSecondary),
          ),
          const SizedBox(height: 18),
          ...[
            t(
              tk: 'Ýazgy ýatlatmalary',
              ru: 'Напоминания о записи',
              en: 'Appointment reminders',
            ),
            t(
              tk: 'Has irki wagt teklipleri',
              ru: 'Предложения более раннего времени',
              en: 'Earlier-slot offers',
            ),
            t(
              tk: 'Master habarlary',
              ru: 'Сообщения мастера',
              en: 'Master messages',
            ),
          ].map(
            (x) => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(x),
              value: true,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(height: 16),
          Field(
            label: t(
              tk: 'Habarlaşmak ýa-da bellik',
              ru: 'Контакт или заметка',
              en: 'Contact or note',
            ),
          ),
        ],
      ),
    );
  }
}
