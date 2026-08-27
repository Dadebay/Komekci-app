part of '../../../app/komekci_app.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final isTk = context.watch<LanguageProvider>().isTurkmen;
    final tokens = context.appTokens;
    final categories = MockCategoryRepository().all();
    return AppScaffold(
      title: isTk ? 'Kategoriýany saýlaň' : 'Выберите категорию',
      subtitle: isTk ? 'Gerekli hyzmaty tapyň' : 'Найдите нужную услугу',
      child: GridView.builder(
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: .95,
        ),
        itemBuilder: (_, index) {
          final category = categories[index];
          return InkWell(
            onTap: () =>
                Navigator.push(context, pageRoute(const BookingPage())),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: tokens.surfaceElevated,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: tokens.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xffF3E7D2),
                    child: AppIcon(
                      index.isEven
                          ? Icons.schedule_outlined
                          : Icons.spa_outlined,
                      color: tokens.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    isTk ? category.nameTk : category.nameRu,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Explore services',
                    style: TextStyle(color: tokens.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MasterSchedule extends StatelessWidget {
  const MasterSchedule({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
    children: [
      const Text(
        'Working schedule',
        style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 18),
      ...[
        'Monday — Friday · 09:00 – 19:00',
        'Saturday · 10:00 – 17:00',
        'Sunday · Day off',
      ].map((x) => InfoRow(text: x)),
      SettingRow(
        label: 'Date override / day off',
        onTap: () => Navigator.push(
          context,
          pageRoute(const SettingsScreen(title: 'Schedule override')),
        ),
      ),
      SettingRow(
        label: 'Vacation',
        onTap: () => Navigator.push(
          context,
          pageRoute(const SettingsScreen(title: 'Vacation')),
        ),
      ),
    ],
  );
}

