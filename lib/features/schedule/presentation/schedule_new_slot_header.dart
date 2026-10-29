part of '../../../app/komekci_app.dart';

class _NewSlotHeader extends StatelessWidget {
  const _NewSlotHeader({required this.language});

  final AppLanguage language;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: tokens.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t(
                                    tk: 'Täze ýazgy goşmak',
                                    ru: 'Добавить запись',
                                    en: 'New booking',
                                  ),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: tokens.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: t(
                                  tk: 'Ýap',
                                  ru: 'Закрыть',
                                  en: 'Close',
                                ),
                                onPressed: () => Navigator.pop(context),
                                icon: AppIcon(
                                  Icons.close,
                                  size: 20,
                                  color: tokens.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: tokens.border),
      ],
    );
  }
}
