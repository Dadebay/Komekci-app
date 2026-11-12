part of '../../../app/komekci_app.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    return AppScaffold(
      title: title,
      child: ListView(
        children: [
          Text(
            AppStrings.appointmentsManageYourPreferences.select(language),
            style: TextStyle(color: context.appTokens.textSecondary),
          ),
          const SizedBox(height: 18),
          ...[
            AppStrings.appointmentsAppointmentReminders.select(language),
            AppStrings.appointmentsEarlierSlotOffers.select(language),
            AppStrings.profileMasterMessages.select(language),
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
            label: AppStrings.appointmentsContactOrNote.select(language),
          ),
        ],
      ),
    );
  }
}
