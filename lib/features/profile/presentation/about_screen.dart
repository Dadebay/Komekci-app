part of '../../../app/komekci_app.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final about = context.watch<AppSettingsProvider>().about;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: t(tk: 'Biz barada', ru: 'О нас', en: 'About us'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            if (about.title == null && about.content == null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Text(
                    t(
                      tk: 'Maglumat entek goşulmady',
                      ru: 'Информация пока не добавлена',
                      en: 'No information yet',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: tokens.textSecondary, fontSize: 15),
                  ),
                ),
              )
            else ...[
              if (about.title case final title?)
                Text(
                  title,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (about.title != null && about.content != null)
                const SizedBox(height: 18),
              if (about.content case final content?)
                Text(
                  content,
                  style: TextStyle(
                    color: tokens.textPrimary,
                    fontSize: 15,
                    height: 1.55,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
