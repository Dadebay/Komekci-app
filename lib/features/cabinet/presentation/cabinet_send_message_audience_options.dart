part of '../../../app/komekci_app.dart';

class _MessageAudienceOptions extends StatelessWidget {
  const _MessageAudienceOptions({required this.language, required this.selectedAudience, required this.subtitle, required this.onSelect});

  final AppLanguage language;
  final int selectedAudience;
  final String Function(int) subtitle;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final audienceTitles = switch (language) {
      AppLanguage.tk => [
        'Ähli müşderiler',
        'Saýlanan müşderiler',
        'Soňky wagt aralygyndaky müşderiler',
      ],
      AppLanguage.ru => [
        'Все клиенты',
        'Выбранные клиенты',
        'Клиенты за период',
      ],
      AppLanguage.en => ['All clients', 'Selected clients', 'Recent clients'],
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                  const SizedBox(height: 20),
                  _FieldLabel(
                    text: t(
                      tk: 'Kimlere ibermeli?',
                      ru: 'Кому отправить?',
                      en: 'Who to send to?',
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(3, (index) {
                    final selected = selectedAudience == index;
                    return GestureDetector(
                      onTap: () => onSelect(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? tokens.accent.withValues(alpha: .1)
                              : tokens.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? tokens.accent : tokens.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 21,
                              height: 21,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? tokens.accent
                                      : tokens.border,
                                  width: 1.6,
                                ),
                              ),
                              child: selected
                                  ? Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: tokens.accent,
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    audienceTitles[index],
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    subtitle(index),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: tokens.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (index != 0)
                              AppIcon(
                                Icons.chevron_right,
                                color: tokens.textSecondary,
                                size: 17,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
      ],
    );
  }
}
