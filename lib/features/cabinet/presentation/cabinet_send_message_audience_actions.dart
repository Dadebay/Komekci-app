part of '../../../app/komekci_app.dart';

extension _SendMessageAudienceActions on _SendMessageScreenState {
  String _audienceSubtitle(AppLanguage language, int index) {
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    switch (index) {
      case 0:
        return t(
          tk: 'Ähli müşderilere iberiler (${_eligibleClients.length} adam).',
          ru: 'Будет отправлено всем клиентам (${_eligibleClients.length} чел.).',
          en: 'Will be sent to all clients (${_eligibleClients.length} people).',
        );
      case 1:
        return _selectedIds.isEmpty
            ? t(
                tk: 'Müşderileri saýlap iberiň.',
                ru: 'Выберите клиентов для отправки.',
                en: 'Choose clients to send to.',
              )
            : t(
                tk: '${_selectedIds.length} müşderi saýlandy.',
                ru: 'Выбрано клиентов: ${_selectedIds.length}.',
                en: '${_selectedIds.length} clients selected.',
              );
      default:
        return _recentIds.isEmpty
            ? t(
                tk: 'Belli bir wagtyň içinde ýazylan müşderiler.',
                ru: 'Клиенты за определённый период.',
                en: 'Clients within a specific time period.',
              )
            : t(
                tk: '${_recentIds.length} müşderi saýlandy.',
                ru: 'Выбрано клиентов: ${_recentIds.length}.',
                en: '${_recentIds.length} clients selected.',
              );
    }
  }

  Future<void> _selectAudience(int index, {required StateSetter update}) async {
    if (index == 1) {
      final result = await Navigator.push<List<String>>(
        context,
        pageRoute(SelectedClientsScreen(initialSelection: _selectedIds, forPush: _pushChannel)),
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
        pageRoute(RecentClientsScreen(initialSelection: _recentIds, forPush: _pushChannel)),
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
  Future<void> _confirmAndSend(AppLanguage language, {required StateSetter update}) async {
    final recipients = _recipients;
    if (_sending || recipients.isEmpty || recipients.length > 50 ||
        _messageController.text.trim().isEmpty ||
        (_pushChannel && _titleController.text.trim().isEmpty)) {
      return;
    }
    String t({required String tk, required String ru, required String en}) =>
        pickTr(language, tk: tk, ru: ru, en: en);
    final methodLabel = _pushChannel
        ? t(tk: 'Push habar', ru: 'Push-уведомление', en: 'Push notification')
        : 'SMS';
    final int recipientCount;
    final String recipientLabel;
    switch (_audience) {
      case 0:
        recipientCount = recipients.length;
        recipientLabel = t(
          tk: 'ähli müşderilere',
          ru: 'всем клиентам',
          en: 'to all clients',
        );
      case 1:
        recipientCount = recipients.length;
        recipientLabel = t(
          tk: 'saýlanan müşderilere',
          ru: 'выбранным клиентам',
          en: 'to selected clients',
        );
      default:
        recipientCount = recipients.length;
        recipientLabel = t(
          tk: 'soňky wagt aralygyndaky müşderilere',
          ru: 'клиентам за период',
          en: 'to clients from the recent period',
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
                  t(
                    tk: 'Habary tassyklaň',
                    ru: 'Подтвердите отправку',
                    en: 'Confirm sending',
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  t(
                    tk: '$methodLabel $recipientLabel iberiler · $recipientCount adam. Dowam etmek isleýärsiňizmi?',
                    ru: '$methodLabel будет отправлено $recipientLabel · $recipientCount чел. Продолжить?',
                    en: '$methodLabel will be sent $recipientLabel · $recipientCount people. Continue?',
                  ),
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
                          t(tk: 'Ýok', ru: 'Отмена', en: 'Cancel'),
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
                        label: t(tk: 'Iber', ru: 'Отправить', en: 'Send'),
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

    if (!_pushChannel && Platform.isAndroid) {
      final numbers = _resolvePhoneNumbers();
      if (numbers.isNotEmpty) {
        update(() => _sending = true);
        try {
          await _sendRealSms(language, numbers);
        } catch (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(
              tk: 'SMS iberilip bilmedi.',
              ru: 'Не удалось отправить SMS.',
              en: 'Could not send the SMS.',
            ))));
          }
        } finally {
          if (mounted) update(() => _sending = false);
        }
        return;
      }
    }
    if (!_pushChannel) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(
        tk: 'SMS ibermek üçin Android we müşderiniň telefon belgisi gerek.',
        ru: 'Для SMS нужен Android и номер телефона клиента.',
        en: 'SMS requires Android and a client phone number.',
      ))));
      return;
    }
    update(() => _sending = true);
    try {
      final response = await context.read<MeRepository>().sendClientNotification(
        title: _titleController.text.trim(),
        body: _messageController.text.trim(),
        accountIds: recipients.map((c) => c.accountId!).toSet().toList(),
      );
      if (!mounted) return;
      final inbox = (response['sent'] as List? ?? const []).length;
      final skipped = (response['skipped'] as List? ?? const []).length;
      final push = response['success_count'] as int? ?? 0;
      final failed = response['failure_count'] as int? ?? 0;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(
        tk: 'Gelen habarlar: $inbox, push tassyklandy: $push, şowsuz: $failed, geçildi: $skipped.',
        ru: 'Входящие: $inbox, push подтверждено: $push, не доставлено: $failed, пропущено: $skipped.',
        en: 'Inbox: $inbox, push confirmed: $push, failed: $failed, skipped: $skipped.',
      ))));
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      final rejected = error is ApiException && error.code == ApiErrors.forbidden
          ? error.details['rejected'] as List?
          : null;
      final message = rejected != null && rejected.isNotEmpty
          ? t(
              tk: 'Habar iberilmedi. Rugsat berilmedik hasaplar: ${rejected.join(', ')}.',
              ru: 'Ничего не отправлено. Недоступные аккаунты: ${rejected.join(', ')}.',
              en: 'Nothing was sent. Unavailable accounts: ${rejected.join(', ')}.',
            )
          : apiErrorMessage(error, language);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      update(() => _sending = false);
    }
  }

}
