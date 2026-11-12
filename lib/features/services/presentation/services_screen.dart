part of '../../../app/komekci_app.dart';

/// Durations offered as quick-pick chips on the service form.
const _serviceDurations = [15, 20, 30, 45, 60, 90, 120, 150];

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  bool _openingService = false;

  Future<bool> _offerFreeMonth({bool afterService = false}) async {
    final language = context.read<LanguageProvider>().language;
    return _showFreeMonthDialog(
      context,
      title: AppStrings.services1MonthFree.select(language),
      message: afterService
          ? AppStrings.servicesYourServiceWasAddedActivate.select(language)
          : AppStrings.servicesUseYourFirstMonthFor.select(language),
      steps: afterService
          ? [
              AppStrings.servicesActivateTheFreeMonth.select(language),
              AppStrings.servicesPaymentIsNeededAfterThe.select(language),
            ]
          : [
              AppStrings.servicesActivateTheFreeMonth.select(language),
              AppStrings.servicesAddYourService.select(language),
              AppStrings.servicesPaymentIsNeededAfterThe.select(language),
            ],
      confirmLabel: AppStrings.servicesUseFreeMonth.select(language),
      cancelLabel: AppStrings.servicesLater.select(language),
    );
  }

  void _showPromoError(Object error) {
    final language = context.read<LanguageProvider>().language;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(apiErrorMessage(error, language))));
  }

  Future<void> _openCreateService() async {
    if (_openingService) return;
    setState(() => _openingService = true);
    try {
      final billing = context.read<BillingProvider>();
      PromoStatus? promo = billing.promo;
      if (promo == null) {
        try {
          promo = await context.read<BillingRepository>().promo();
        } catch (_) {
          // Service creation will still get the server's access check.
        }
      }
      if (!mounted) return;
      if (promo?.needsTopup == true) {
        await Navigator.push(
          context,
          pageRoute(const MasterSubscriptionScreen(onboarding: false)),
        );
        return;
      }
      if (promo?.isAvailable == true) {
        final accepted = await _offerFreeMonth();
        if (!accepted || !mounted) return;
        try {
          await billing.activatePromo();
        } on ApiException catch (error) {
          if (!mounted) return;
          if (error.code == ApiErrors.servicesRequired) {
            final before = context.read<ServiceProvider>().services.length;
            await Navigator.push(context, pageRoute(const ServiceFormScreen()));
            if (!mounted ||
                context.read<ServiceProvider>().services.length <= before) {
              return;
            }
            if (await _offerFreeMonth(afterService: true) && mounted) {
              try {
                await billing.activatePromo();
              } catch (retryError) {
                if (mounted) _showPromoError(retryError);
              }
            }
            return;
          }
          if (error.code == ApiErrors.promoAlreadyUsed) {
            await billing.refresh();
            if (!mounted) return;
            if (billing.promo?.needsTopup == true) {
              await Navigator.push(
                context,
                pageRoute(const MasterSubscriptionScreen(onboarding: false)),
              );
              return;
            }
            if (billing.promo?.active != true &&
                billing.promo?.paidAccess != true) {
              _showPromoError(error);
              return;
            }
          } else {
            _showPromoError(error);
            return;
          }
        } catch (error) {
          if (mounted) _showPromoError(error);
          return;
        }
      }
      if (mounted) {
        await Navigator.push(context, pageRoute(const ServiceFormScreen()));
      }
    } finally {
      if (mounted) setState(() => _openingService = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageProvider>().language;
    final provider = context.watch<ServiceProvider>();
    final services = provider.services;
    final hidden = services.where((s) => !s.active).length;
    final tokens = context.appTokens;
    return Scaffold(
      backgroundColor: tokens.surface,
      appBar: CabinetAppBar(
        title: AppStrings.servicesServices.select(language),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openingService ? null : _openCreateService,
        backgroundColor: tokens.accent,
        foregroundColor: tokens.accentOn,
        elevation: 4,
        icon: const AppIcon(Icons.add, size: 22),
        label: Text(
          AppStrings.servicesAddService2.select(language),
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: ListView(
          // Bottom room so the last card is not hidden behind the button.
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 100),
          children: [
            if (services.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ServicesPill(
                    label: AppStrings.servicesServices2(
                      services.length,
                    ).select(language),
                    color: tokens.accent,
                  ),
                  _ServicesPill(
                    label: AppStrings.servicesVisible(
                      services.length - hidden,
                    ).select(language),
                    color: tokens.success,
                  ),
                  if (hidden > 0)
                    _ServicesPill(
                      label: AppStrings.servicesHidden(hidden).select(language),
                      color: tokens.textSecondary,
                    ),
                ],
              ),
            ],
            if (services.isNotEmpty) const SizedBox(height: 14),
            if (services.isEmpty && provider.loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                ),
              )
            else if (services.isEmpty)
              EmptyState(
                icon: Icons.content_cut,
                title: AppStrings.servicesNoServicesYet.select(language),
                text: AppStrings.servicesTapAddServiceBelowTo.select(language),
              )
            else
              ...services.map((service) => _ServiceCard(service: service)),
          ],
        ),
      ),
    );
  }
}

class _ServicesPill extends StatelessWidget {
  const _ServicesPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
    ),
  );
}
