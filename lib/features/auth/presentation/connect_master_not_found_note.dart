part of '../../../app/komekci_app.dart';

class _NotFoundNote extends StatelessWidget {
  const _NotFoundNote({required this.title, required this.text});
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 28, 22, 26),
      decoration: _bookingCardDecoration(
        tokens,
      ).copyWith(borderRadius: BorderRadius.circular(26)),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tokens.warning.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: AppIcon(
              Icons.person_search_outlined,
              size: 38,
              color: tokens.warning,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 17.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: tokens.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Three steps on a vertical timeline, shown until the first search.
class _HowItWorks extends StatelessWidget {
  const _HowItWorks({required this.title, required this.steps});
  final String title;
  final List<(IconData, String, String)> steps;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: tokens.accent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < steps.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 40,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tokens.accent.withValues(alpha: .14),
                          border: Border.all(
                            color: tokens.accent.withValues(alpha: .4),
                          ),
                        ),
                        child: AppIcon(
                          steps[i].$1,
                          size: 19,
                          color: tokens.accent,
                        ),
                      ),
                      if (i < steps.length - 1)
                        Expanded(
                          child: Container(
                            width: 2,
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: tokens.border,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: i < steps.length - 1 ? 20 : 0,
                      top: 2,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ${steps[i].$2}',
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          steps[i].$3,
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: tokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class RequestPendingScreen extends StatelessWidget {
  const RequestPendingScreen({super.key, required this.master});
  final MasterBrief master;
  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return AppScaffold(
      title: t(
        tk: 'Haýyş iberildi',
        ru: 'Запрос отправлен',
        en: 'Request sent',
      ),
      titleInAppBar: true,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 132,
                      height: 132,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: tokens.accent.withValues(alpha: .10),
                      ),
                      child: Container(
                        width: 100,
                        height: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tokens.accent.withValues(alpha: .18),
                        ),
                        child: Container(
                          width: 70,
                          height: 70,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tokens.surface,
                            boxShadow: [
                              BoxShadow(
                                color: tokens.accent.withValues(alpha: .35),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: AppIcon(
                            Icons.hourglass_top_rounded,
                            size: 32,
                            color: tokens.accent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      t(
                        tk: 'Tassyklama garaşylýar',
                        ru: 'Ожидание подтверждения',
                        en: 'Waiting for confirmation',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: tokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t(
                        tk: '${master.name} haýyşyňyz barada habarly bolar.',
                        ru: '${master.name} получит уведомление о вашем запросе.',
                        en: '${master.name} will be notified about your request.',
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: tokens.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: _bookingCardDecoration(tokens),
                      child: Row(
                        children: [
                          MasterAvatar(url: master.photoUrl, radius: 26),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  master.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '@${master.nickname}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: tokens.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _ProfilePill(
                            dotColor: tokens.warning,
                            label: t(
                              tk: 'Garaşylýar',
                              ru: 'Ожидание',
                              en: 'Pending',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: t(tk: 'Baş sahypa', ru: 'На главную', en: 'Go to home'),
            onTap: () => Navigator.pushAndRemoveUntil(
              context,
              pageRoute(const ClientHome()),
              (_) => false,
            ),
          ),
        ],
      ),
    );
  }
}
