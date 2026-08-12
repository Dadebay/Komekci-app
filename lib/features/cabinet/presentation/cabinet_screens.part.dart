part of '../../../app/komekci_app.dart';

/// Mock master profile shown until the backend supplies the real account.
const _mockMasterName = 'Anna';
const _mockMasterNick = '@anna_master';
const _mockMasterPhone = '+993 65 123456';
const _mockMasterAddress = 'Aşgabat, Büzmeýin etraby';
const _mockBalance = 50;
const _mockTotalClients = 128;

/// Cabinet cards sit on white, so their outline is softer than the app default.
final _softLine = line.withValues(alpha: .55);

/// Mock client used across the notification / messaging screens.
typedef _MockClient = ({String name, String phone, String lastVisitDate, String lastVisitTime});

const _mockClients = <_MockClient>[
  (name: 'Aýgül Annagulyýewa', phone: '+993 65 123456', lastVisitDate: '03.06.2025', lastVisitTime: '14:30'),
  (name: 'Maksat Geldiýew', phone: '+993 64 987654', lastVisitDate: '31.05.2025', lastVisitTime: '16:45'),
  (name: 'Selbi Atajanowa', phone: '+993 65 555111', lastVisitDate: '29.05.2025', lastVisitTime: '11:00'),
  (name: 'Oguljahan Muhammedowa', phone: '+993 63 222333', lastVisitDate: '27.05.2025', lastVisitTime: '13:20'),
  (name: 'Dowletmyrat Ýazmammedow', phone: '+993 61 777888', lastVisitDate: '25.05.2025', lastVisitTime: '09:15'),
  (name: 'Maral Rejepowa', phone: '+993 65 444777', lastVisitDate: '24.05.2025', lastVisitTime: '10:05'),
];

String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

String _formatTime(TimeOfDay time) => '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

TimeOfDay _parseTime(String value) {
  final parts = value.split(':');
  return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
}

/// Bottom sheet to edit a start/end time pair (used by the day rows and the break-time row).
Future<(String, String)?> _pickTimeRange(BuildContext context, {required bool tk, required String title, required String start, required String end}) {
  var localStart = start;
  var localEnd = end;
  return showModalBottomSheet<(String, String)>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (sheetContext) => StatefulBuilder(
      builder: (sheetContext, setSheetState) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(sheetContext).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _PickerField(
                    label: tk ? 'Başlangyç' : 'Начало',
                    value: localStart,
                    icon: Icons.schedule_outlined,
                    trailingIcon: Icons.expand_more,
                    onTap: () async {
                      final picked = await showTimePicker(context: sheetContext, initialTime: _parseTime(localStart));
                      if (picked != null) setSheetState(() => localStart = _formatTime(picked));
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickerField(
                    label: tk ? 'Tamamlanyş' : 'Конец',
                    value: localEnd,
                    icon: Icons.schedule_outlined,
                    trailingIcon: Icons.expand_more,
                    onTap: () async {
                      final picked = await showTimePicker(context: sheetContext, initialTime: _parseTime(localEnd));
                      if (picked != null) setSheetState(() => localEnd = _formatTime(picked));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _MasterActionButton(label: tk ? 'Ýatda sakla' : 'Сохранить', enabled: true, leading: Icons.save_outlined, onTap: () => Navigator.pop(sheetContext, (localStart, localEnd))),
          ],
        ),
      ),
    ),
  );
}

/// Bottom sheet listing a fixed set of numeric choices (buffer minutes, reminder days, ...).
Future<int?> _pickDuration(BuildContext context, {required bool tk, required int current, required List<int> options, required String unit}) => showModalBottomSheet<int>(
  context: context,
  backgroundColor: Colors.white,
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  builder: (sheetContext) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(tk ? 'Sany saýlaň' : 'Выберите значение', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...options.map(
              (n) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('$n $unit', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                trailing: n == current ? const AppIcon(Icons.check, color: gold) : null,
                onTap: () => Navigator.pop(sheetContext, n),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);

class CabinetScreen extends StatefulWidget {
  const CabinetScreen({super.key});

  @override
  State<CabinetScreen> createState() => _CabinetScreenState();
}

class _CabinetScreenState extends State<CabinetScreen> {
  File? _avatar;

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final entries = <(IconData, String, Widget)>[
      (Icons.person_outline, tk ? 'Profil' : 'Профиль', const CabinetProfileScreen()),
      (Icons.content_cut, tk ? 'Hyzmatlar' : 'Услуги', const ServicesScreen()),
      (Icons.schedule_outlined, tk ? 'Iş wagty' : 'График работы', const WorkingHoursScreen()),
      (Icons.notifications_none, tk ? 'Bildiriş' : 'Уведомления', const ClientNotifyScreen()),
      (Icons.account_balance_wallet_outlined, tk ? 'Töleg we Abuna' : 'Оплата и подписка', const BillingScreen()),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 110),
          children: [
            Row(
              children: [
                const SizedBox(width: 40),
                Expanded(
                  child: Text(
                    tk ? 'KABINET' : 'КАБИНЕТ',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 15, letterSpacing: 1.1, fontWeight: FontWeight.w700),
                  ),
                ),
                _RoundIconButton(icon: Icons.notifications_none, onTap: () => Navigator.push(context, _pageRoute(const ClientNotifyScreen()))),
              ],
            ),
            const SizedBox(height: 18),
            _MasterCard(avatar: _avatar, onAvatarPicked: (file) => setState(() => _avatar = file), onTap: () => Navigator.push(context, _pageRoute(const CabinetProfileScreen()))),
            const SizedBox(height: 22),
            ...List.generate(entries.length, (index) {
              final entry = entries[index];
              return _CabinetRow(index: index + 1, icon: entry.$1, label: entry.$2, onTap: () => Navigator.push(context, _pageRoute(entry.$3)));
            }),
            const SizedBox(height: 10),
            _HelpCard(onTap: () => Navigator.push(context, _pageRoute(const SupportScreen()))),
          ],
        ),
      ),
    );
  }
}

class _MasterCard extends StatelessWidget {
  const _MasterCard({required this.avatar, required this.onAvatarPicked, required this.onTap});
  final File? avatar;
  final ValueChanged<File> onAvatarPicked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _softLine),
          boxShadow: [BoxShadow(color: ink.withValues(alpha: .05), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AvatarPicker(file: avatar, onPicked: onAvatarPicked, radius: 36),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(_mockMasterName, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      const Text(_mockMasterNick, style: TextStyle(fontSize: 13, color: Colors.black45)),
                      const SizedBox(height: 10),
                      const _MetaLine(icon: Icons.phone_outlined, text: _mockMasterPhone),
                      const SizedBox(height: 5),
                      const _MetaLine(icon: Icons.location_on_outlined, text: _mockMasterAddress),
                    ],
                  ),
                ),
                const AppIcon(Icons.chevron_right, color: Colors.black26, size: 18),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: _softLine, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: const Color(0xffFDF9F2), borderRadius: BorderRadius.circular(12)),
                  child: const AppIcon(Icons.account_balance_wallet_outlined, color: gold, size: 18),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tk ? 'Balans' : 'Баланс', style: const TextStyle(fontSize: 11.5, color: Colors.black45)),
                      const SizedBox(height: 2),
                      Text('$_mockBalance ${tk ? "manat" : "манат"}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, _pageRoute(const MasterSubscriptionScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    decoration: BoxDecoration(color: ink, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      tk ? 'Doldur' : 'Пополнить',
                      style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      AppIcon(icon, color: gold, size: 14),
      const SizedBox(width: 7),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 12.5, color: Colors.black54),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

class _CabinetRow extends StatelessWidget {
  const _CabinetRow({required this.index, required this.icon, required this.label, required this.onTap});
  final int index;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _softLine),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xffFDF9F2), borderRadius: BorderRadius.circular(13)),
            child: AppIcon(icon, color: gold, size: 20),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text('$index. $label', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
          const AppIcon(Icons.chevron_right, color: Colors.black26, size: 18),
        ],
      ),
    ),
  );
}

class _HelpCard extends StatelessWidget {
  const _HelpCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xffFDF9F2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xffF0E4CE).withValues(alpha: .6)),
        ),
        child: Row(
          children: [
            const AppIcon(Icons.info_outline, color: gold, size: 20),
            const SizedBox(width: 13),
            Expanded(
              child: Text(tk ? 'Kömek gerekmi?' : 'Нужна помощь?', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
            ),
            const AppIcon(Icons.chevron_right, color: Colors.black26, size: 18),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _softLine),
      ),
      child: AppIcon(icon, color: ink, size: 19),
    ),
  );
}

/// Small circular "(?)" button used in the top-right corner of most cabinet detail screens.
class _HelpIconButton extends StatelessWidget {
  const _HelpIconButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _softLine),
      ),
      child: const AppIcon(Icons.help_outline, color: ink, size: 16),
    ),
  );
}

/// Balance pill shown in place of the help button on the payment screen.
class _BalanceChip extends StatelessWidget {
  const _BalanceChip();

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xffFDF9F2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffF0E4CE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AppIcon(Icons.account_balance_wallet_outlined, color: gold, size: 14),
          const SizedBox(width: 6),
          Text('$_mockBalance ${tk ? "manat" : "манат"}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

/// Shared header for every cabinet destination.
class CabinetAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CabinetAppBar({super.key, required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    // Reused as a tab root, where there is nothing to pop back to.
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      toolbarHeight: 52,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: canPop
          ? IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: const AppIcon(Icons.arrow_back, color: ink, size: 20),
            )
          : null,
      title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      actions: [if (action != null) Padding(padding: const EdgeInsets.only(right: 12), child: action!)],
    );
  }
}

/// Rounded info banner: icon badge on the left, explanatory copy on the right.
class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: const Color(0xffF6F5F2), borderRadius: BorderRadius.circular(16)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          child: AppIcon(icon, color: ink, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.45)),
        ),
      ],
    ),
  );
}

/// One row inside the "Goşmaça sazlamalar" card: icon, title/subtitle, a value and an optional
/// switch and/or chevron. Used for break time, vacation, client buffer and special days.
class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.icon, required this.title, this.subtitle, this.value, this.switchValue, this.onSwitchChanged, this.showChevron = false, this.onTap});

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? value;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _softLine),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: const Color(0xffFDF9F2), borderRadius: BorderRadius.circular(12)),
                child: AppIcon(icon, color: gold, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    if (subtitle != null) ...[const SizedBox(height: 2), Text(subtitle!, style: const TextStyle(fontSize: 11.5, color: Colors.black45, height: 1.3))],
                  ],
                ),
              ),
              if (value != null) ...[
                const SizedBox(width: 8),
                Text(
                  value!,
                  style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Colors.black54),
                ),
              ],
              if (switchValue != null) ...[
                const SizedBox(width: 2),
                Transform.scale(
                  scale: .82,
                  child: Switch(value: switchValue!, activeThumbColor: Colors.white, activeTrackColor: ink, onChanged: onSwitchChanged),
                ),
              ],
              if (showChevron) ...[const SizedBox(width: 2), const AppIcon(Icons.chevron_right, color: Colors.black26, size: 17)],
            ],
          ),
        ),
      ),
    ),
  );
}

/// Labeled box that opens a picker (time or date) on tap.
class _PickerField extends StatelessWidget {
  const _PickerField({required this.label, required this.value, required this.icon, required this.onTap, this.trailingIcon = Icons.expand_more});
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: line),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              AppIcon(icon, color: ink, size: 17),
              const SizedBox(width: 10),
              Expanded(
                child: Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
              AppIcon(trailingIcon, color: Colors.black38, size: 18),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Small bordered chip used to display a day's start/end time.
class _TimeChip extends StatelessWidget {
  const _TimeChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      border: Border.all(color: line),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(text, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
  );
}

/// Rounded checkbox indicator used in the client-picker lists.
class _CheckboxDot extends StatelessWidget {
  const _CheckboxDot({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: checked ? ink : Colors.white,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: checked ? ink : line, width: 1.6),
    ),
    child: checked ? const AppIcon(Icons.check, color: Colors.white, size: 13) : null,
  );
}

/// A single client row with avatar, contact details and a trailing checkbox.
class _ClientListTile extends StatelessWidget {
  const _ClientListTile({required this.name, required this.phone, required this.subtitle, required this.checked, required this.onTap});
  final String name;
  final String phone;
  final String subtitle;
  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: checked ? gold : _softLine, width: checked ? 1.4 : 1),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xffE6D2B1),
            child: Text(
              name.substring(0, 1),
              style: const TextStyle(color: ink, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(phone, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black38)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _CheckboxDot(checked: checked),
        ],
      ),
    ),
  );
}

/// Icon + label + value row used inside the subscription card.
class _SubscriptionDateRow extends StatelessWidget {
  const _SubscriptionDateRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: const Color(0xffFDF9F2), borderRadius: BorderRadius.circular(10)),
        child: AppIcon(icon, color: gold, size: 15),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
    ],
  );
}

class CabinetProfileScreen extends StatefulWidget {
  const CabinetProfileScreen({super.key});

  @override
  State<CabinetProfileScreen> createState() => _CabinetProfileScreenState();
}

class _CabinetProfileScreenState extends State<CabinetProfileScreen> {
  final _controllers = [
    TextEditingController(text: _mockMasterName),
    TextEditingController(text: _mockMasterNick),
    TextEditingController(text: _mockMasterPhone),
    TextEditingController(text: _mockMasterAddress),
    TextEditingController(text: 'Saç ussasy · 6 ýyl tejribe'),
  ];
  File? _avatar;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final labels = tk ? ['Adyňyz', 'Lakamyňyz', 'Telefon belgiňiz', 'Salgysy', 'Özüňiz barada'] : ['Имя', 'Никнейм', 'Телефон', 'Адрес', 'О себе'];
    const icons = [Icons.person_outline, Icons.account_box_outlined, Icons.phone_outlined, Icons.location_on_outlined, Icons.edit_outlined];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(title: tk ? 'Profil' : 'Профиль'),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  Center(
                    child: AvatarPicker(file: _avatar, onPicked: (file) => setState(() => _avatar = file), radius: 46),
                  ),
                  const SizedBox(height: 24),
                  ...List.generate(labels.length, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel(text: labels[index]),
                          const SizedBox(height: 7),
                          TextField(
                            controller: _controllers[index],
                            maxLines: index == 4 ? 3 : 1,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              prefixIconConstraints: const BoxConstraints.tightFor(width: 44, height: 44),
                              prefixIcon: SizedBox(
                                width: 44,
                                height: 44,
                                child: Center(child: AppIcon(icons[index], color: ink, size: 18)),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: line),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: gold, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label: tk ? 'Ýatda sakla' : 'Сохранить',
                enabled: true,
                leading: Icons.save_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tk ? 'Profil ýatda saklandy.' : 'Профиль сохранён.')));
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkingHoursScreen extends StatefulWidget {
  const WorkingHoursScreen({super.key});

  @override
  State<WorkingHoursScreen> createState() => _WorkingHoursScreenState();
}

class _WorkingHoursScreenState extends State<WorkingHoursScreen> {
  // Mock weekly schedule: open flag plus start and end hour per weekday.
  var _days = List.generate(7, (index) => (open: index != 6, start: index == 5 ? '10:00' : '09:00', end: index == 5 ? '17:00' : '19:00'));

  String _breakStart = '13:00';
  String _breakEnd = '14:00';

  DateTime? _vacationStart = DateTime(2024, 6, 10);
  DateTime? _vacationEnd = DateTime(2024, 6, 20);
  String _vacationNote = '';
  bool _vacationEnabled = true;

  bool _bufferEnabled = true;
  int _bufferMinutes = 10;

  var _specialDays = <DateTime>[];

  Future<void> _editDay(int index, bool tk, List<String> names) async {
    final day = _days[index];
    final result = await _pickTimeRange(context, tk: tk, title: names[index], start: day.start, end: day.end);
    if (result == null) return;
    setState(() {
      final updated = List.of(_days);
      updated[index] = (open: day.open, start: result.$1, end: result.$2);
      _days = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final names = tk ? ['Duşenbe', 'Sişenbe', 'Çarşenbe', 'Penşenbe', 'Anna', 'Şenbe', 'Ýekşenbe'] : ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
    final vacationValue = _vacationStart != null && _vacationEnd != null ? '${_formatDate(_vacationStart!)} - ${_formatDate(_vacationEnd!)}' : (tk ? 'Bellenmedik' : 'Не задано');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: tk ? 'Iş wagty' : 'График работы',
        action: _HelpIconButton(onTap: () => Navigator.push(context, _pageRoute(const SupportScreen()))),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _InfoBanner(
                    icon: Icons.schedule_outlined,
                    text: tk ? 'Siziň iş wagtyňyz müşderilere siziň boş wagtlaryňyzy görkezmek üçin ulanylýar.' : 'Ваш график используется, чтобы показывать клиентам свободное время.',
                  ),
                  const SizedBox(height: 20),
                  Text(tk ? 'Hepdäniň iş günleri' : 'Рабочие дни недели', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  ...List.generate(names.length, (index) {
                    final day = _days[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: day.open ? line : const Color(0xffF0EEE9)),
                      ),
                      child: Row(
                        children: [
                          Text(names[index], style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 6),
                          Transform.scale(
                            scale: .78,
                            child: Switch(
                              value: day.open,
                              activeThumbColor: Colors.white,
                              activeTrackColor: ink,
                              onChanged: (value) => setState(() {
                                final updated = List.of(_days);
                                updated[index] = (open: value, start: day.start, end: day.end);
                                _days = updated;
                              }),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: day.open ? () => _editDay(index, tk, names) : null,
                            child: Row(
                              children: [
                                if (day.open) ...[
                                  _TimeChip(text: day.start),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 6),
                                    child: Text('–', style: TextStyle(color: Colors.black38)),
                                  ),
                                  _TimeChip(text: day.end),
                                ] else
                                  Text(
                                    tk ? 'Dynç güni' : 'Выходной',
                                    style: const TextStyle(fontSize: 12.5, color: Colors.black38, fontWeight: FontWeight.w600),
                                  ),
                                const SizedBox(width: 6),
                                AppIcon(Icons.chevron_right, color: day.open ? Colors.black26 : Colors.black12, size: 17),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 22),
                  Text(tk ? 'Goşmaça sazlamalar' : 'Дополнительные настройки', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  _SettingRow(
                    icon: Icons.coffee_outlined,
                    title: tk ? 'Arakesme wagty' : 'Время перерыва',
                    value: '$_breakStart - $_breakEnd',
                    showChevron: true,
                    onTap: () async {
                      final result = await _pickTimeRange(context, tk: tk, title: tk ? 'Arakesme wagty' : 'Время перерыва', start: _breakStart, end: _breakEnd);
                      if (result != null) {
                        setState(() {
                          _breakStart = result.$1;
                          _breakEnd = result.$2;
                        });
                      }
                    },
                  ),
                  _SettingRow(
                    icon: Icons.event_busy_outlined,
                    title: tk ? 'Dynç alyş ' : 'Отпуск',
                    value: vacationValue,
                    switchValue: _vacationEnabled,
                    onSwitchChanged: (v) => setState(() => _vacationEnabled = v),
                    onTap: () async {
                      final result = await Navigator.push<({DateTime start, DateTime end, String note})?>(
                        context,
                        _pageRoute(VacationScreen(initialStart: _vacationStart, initialEnd: _vacationEnd, initialNote: _vacationNote)),
                      );
                      if (result != null) {
                        setState(() {
                          _vacationStart = result.start;
                          _vacationEnd = result.end;
                          _vacationNote = result.note;
                          _vacationEnabled = true;
                        });
                      }
                    },
                  ),
                  _SettingRow(
                    icon: Icons.timer_outlined,
                    title: tk ? 'Müşderileriň arasyndaky arakesme' : 'Перерыв между клиентами',
                    subtitle: tk ? 'Her bir müşderiden soň goşmaça wagt' : 'Дополнительное время после каждого клиента',
                    value: '$_bufferMinutes ${tk ? "min" : "мин"}',
                    switchValue: _bufferEnabled,
                    onSwitchChanged: (v) => setState(() => _bufferEnabled = v),
                    onTap: () async {
                      final picked = await _pickDuration(context, tk: tk, current: _bufferMinutes, options: const [5, 10, 15, 20, 30, 45, 60], unit: tk ? 'min' : 'мин');
                      if (picked != null) setState(() => _bufferMinutes = picked);
                    },
                  ),
                  _SettingRow(
                    icon: Icons.event_busy_outlined,
                    title: tk ? 'Aýratyn günler' : 'Особые дни',
                    subtitle: tk ? 'Goşmaça günleri ýa-da üýtgeşmeleri belläň' : 'Отметьте дополнительные дни или изменения',
                    value: '${_specialDays.length} ${tk ? "gün" : "дн."}',
                    showChevron: true,
                    onTap: () async {
                      final result = await Navigator.push<List<DateTime>?>(context, _pageRoute(SpecialDaysScreen(initialDays: _specialDays)));
                      if (result != null) setState(() => _specialDays = result);
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label: tk ? 'Üýtgeşmeleri ýatda sakla' : 'Сохранить изменения',
                enabled: true,
                leading: Icons.save_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tk ? 'Iş wagty ýatda saklandy.' : 'График сохранён.')));
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VacationScreen extends StatefulWidget {
  const VacationScreen({super.key, this.initialStart, this.initialEnd, this.initialNote = ''});
  final DateTime? initialStart;
  final DateTime? initialEnd;
  final String initialNote;

  @override
  State<VacationScreen> createState() => _VacationScreenState();
}

class _VacationScreenState extends State<VacationScreen> {
  late DateTime _start = widget.initialStart ?? DateTime.now();
  late DateTime _end = widget.initialEnd ?? DateTime.now().add(const Duration(days: 7));
  late final _noteController = TextEditingController(text: widget.initialNote);

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _start : _end,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) _end = _start;
      } else {
        _end = picked;
        if (_start.isAfter(_end)) _start = _end;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: tk ? 'Dynç alyş ' : 'Отпуск',
        action: _HelpIconButton(onTap: () => Navigator.push(context, _pageRoute(const SupportScreen()))),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _InfoBanner(
                    icon: Icons.event_busy_outlined,
                    text: tk
                        ? 'Bu wagtda siz hyzmatlary kabul etmersiňiz. Müşderiler bu günler üçin sargyt edip bilmezler.'
                        : 'В это время вы не принимаете заявки. Клиенты не смогут записаться на эти дни.',
                  ),
                  const SizedBox(height: 22),
                  Text(tk ? 'Dynç alyş döwri' : 'Период отпуска', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  _PickerField(label: tk ? 'Başlangyç senesi' : 'Дата начала', value: _formatDate(_start), icon: Icons.calendar_today_outlined, onTap: () => _pickDate(isStart: true)),
                  const SizedBox(height: 14),
                  _PickerField(label: tk ? 'Tamamlanýan senesi' : 'Дата окончания', value: _formatDate(_end), icon: Icons.calendar_today_outlined, onTap: () => _pickDate(isStart: false)),
                  const SizedBox(height: 22),
                  _FieldLabel(text: tk ? 'Düşündiriş (islege görä)' : 'Комментарий (необязательно)'),
                  const SizedBox(height: 8),
                  _FormField(controller: _noteController, hint: tk ? 'Mysal: Tomusky dynç alyş' : 'Например: летний отпуск', maxLines: 4, maxLength: 200, onChanged: () => setState(() {})),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(
                label: tk ? 'Ýatda sakla' : 'Сохранить',
                enabled: true,
                leading: Icons.save_outlined,
                onTap: () => Navigator.pop(context, (start: _start, end: _end, note: _noteController.text.trim())),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SpecialDaysScreen extends StatefulWidget {
  const SpecialDaysScreen({super.key, required this.initialDays});
  final List<DateTime> initialDays;

  @override
  State<SpecialDaysScreen> createState() => _SpecialDaysScreenState();
}

class _SpecialDaysScreenState extends State<SpecialDaysScreen> {
  late var _days = List.of(widget.initialDays)..sort();

  Future<void> _addDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: now, firstDate: now.subtract(const Duration(days: 1)), lastDate: now.add(const Duration(days: 365)));
    if (picked == null) return;
    final exists = _days.any((d) => d.year == picked.year && d.month == picked.month && d.day == picked.day);
    if (exists) return;
    setState(() => _days = (List.of(_days)..add(picked))..sort());
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: tk ? 'Aýratyn günler' : 'Особые дни',
        action: _HelpIconButton(onTap: () => Navigator.push(context, _pageRoute(const SupportScreen()))),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _InfoBanner(
                    icon: Icons.event_busy_outlined,
                    text: tk ? 'Bu günlerde hyzmat kabul edilmez. Islendik senäni goşup ýa-da aýryp bilersiňiz.' : 'В эти дни запись недоступна. Добавляйте или удаляйте любые даты.',
                  ),
                  const SizedBox(height: 18),
                  if (_days.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: Text(tk ? 'Entek aýratyn gün goşulmady.' : 'Особые дни ещё не добавлены.', style: const TextStyle(color: Colors.black45, fontSize: 13)),
                      ),
                    )
                  else
                    ..._days.map(
                      (d) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _softLine),
                        ),
                        child: Row(
                          children: [
                            const AppIcon(Icons.event_busy_outlined, color: gold, size: 18),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(_formatDate(d), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _days = List.of(_days)..remove(d)),
                              child: const AppIcon(Icons.close, color: Colors.black38, size: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: _addDay,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: line),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppIcon(Icons.add, color: ink, size: 18),
                          const SizedBox(width: 8),
                          Text(tk ? 'Gün goş' : 'Добавить день', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(label: tk ? 'Ýatda sakla' : 'Сохранить', enabled: true, leading: Icons.save_outlined, onTap: () => Navigator.pop(context, _days)),
            ),
          ],
        ),
      ),
    );
  }
}

class ClientNotifyScreen extends StatefulWidget {
  const ClientNotifyScreen({super.key});

  @override
  State<ClientNotifyScreen> createState() => _ClientNotifyScreenState();
}

class _ClientNotifyScreenState extends State<ClientNotifyScreen> {
  bool _reminderEnabled = true;
  int _reminderDays = 10;

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: tk ? 'Müşderilere bildiriş' : 'Уведомления клиентам',
        action: _HelpIconButton(onTap: () => Navigator.push(context, _pageRoute(const SupportScreen()))),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _InfoBanner(
              icon: Icons.notifications_none,
              text: tk
                  ? 'Ýazgy ýatlatmalary müşderilere awtomatiki iberilýär. Bu habarlaryň sazlamasy ulgam tarapyndan dolandyrylýar.'
                  : 'Напоминания о записи отправляются клиентам автоматически. Этими настройками управляет система.',
            ),
            const SizedBox(height: 22),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: AppIcon(Icons.groups_outlined, color: ink, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(tk ? '1. Müşderini gaýtadan çagyrmak' : '1. Повторный вызов клиента', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tk ? 'Müşderä soňky saparyndan belli bir wagtdan soň ýatlatma habary iberiler.' : 'Клиенту будет отправлено напоминание через определённое время после последнего визита.',
              style: const TextStyle(fontSize: 12, color: Colors.black45, height: 1.4),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _softLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(tk ? 'Funksiýany aç / ýap' : 'Включить / выключить', style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                      ),
                      Switch(value: _reminderEnabled, activeThumbColor: Colors.white, activeTrackColor: ink, onChanged: (v) => setState(() => _reminderEnabled = v)),
                    ],
                  ),
                  Divider(color: _softLine, height: 22),
                  Text(tk ? 'Ýatlatma näçe günden soň iberilsin?' : 'Через сколько дней отправлять напоминание?', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    tk ? 'Müşteri bu wagt aralygynda täzeden ýazylmasa, oňa ýatlatma habary iberiler.' : 'Если клиент не запишется повторно за это время, ему придёт напоминание.',
                    style: const TextStyle(fontSize: 11.5, color: Colors.black45, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () async {
                      final picked = await _pickDuration(context, tk: tk, current: _reminderDays, options: const [3, 5, 7, 10, 14, 21, 30], unit: tk ? 'gün' : 'дн.');
                      if (picked != null) setState(() => _reminderDays = picked);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        border: Border.all(color: line),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('$_reminderDays ${tk ? "gün" : "дн."}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                          const AppIcon(Icons.expand_more, color: Colors.black38, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 26),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: AppIcon(Icons.send_outlined, color: ink, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(tk ? '2. Gysga habar ibermek' : '2. Отправить короткое сообщение', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tk ? 'Islendik müşdere ýa-da ähli müşderilere gysga habar iberiň.' : 'Отправьте короткое сообщение любому клиенту или всем сразу.',
              style: const TextStyle(fontSize: 12, color: Colors.black45, height: 1.4),
            ),
            const SizedBox(height: 12),
            _SettingRow(icon: Icons.send_outlined, title: tk ? 'Habar ibermek' : 'Отправить сообщение', showChevron: true, onTap: () => Navigator.push(context, _pageRoute(const SendMessageScreen()))),
            const SizedBox(height: 10),
            _InfoBanner(icon: Icons.info_outline, text: tk ? 'Habarlar ähli müşderilere ýa-da saýlanan müşderilere iberlip bilner.' : 'Сообщения можно отправить всем клиентам или выбранным.'),
          ],
        ),
      ),
    );
  }
}

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final _messageController = TextEditingController();
  int _audience = 0; // 0 = all, 1 = selected, 2 = recent
  var _selectedNames = <String>[];
  var _recentNames = <String>[];
  bool _pushChannel = true;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _audienceSubtitle(bool tk, int index) {
    switch (index) {
      case 0:
        return tk ? 'Ähli müşderilere iberiler ($_mockTotalClients adam).' : 'Будет отправлено всем клиентам ($_mockTotalClients чел.).';
      case 1:
        return _selectedNames.isEmpty
            ? (tk ? 'Müşderileri saýlap iberiň.' : 'Выберите клиентов для отправки.')
            : (tk ? '${_selectedNames.length} müşderi saýlandy.' : 'Выбрано клиентов: ${_selectedNames.length}.');
      default:
        return _recentNames.isEmpty
            ? (tk ? 'Belli bir wagtyň içinde ýazylan müşderiler.' : 'Клиенты за определённый период.')
            : (tk ? '${_recentNames.length} müşderi saýlandy.' : 'Выбрано клиентов: ${_recentNames.length}.');
    }
  }

  Future<void> _selectAudience(int index) async {
    if (index == 1) {
      final result = await Navigator.push<List<String>>(context, _pageRoute(SelectedClientsScreen(initialSelection: _selectedNames)));
      if (result == null) return;
      setState(() {
        _audience = 1;
        _selectedNames = result;
      });
      return;
    }
    if (index == 2) {
      final result = await Navigator.push<List<String>>(context, _pageRoute(RecentClientsScreen(initialSelection: _recentNames)));
      if (result == null) return;
      setState(() {
        _audience = 2;
        _recentNames = result;
      });
      return;
    }
    setState(() => _audience = 0);
  }

  /// Shows who the message will actually reach and asks for a final confirmation before sending.
  Future<void> _confirmAndSend(bool tk) async {
    final int recipientCount;
    final String recipientLabel;
    switch (_audience) {
      case 0:
        recipientCount = _mockTotalClients;
        recipientLabel = tk ? 'ähli müşderilere' : 'всем клиентам';
      case 1:
        recipientCount = _selectedNames.length;
        recipientLabel = tk ? 'saýlanan müşderilere' : 'выбранным клиентам';
      default:
        recipientCount = _recentNames.length;
        recipientLabel = tk ? 'soňky wagt aralygyndaky müşderilere' : 'клиентам за период';
    }
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tk ? 'Habary tassyklaň' : 'Подтвердите отправку', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 10),
                Text(
                  tk ? 'Habar $recipientLabel iberiler · $recipientCount adam. Dowam etmek isleýärsiňizmi?' : 'Сообщение будет отправлено $recipientLabel · $recipientCount чел. Продолжить?',
                  style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.45),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: line),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        onPressed: () => Navigator.pop(sheetContext, false),
                        child: Text(
                          tk ? 'Ýok' : 'Отмена',
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: ink),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MasterActionButton(label: tk ? 'Iber' : 'Отправить', enabled: true, onTap: () => Navigator.pop(sheetContext, true)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (confirmed != true || !mounted) return;

    // Real SMS delivery is only possible on Android, and only for audiences whose phone
    // numbers we actually know (the "all clients" count is a mock total with no directory).
    if (!_pushChannel && Platform.isAndroid) {
      final numbers = _resolvePhoneNumbers();
      if (numbers.isNotEmpty) {
        await _sendRealSms(tk, numbers);
        return;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tk ? 'Habar $recipientCount adama iberildi.' : 'Сообщение отправлено $recipientCount получателям.')));
    Navigator.pop(context);
  }

  List<String> _resolvePhoneNumbers() {
    switch (_audience) {
      case 1:
        return _selectedNames.map((name) => _mockClients.firstWhere((c) => c.name == name).phone).toList();
      case 2:
        return _recentNames.map((name) => _mockClients.firstWhere((c) => c.name == name).phone).toList();
      default:
        return const [];
    }
  }

  Future<void> _sendRealSms(bool tk, List<String> numbers) async {
    final status = await Permission.sms.request();
    if (!status.isGranted) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tk ? 'SMS ibermek üçin rugsat gerek.' : 'Для отправки SMS нужно разрешение.')));
      return;
    }
    final message = _messageController.text.trim();
    var sent = 0;
    for (final number in numbers) {
      final result = await BackgroundSms.sendMessage(phoneNumber: number, message: message);
      if (result == SmsStatus.sent) sent++;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tk ? '$sent/${numbers.length} SMS iberildi.' : 'Отправлено SMS: $sent из ${numbers.length}.')));
    Navigator.pop(context);
  }

  Future<void> _pickChannel(bool tk) async {
    final picked = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tk ? 'Geplesik görnüşi' : 'Способ отправки', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const AppIcon(Icons.notifications_none, color: gold),
                  title: Text(tk ? 'Push habar' : 'Push-уведомление', style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                  trailing: _pushChannel ? const AppIcon(Icons.check, color: gold) : null,
                  onTap: () => Navigator.pop(sheetContext, true),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const AppIcon(Icons.smartphone_outlined, color: gold),
                  title: const Text('SMS', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                  trailing: !_pushChannel ? const AppIcon(Icons.check, color: gold) : null,
                  onTap: () => Navigator.pop(sheetContext, false),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    if (picked != null) setState(() => _pushChannel = picked);
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final audienceTitles = tk ? ['Ähli müşderiler', 'Saýlanan müşderiler', 'Soňky wagt aralygyndaky müşderiler'] : ['Все клиенты', 'Выбранные клиенты', 'Клиенты за период'];
    final ready = _messageController.text.trim().isNotEmpty && (_audience != 1 || _selectedNames.isNotEmpty) && (_audience != 2 || _recentNames.isNotEmpty);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: tk ? 'Habar ibermek' : 'Отправить сообщение',
        action: _HelpIconButton(onTap: () => Navigator.push(context, _pageRoute(const SupportScreen()))),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _InfoBanner(
                    icon: Icons.chat_bubble_outline,
                    text: tk ? 'Saýlanan müşderilere gysga habar iberiň. SMS ýa-da push habarnama bolar.' : 'Отправьте короткое сообщение выбранным клиентам. Это может быть SMS или push-уведомление.',
                  ),
                  const SizedBox(height: 20),
                  _FieldLabel(text: tk ? 'Kimlere ibermeli?' : 'Кому отправить?'),
                  const SizedBox(height: 10),
                  ...List.generate(3, (index) {
                    final selected = _audience == index;
                    return GestureDetector(
                      onTap: () => _selectAudience(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xffFDF9F2) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: selected ? gold : line, width: selected ? 1.5 : 1),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 21,
                              height: 21,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: selected ? gold : line, width: 1.6),
                              ),
                              child: selected
                                  ? Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(shape: BoxShape.circle, color: gold),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(audienceTitles[index], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 3),
                                  Text(_audienceSubtitle(tk, index), style: const TextStyle(fontSize: 11.5, color: Colors.black45)),
                                ],
                              ),
                            ),
                            if (index != 0) const AppIcon(Icons.chevron_right, color: Colors.black26, size: 17),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  _FieldLabel(text: tk ? 'Habar teksti' : 'Текст сообщения', required: true),
                  const SizedBox(height: 8),
                  _FormField(controller: _messageController, hint: tk ? 'Habaryňyzy ýazyň...' : 'Напишите сообщение...', maxLines: 5, maxLength: 160, onChanged: () => setState(() {})),
                  const SizedBox(height: 18),
                  _FieldLabel(text: tk ? 'Geplesik görnüşi' : 'Способ отправки'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickChannel(tk),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _softLine),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: const Color(0xffFDF9F2), borderRadius: BorderRadius.circular(11)),
                            child: AppIcon(_pushChannel ? Icons.notifications_none : Icons.smartphone_outlined, color: gold, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_pushChannel ? (tk ? 'Push habar' : 'Push-уведомление') : 'SMS', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 2),
                                Text(
                                  _pushChannel ? (tk ? 'Müşderilere push habarnama iberiler.' : 'Клиентам придёт push-уведомление.') : (tk ? 'Müşderilere SMS iberiler.' : 'Клиентам придёт SMS.'),
                                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                                ),
                              ],
                            ),
                          ),
                          const AppIcon(Icons.expand_more, color: Colors.black38, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(label: tk ? 'Habar ibermek' : 'Отправить', enabled: ready, leading: Icons.send_outlined, onTap: () => _confirmAndSend(tk)),
            ),
          ],
        ),
      ),
    );
  }
}

class SelectedClientsScreen extends StatefulWidget {
  const SelectedClientsScreen({super.key, this.initialSelection = const []});
  final List<String> initialSelection;

  @override
  State<SelectedClientsScreen> createState() => _SelectedClientsScreenState();
}

class _SelectedClientsScreenState extends State<SelectedClientsScreen> {
  final _searchController = TextEditingController();
  late final _selected = Set<String>.of(widget.initialSelection);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final query = _searchController.text.trim().toLowerCase();
    final clients = _mockClients.where((c) => query.isEmpty || c.name.toLowerCase().contains(query) || c.phone.contains(query)).toList();
    final allSelected = clients.isNotEmpty && clients.every((c) => _selected.contains(c.name));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: tk ? 'Saýlanan müşderiler' : 'Выбранные клиенты',
        action: _HelpIconButton(onTap: () => Navigator.push(context, _pageRoute(const SupportScreen()))),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _InfoBanner(
                    icon: Icons.groups_outlined,
                    text: tk ? 'Habar ibermek üçin müşderileri saýlaň. Soňra habar tekstini ýazyň we iberiň.' : 'Выберите клиентов для отправки. Затем напишите текст сообщения и отправьте.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: tk ? 'Gözleg' : 'Поиск',
                      hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.all(13),
                        child: AppIcon(Icons.search, color: Colors.black38, size: 18),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: line),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: gold, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(tk ? 'Saýlananlar: ${_selected.length}' : 'Выбрано: ${_selected.length}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => setState(() {
                          if (allSelected) {
                            for (final c in clients) {
                              _selected.remove(c.name);
                            }
                          } else {
                            for (final c in clients) {
                              _selected.add(c.name);
                            }
                          }
                        }),
                        child: Row(
                          children: [
                            Text(tk ? 'Ählisini saýlamak' : 'Выбрать всех', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                            const SizedBox(width: 8),
                            _CheckboxDot(checked: allSelected),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ...clients.map((c) {
                    final checked = _selected.contains(c.name);
                    return _ClientListTile(
                      name: c.name,
                      phone: c.phone,
                      subtitle: '${tk ? "Soňky gezek" : "Последний визит"}: ${c.lastVisitDate}',
                      checked: checked,
                      onTap: () => setState(() {
                        if (checked) {
                          _selected.remove(c.name);
                        } else {
                          _selected.add(c.name);
                        }
                      }),
                    );
                  }),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(label: '${tk ? "Dowam et" : "Продолжить"} (${_selected.length})', enabled: _selected.isNotEmpty, onTap: () => Navigator.pop(context, _selected.toList())),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentClientsScreen extends StatefulWidget {
  const RecentClientsScreen({super.key, this.initialSelection = const []});
  final List<String> initialSelection;

  @override
  State<RecentClientsScreen> createState() => _RecentClientsScreenState();
}

class _RecentClientsScreenState extends State<RecentClientsScreen> {
  int _period = 0; // 0:7d 1:30d 2:3m 3:6m
  late final _selected = Set<String>.of(widget.initialSelection);

  static const _periodCounts = [5, 6, 6, 6];

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final periodLabels = tk ? ['7 gün', '30 gün', '3 aý', '6 aý'] : ['7 дней', '30 дней', '3 мес.', '6 мес.'];
    final clients = _mockClients.take(_periodCounts[_period]).toList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(
        title: tk ? 'Soňky müşderiler' : 'Недавние клиенты',
        action: _HelpIconButton(onTap: () => Navigator.push(context, _pageRoute(const SupportScreen()))),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                children: [
                  _InfoBanner(icon: Icons.schedule_outlined, text: tk ? 'Soňky haçan hyzmat alan müşderileriňize habar iberiň.' : 'Отправьте сообщение клиентам, которые недавно получали услугу.'),
                  const SizedBox(height: 18),
                  Text(tk ? 'Döwrüni saýlaň' : 'Выберите период', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(periodLabels.length, (index) {
                      final selected = _period == index;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index == periodLabels.length - 1 ? 0 : 8),
                          child: GestureDetector(
                            onTap: () => setState(() {
                              _period = index;
                              _selected.clear();
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected ? ink : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: selected ? ink : line),
                              ),
                              child: Text(
                                periodLabels[index],
                                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: selected ? Colors.white : ink),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    tk ? 'Soňky ${periodLabels[_period]} içinde hyzmat alanlar (${clients.length})' : 'Клиенты за последние ${periodLabels[_period]} (${clients.length})',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  ...clients.map((c) {
                    final checked = _selected.contains(c.name);
                    return _ClientListTile(
                      name: c.name,
                      phone: c.phone,
                      subtitle: '${tk ? "Soňky sapar" : "Последний визит"}: ${c.lastVisitDate} ${c.lastVisitTime}',
                      checked: checked,
                      onTap: () => setState(() {
                        if (checked) {
                          _selected.remove(c.name);
                        } else {
                          _selected.add(c.name);
                        }
                      }),
                    );
                  }),
                  const SizedBox(height: 8),
                  _InfoBanner(icon: Icons.info_outline, text: tk ? 'Maksimum 100 müşdera çenli habar iberip bilersiňiz.' : 'Вы можете отправить сообщение максимум 100 клиентам.'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: _MasterActionButton(label: '${tk ? "Dowam et" : "Продолжить"} (${_selected.length})', enabled: _selected.isNotEmpty, onTap: () => Navigator.pop(context, _selected.toList())),
            ),
          ],
        ),
      ),
    );
  }
}

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final history = tk
        ? [('01.08.2026', '14:30', 'Abuna tölegi', 20), ('01.07.2026', '14:30', 'Abuna tölegi', 20), ('01.06.2026', '14:30', 'Abuna tölegi', 20)]
        : [('01.08.2026', '14:30', 'Оплата подписки', 20), ('01.07.2026', '14:30', 'Оплата подписки', 20), ('01.06.2026', '14:30', 'Оплата подписки', 20)];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(title: tk ? 'Töleg we Abuna' : 'Оплата и подписка', action: const _BalanceChip()),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            Text(tk ? '1. Häzirki abuna' : '1. Текущая подписка', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _softLine),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: ink),
                        child: const Text('♔', style: TextStyle(fontSize: 20, color: gold)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tk ? 'Master abuna' : 'Подписка мастера', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 2),
                            Text('$_monthlyFee ${tk ? "manat / aý" : "манат / мес."}', style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(color: const Color(0xffEFF7EF), borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          tk ? 'Aktiw' : 'Активна',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xff3E8E41)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: _softLine, height: 1),
                  const SizedBox(height: 14),
                  _SubscriptionDateRow(icon: Icons.calendar_today_outlined, label: tk ? 'Soňky töleg' : 'Последний платёж', value: '01.08.2026'),
                  const SizedBox(height: 10),
                  _SubscriptionDateRow(icon: Icons.calendar_month_outlined, label: tk ? 'Indiki töleg' : 'Следующий платёж', value: '01.09.2026'),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _InfoBanner(
              icon: Icons.info_outline,
              text: tk ? 'Siziň abunaňyz 31 gün soň awtomatiki täzelener. Indiki töleg senesi: 01.09.2026' : 'Ваша подписка автоматически продлится через 31 день. Дата следующего платежа: 01.09.2026',
            ),
            const SizedBox(height: 26),
            Text(tk ? '2. Balans doldurmak' : '2. Пополнение баланса', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _MasterActionButton(
              label: tk ? 'Balans doldurmak' : 'Пополнить баланс',
              enabled: true,
              leading: Icons.add,
              onTap: () => Navigator.push(context, _pageRoute(const MasterSubscriptionScreen())),
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: Text(tk ? '3. Töleg taryhy' : '3. История платежей', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
                Text(
                  tk ? 'Ählisini görmek' : 'Смотреть все',
                  style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600),
                ),
                const AppIcon(Icons.chevron_right, color: Colors.black26, size: 15),
              ],
            ),
            const SizedBox(height: 12),
            ...history.map((entry) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _softLine),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: const Color(0xffFDF9F2), borderRadius: BorderRadius.circular(12)),
                      child: const AppIcon(Icons.credit_card_outlined, color: gold, size: 17),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${entry.$1}  ${entry.$2}', style: const TextStyle(fontSize: 12, color: Colors.black45)),
                          const SizedBox(height: 2),
                          Text(entry.$3, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Text(
                      '-${entry.$4} ${tk ? "manat" : "манат"}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: ink),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tk = context.watch<LanguageProvider>().isTurkmen;
    final faq = tk
        ? [
            ('Abunany nädip tölemeli?', 'Kabinet → Töleg bölüminden balansyňyzy dolduryp bilersiňiz.'),
            ('Hyzmat nädip goşulýar?', 'Kabinet → Hyzmatlar → Täze hyzmat goş.'),
            ('Iş wagtymy üýtgedip bilerinmi?', 'Hawa, Kabinet → Iş wagty bölüminden islendik wagt.'),
          ]
        : [
            ('Как оплатить подписку?', 'Кабинет → Оплата, пополните баланс.'),
            ('Как добавить услугу?', 'Кабинет → Услуги → Добавить услугу.'),
            ('Можно ли менять график?', 'Да, в разделе Кабинет → График работы.'),
          ];
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CabinetAppBar(title: tk ? 'Kömek' : 'Помощь'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            ...faq.map(
              (item) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _softLine),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.$1, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text(item.$2, style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.45)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _MasterActionButton(
              label: tk ? 'Goldaw bilen habarlaş' : 'Связаться с поддержкой',
              enabled: true,
              leading: Icons.chat_bubble_outline,
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tk ? 'Goldaw bilen habarlaşylýar...' : 'Связываемся с поддержкой...'))),
            ),
          ],
        ),
      ),
    );
  }
}
