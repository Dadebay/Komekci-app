part of '../../../app/komekci_app.dart';


const _monthsEn = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Translator shorthand shared by every screen in this flow.
typedef _Tr =
    String Function({
      required String tk,
      required String ru,
      required String en,
    });

/// "1 Hyzmat · 2 Wagt · 3 Tassykla" progress row used across the wizard.
class _WizardSteps extends StatelessWidget {
  const _WizardSteps({required this.current, required this.labels});
  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      children: List.generate(labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final leftStep = (i ~/ 2) + 1;
          final done = leftStep < current;
          return Expanded(
            child: Container(height: 2, color: done ? t.accent : t.border),
          );
        }
        final step = (i ~/ 2) + 1;
        final active = step == current;
        final done = step < current;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: active || done ? t.accent : t.surfaceElevated,
                border: Border.all(color: active || done ? t.accent : t.border),
              ),
              child: done
                  ? AppIcon(Icons.check, size: 13, color: t.accentOn)
                  : Text(
                      '$step',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? t.accentOn : t.textSecondary,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              labels[step - 1],
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: active ? t.textPrimary : t.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}

