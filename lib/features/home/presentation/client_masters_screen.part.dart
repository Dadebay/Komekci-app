part of '../../../app/komekci_app.dart';

/// App bar for [ClientMastersScreen]: the filter action sits on the left
/// (next to the back button, if any) as a bare icon with no circular
/// badge; the search icon sits on the right and, when tapped, swaps the
/// title for an inline search field with a fade + horizontal-size
/// animation instead of pushing a separate search screen.
class _MastersAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _MastersAppBar({
    required this.canPop,
    required this.title,
    required this.searchOpen,
    required this.searchController,
    required this.searchHint,
    required this.hasActiveFilter,
    required this.onToggleSearch,
    required this.onFilterTap,
    required this.onSearchChanged,
  });

  final bool canPop;
  final String title;
  final bool searchOpen;
  final TextEditingController searchController;
  final String searchHint;
  final bool hasActiveFilter;
  final VoidCallback onToggleSearch;
  final VoidCallback onFilterTap;
  final VoidCallback onSearchChanged;

  @override
  Size get preferredSize => const Size.fromHeight(52);

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return AppBar(
      toolbarHeight: 52,
      elevation: 0,
      backgroundColor: tokens.surface,
      centerTitle: true,
      titleSpacing: 0,
      automaticallyImplyLeading: false,
      leadingWidth: canPop ? 92 : 52,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canPop)
            IconButton(
              onPressed: () => Navigator.maybePop(context),
              icon: AppIcon(Icons.arrow_back, color: tokens.textPrimary, size: 20),
            ),
          GestureDetector(
            onTap: onFilterTap,
            child: SizedBox(
              width: 44,
              height: 44,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppIcon(Icons.filter_list, color: hasActiveFilter ? tokens.accent : tokens.textPrimary),
              ),
            ),
          ),
        ],
      ),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SizeTransition(sizeFactor: animation, axis: Axis.horizontal, child: child),
        ),
        child: searchOpen
            ? _AppBarSearchField(
                key: const ValueKey('masters-search-field'),
                controller: searchController,
                hint: searchHint,
                onChanged: onSearchChanged,
              )
            : Text(
                title,
                key: const ValueKey('masters-title'),
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: onToggleSearch,
            child: SizedBox(
              width: 44,
              height: 44,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: AppIcon(searchOpen ? Icons.close : Icons.search, color: tokens.textPrimary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AppBarSearchField extends StatelessWidget {
  const _AppBarSearchField({super.key, required this.controller, required this.hint, required this.onChanged});
  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Container(
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: tokens.surfaceElevated, borderRadius: BorderRadius.circular(12)),
      child: TextField(
        controller: controller,
        autofocus: true,
        onChanged: (_) => onChanged(),
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(fontSize: 14, color: tokens.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13.5, color: tokens.textSecondary),
          prefixIcon: FittedBox(
            fit: BoxFit.scaleDown,
            child: AppIcon(Icons.search, size: 16, color: tokens.textSecondary),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 28, minHeight: 16),
          contentPadding: const EdgeInsets.symmetric(vertical: 9),
        ),
      ),
    );
  }
}

/// Full master directory — the destination for "Ähli masterlar" and the
/// "Masterlar" bottom-nav tab. Filterable by service, location and gender,
/// and searchable by name or specialty.
class ClientMastersScreen extends StatefulWidget {
  const ClientMastersScreen({super.key});

  @override
  State<ClientMastersScreen> createState() => _ClientMastersScreenState();
}

class _ClientMastersScreenState extends State<ClientMastersScreen> {
  final _searchController = TextEditingController();
  bool _searchOpen = false;
  String? _filterService;
  String? _filterLocation;
  String? _filterGender;
  String? _filterTime;

  // Read once at mount instead of on every build: the filter sheet's chip
  // taps call this screen's own setState while the sheet is still open,
  // which would otherwise re-evaluate canPop() while a modal route sits on
  // top of us and briefly (and wrongly) show a back button in the app bar.
  late final bool _canPop = Navigator.of(context).canPop();

  bool get _hasActiveFilter => _filterService != null || _filterLocation != null || _filterGender != null || _filterTime != null;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() => setState(() {
    _searchOpen = !_searchOpen;
    if (!_searchOpen) _searchController.clear();
  });

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final tk = language == AppLanguage.tk;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    final canPop = _canPop;
    final query = _searchController.text.trim().toLowerCase();
    final results = _clientMasters.where((m) {
      if (_filterService != null && !m.serviceIds.contains(_filterService)) {
        return false;
      }
      if (_filterLocation != null && m.locationId != _filterLocation) {
        return false;
      }
      if (_filterGender != null && m.gender != _filterGender) return false;
      if (query.isEmpty) return true;
      final name = (tk ? m.nameTk : m.nameRu).toLowerCase();
      final specialty = (tk ? m.specialtyTk : m.specialtyRu).toLowerCase();
      return name.contains(query) || specialty.contains(query);
    }).toList();
    if (query.isNotEmpty) {
      debugPrint('[ClientMastersScreen] "$query" -> ${results.length}/${_clientMasters.length} masters matched (local filter, no network request)');
    }

    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: _MastersAppBar(
        canPop: canPop,
        title: t(tk: 'Masterlar', ru: 'Мастера', en: 'Masters'),
        searchOpen: _searchOpen,
        searchController: _searchController,
        searchHint: t(tk: 'Ussany gözle', ru: 'Найти мастера', en: 'Search for a master'),
        hasActiveFilter: _hasActiveFilter,
        onToggleSearch: _toggleSearch,
        onFilterTap: () => _openFilterSheet(context),
        onSearchChanged: () {
          debugPrint('[ClientMastersScreen] local search query: "${_searchController.text}" (no backend API — filters the in-memory _clientMasters mock list)');
          setState(() {});
        },
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 16, 20, canPop ? 20 : 110),
          children: [
            if (results.isEmpty)
              EmptyState(
                icon: Icons.person_search_outlined,
                title: t(tk: 'Master tapylmady', ru: 'Мастера не найдены', en: 'No masters found'),
                text: t(tk: 'Gözlegi ýa-da süzgüçi üýtgediň.', ru: 'Измените поиск или фильтр.', en: 'Try a different search or filter.'),
              )
            else
              ...results.asMap().entries.map(
                (e) => _FadeSlideIn(index: e.key, child: _ClientMasterListRow(master: e.value, tk: tk)),
              ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: context.appTokens.surface,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (_) => _MasterFilterSheet(
      initialService: _filterService,
      initialLocation: _filterLocation,
      initialGender: _filterGender,
      initialTime: _filterTime,
      onApply: (service, location, gender, time) => setState(() {
        _filterService = service;
        _filterLocation = location;
        _filterGender = gender;
        _filterTime = time;
      }),
    ),
  );
}

/// Fades and slides a list item up into place on first build, staggered by
/// [index] so results cascade in rather than popping in all at once.
class _FadeSlideIn extends StatefulWidget {
  const _FadeSlideIn({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<_FadeSlideIn> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  late final _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  late final _slide = Tween<Offset>(begin: const Offset(0, .08), end: Offset.zero)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 28 * widget.index.clamp(0, 12)), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _fade,
    child: SlideTransition(position: _slide, child: widget.child),
  );
}

/// The "Filtrler" bottom sheet — service, location, gender and available-time
/// sections, each a collapsible row of chips, applied together via "Görkez".
class _MasterFilterSheet extends StatefulWidget {
  const _MasterFilterSheet({required this.initialService, required this.initialLocation, required this.initialGender, required this.initialTime, required this.onApply});
  final String? initialService;
  final String? initialLocation;
  final String? initialGender;
  final String? initialTime;
  final void Function(String? service, String? location, String? gender, String? time) onApply;

  @override
  State<_MasterFilterSheet> createState() => _MasterFilterSheetState();
}

class _MasterFilterSheetState extends State<_MasterFilterSheet> {
  late String? _service = widget.initialService;
  late String? _location = widget.initialLocation;
  late String? _gender = widget.initialGender;
  late String? _time = widget.initialTime;

  bool _serviceExpanded = true;
  bool _locationExpanded = true;
  bool _genderExpanded = true;
  bool _timeExpanded = true;

  int get _resultCount => _clientMasters.where((m) {
    if (_service != null && !m.serviceIds.contains(_service)) return false;
    if (_location != null && m.locationId != _location) return false;
    if (_gender != null && m.gender != _gender) return false;
    return true;
  }).length;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    String t({required String tk, required String ru, required String en}) => pickTr(language, tk: tk, ru: ru, en: en);
    final tokens = context.appTokens;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .82),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: tokens.border, borderRadius: BorderRadius.circular(4)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      t(tk: 'Filtrler', ru: 'Фильтры', en: 'Filters'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() {
                      _service = null;
                      _location = null;
                      _gender = null;
                      _time = null;
                    }),
                    child: Text(
                      t(tk: 'Arassalamak', ru: 'Очистить', en: 'Clear'),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: tokens.accent),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FilterSection(
                      icon: Icons.content_cut,
                      title: t(tk: 'Hyzmat', ru: 'Услуга', en: 'Service'),
                      expanded: _serviceExpanded,
                      onToggle: () => setState(() => _serviceExpanded = !_serviceExpanded),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChipButton(
                            label: t(tk: 'Ähli hyzmatlar', ru: 'Все услуги', en: 'All services'),
                            selected: _service == null,
                            onTap: () => setState(() => _service = null),
                          ),
                          ..._serviceFilters.map(
                            (item) => _FilterChipButton(
                              label: pickTr(language, tk: item.$2, ru: item.$3, en: item.$4),
                              selected: _service == item.$1,
                              onTap: () => setState(() => _service = item.$1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 24, color: tokens.border),
                    _FilterSection(
                      icon: Icons.location_on_outlined,
                      title: t(tk: 'Ýerleşýän ýeri', ru: 'Расположение', en: 'Location'),
                      expanded: _locationExpanded,
                      onToggle: () => setState(() => _locationExpanded = !_locationExpanded),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChipButton(
                            label: t(tk: 'Ähli ýerleşýän ýerler', ru: 'Все районы', en: 'All areas'),
                            selected: _location == null,
                            onTap: () => setState(() => _location = null),
                          ),
                          ..._locationFilters.map(
                            (item) => _FilterChipButton(
                              label: pickTr(language, tk: item.$2, ru: item.$3, en: item.$4),
                              selected: _location == item.$1,
                              onTap: () => setState(() => _location = item.$1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 24, color: tokens.border),
                    _FilterSection(
                      icon: Icons.person_outline,
                      title: t(tk: 'Jyns', ru: 'Пол', en: 'Gender'),
                      expanded: _genderExpanded,
                      onToggle: () => setState(() => _genderExpanded = !_genderExpanded),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChipButton(
                            label: t(tk: 'Ähli', ru: 'Все', en: 'All'),
                            selected: _gender == null,
                            onTap: () => setState(() => _gender = null),
                          ),
                          _FilterChipButton(
                            label: t(tk: 'Erkek', ru: 'Мужской', en: 'Male'),
                            selected: _gender == 'male',
                            onTap: () => setState(() => _gender = 'male'),
                          ),
                          _FilterChipButton(
                            label: t(tk: 'Aýal', ru: 'Женский', en: 'Female'),
                            selected: _gender == 'female',
                            onTap: () => setState(() => _gender = 'female'),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 24, color: tokens.border),
                    _FilterSection(
                      icon: Icons.schedule_outlined,
                      title: t(tk: 'Elýeterli wagt', ru: 'Доступное время', en: 'Available time'),
                      expanded: _timeExpanded,
                      onToggle: () => setState(() => _timeExpanded = !_timeExpanded),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _FilterChipButton(
                            label: t(tk: 'Ähli wagtlar', ru: 'Любое время', en: 'Any time'),
                            selected: _time == null,
                            onTap: () => setState(() => _time = null),
                          ),
                          ..._timeFilters.map(
                            (item) => _FilterChipButton(
                              label: pickTr(language, tk: item.$2, ru: item.$3, en: item.$4),
                              selected: _time == item.$1,
                              onTap: () => setState(() => _time = item.$1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: tokens.textPrimary, shape: const StadiumBorder()),
                  onPressed: () {
                    widget.onApply(_service, _location, _gender, _time);
                    Navigator.pop(context);
                  },
                  child: Text(
                    '${t(tk: 'Görkez', ru: 'Показать', en: 'Show')} ($_resultCount)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.icon, required this.title, required this.expanded, required this.onToggle, required this.child});
  final IconData icon;
  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                AppIcon(icon, size: 17, color: tokens.textPrimary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700)),
                ),
                AppIcon(expanded ? Icons.expand_less : Icons.expand_more, size: 18, color: tokens.textSecondary),
              ],
            ),
          ),
        ),
        if (expanded) Padding(padding: const EdgeInsets.only(bottom: 6), child: child),
      ],
    );
  }
}

class _FilterChipButton extends StatelessWidget {
  const _FilterChipButton({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.appTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? tokens.textPrimary : tokens.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? tokens.textPrimary : tokens.border),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: selected ? tokens.surface : tokens.textPrimary),
        ),
      ),
    );
  }
}
