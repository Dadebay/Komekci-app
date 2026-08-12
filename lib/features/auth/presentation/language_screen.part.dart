part of '../../../app/komekci_app.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>();
    final tr = Tr(language.language);
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 26, 28, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                Text(
                  tr.chooseLanguage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -.5,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  language.language == AppLanguage.tk
                      ? 'Programmany ulanmak üçin öz diliňizi saýlaň'
                      : 'Выберите предпочтительный язык для приложения',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 38),
                LanguageOptionCard(
                  flag: '🇹🇲',
                  primary: 'Türkmençe',
                  secondary: 'Türkmen dili',
                  selected: language.language == AppLanguage.tk,
                  onTap: () => language.select(AppLanguage.tk),
                ),
                const SizedBox(height: 12),
                LanguageOptionCard(
                  flag: '🇷🇺',
                  primary: 'Русский',
                  secondary: 'Русский язык',
                  selected: language.language == AppLanguage.ru,
                  onTap: () => language.select(AppLanguage.ru),
                ),
                const Spacer(),
                PrimaryButton(
                  label: tr.continueText,
                  onTap: () =>
                      Navigator.push(context, _pageRoute(const RoleScreen())),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LanguageOptionCard extends StatelessWidget {
  const LanguageOptionCard({
    super.key,
    required this.flag,
    required this.primary,
    required this.secondary,
    required this.selected,
    required this.onTap,
  });
  final String flag;
  final String primary;
  final String secondary;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(22),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      height: 61,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: selected ? const Color(0xffFFFCF6) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected ? gold : line,
          width: selected ? 1.7 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .025),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            height: 34,
            child: Center(
              child: Text(
                flag,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  primary,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: ink,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  secondary,
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 19,
            height: 19,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? gold : Colors.transparent,
              border: Border.all(
                color: selected ? gold : const Color(0xffD8D5CE),
              ),
            ),
            child: selected
                ? const AppIcon(Icons.check, color: Colors.white, size: 12)
                : null,
          ),
        ],
      ),
    ),
  );
}
