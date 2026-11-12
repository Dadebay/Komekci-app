part of '../../../app/komekci_app.dart';

extension _SendMessageAudienceActions on _SendMessageScreenState {
  String _audienceSubtitle(AppLanguage language, int index) {
    switch (index) {
      case 0:
        return AppStrings.cabinetWillBeSentToAll(
          _eligibleClients.length,
        ).select(language);
      case 1:
        return _selectedIds.isEmpty
            ? AppStrings.cabinetChooseClientsToSendTo2.select(language)
            : AppStrings.cabinetClientsSelected(
                _selectedIds.length,
              ).select(language);
      default:
        return _recentIds.isEmpty
            ? AppStrings.cabinetClientsWithinASpecificTime.select(language)
            : AppStrings.cabinetClientsSelected(
                _recentIds.length,
              ).select(language);
    }
  }

  Future<void> _selectAudience(int index, {required StateSetter update}) async {
    if (index == 1) {
      final result = await Navigator.push<List<String>>(
        context,
        pageRoute(
          SelectedClientsScreen(
            initialSelection: _selectedIds,
            forPush: _pushChannel,
          ),
        ),
      );
      if (result == null) return;
      update(() {
        _audience = 1;
        _selectedIds = result;
      });
      return;
    }
    if (index == 2) {
      final result = await Navigator.push<List<String>>(
        context,
        pageRoute(
          RecentClientsScreen(
            initialSelection: _recentIds,
            forPush: _pushChannel,
          ),
        ),
      );
      if (result == null) return;
      update(() {
        _audience = 2;
        _recentIds = result;
      });
      return;
    }
    update(() => _audience = 0);
  }

  /// Shows who the message will actually reach and asks for a final confirmation before sending.
  Future<void> _confirmAndSend(
    AppLanguage language, {
    required StateSetter update,
  }) async {
    final recipients = _recipients;
    if (_sending ||
        recipients.isEmpty ||
        recipients.length > 50 ||
        _messageController.text.trim().isEmpty ||
        (_pushChannel && _titleController.text.trim().isEmpty)) {
      return;
    }
    final methodLabel = _pushChannel
        ? AppStrings.cabinetPushNotification.select(language)
        : 'SMS';
    final int recipientCount;
    final String recipientLabel;
    switch (_audience) {
      case 0:
        recipientCount = recipients.length;
        recipientLabel = AppStrings.cabinetToAllClients.select(language);
      case 1:
        recipientCount = recipients.length;
        recipientLabel = AppStrings.cabinetToSelectedClients.select(language);
      default:
        recipientCount = recipients.length;
        recipientLabel = AppStrings.cabinetToClientsFromTheRecent.select(
          language,
        );
    }
    final tokens = context.appTokens;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: tokens.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.cabinetConfirmSending.select(language),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.cabinetWillBeSentPeopleContinue(
                    methodLabel,
                    recipientLabel,
                    recipientCount,
                  ).select(language),
                  style: TextStyle(
                    fontSize: 13,
                    color: tokens.textSecondary,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: BorderSide(color: tokens.border),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: () => Navigator.pop(sheetContext, false),
                        child: Text(
                          AppStrings.cabinetCancel.select(language),
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w600,
                            color: tokens.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MasterActionButton(
                        label: AppStrings.cabinetSend.select(language),
                        enabled: true,
                        onTap: () => Navigator.pop(sheetContext, true),
                      ),
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

    if (!_pushChannel) {
      final withPhone = recipients.where((c) => c.phone.isNotEmpty).toList();
      if (withPhone.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              pickTr(
                language,
                tk: 'SMS ibermek üçin müşderiniň telefon belgisi gerek.',
                ru: 'Для SMS нужен номер телефона клиента.',
                en: 'SMS needs the client\'s phone number.',
              ),
            ),
          ),
        );
        return;
      }
      await _sendSmsViaApp(language, withPhone);
      return;
    }
    update(() => _sending = true);
    try {
      final response = await context
          .read<MeRepository>()
          .sendClientNotification(
            title: _titleController.text.trim(),
            body: _messageController.text.trim(),
            accountIds: recipients.map((c) => c.accountId!).toSet().toList(),
          );
      if (!mounted) return;
      final inbox = (response['sent'] as List? ?? const []).length;
      final skipped = (response['skipped'] as List? ?? const []).length;
      final push = response['success_count'] as int? ?? 0;
      final failed = response['failure_count'] as int? ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppStrings.cabinetInboxPushConfirmedFailedSkipped(
              inbox,
              push,
              failed,
              skipped,
            ).select(language),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      final rejected =
          error is ApiException && error.code == ApiErrors.forbidden
          ? error.details['rejected'] as List?
          : null;
      final message = rejected != null && rejected.isNotEmpty
          ? AppStrings.cabinetNothingWasSentUnavailableAccounts(
              rejected.join(', '),
            ).select(language)
          : apiErrorMessage(error, language);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      update(() => _sending = false);
    }
  }
}
