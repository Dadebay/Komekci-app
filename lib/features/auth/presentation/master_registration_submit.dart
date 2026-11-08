part of '../../../app/komekci_app.dart';

extension _MasterRegistrationSubmit on _MasterRegistrationScreenState {
  Future<void> _continueRegistration(
    String Function({
      required String tk,
      required String ru,
      required String en,
    })
    t, {
    required StateSetter update,
  }) async {
    if (_submitting) return;
    if (!_complete) {
      update(() => _showErrors = true);
      return;
    }
    final language = context.read<LanguageProvider>().language;
    final auth = context.read<AuthProvider>();
    final authRepository = context.read<AuthRepository>();
    final nickname = _text(
      _MasterRegistrationScreenState._nicknameIndex,
    ).toLowerCase().replaceFirst('@', '');
    if (!nicknamePattern.hasMatch(nickname)) {
      update(() {
        _showErrors = true;
        _serverErrors[_MasterRegistrationScreenState._nicknameIndex] = t(
          tk: '3-20 harp: kiçi harp, san we _ (sanly başlanyp bilmez)',
          ru: '3-20 символов: строчные буквы, цифры и _ (не с цифры)',
          en: '3-20 chars: lowercase letters, numbers and _ (no leading digit)',
        );
      });
      return;
    }
    update(() {
      _submitting = true;
      _formError = null;
      _phoneTaken = false;
      _serverErrors.clear();
    });
    final data = RegistrationData(
      role: 'master',
      name: _text(_MasterRegistrationScreenState._nameIndex),
      nickname: nickname,
      phone: widget.phone,
      locale: context.read<AppSettingsProvider>().locales.isEmpty
          ? null
          : language.name,
      photoPath: _photo?.path,
      address: _text(_MasterRegistrationScreenState._addressIndex),
      description: _text(_MasterRegistrationScreenState._aboutIndex),
      bannerPath: _banner?.path,
      instagramUrl: socialUrl(
        _text(_MasterRegistrationScreenState._instagramIndex),
        host: 'instagram.com',
      ),
      tiktokUrl: socialUrl(
        _text(_MasterRegistrationScreenState._tiktokIndex),
        host: 'tiktok.com',
        atPrefix: true,
      ),
    );
    try {
      final check = await authRepository.nicknameAvailable(nickname);
      if (!check.available) {
        if (!mounted) return;
        update(() {
          _submitting = false;
          _nicknameSuggestions = check.suggestions;
          _nicknameState = _NicknameState.taken;
          _serverErrors[_MasterRegistrationScreenState._nicknameIndex] = t(
            tk: 'Bu lakam eýesiz däl',
            ru: 'Этот никнейм уже занят',
            en: 'This nickname is taken',
          );
        });
        return;
      }
      await auth.register(data);
    } catch (error) {
      if (!mounted) return;
      _showRegistrationError(error, language, update: update);
      return;
    }
    if (!mounted) return;
    update(() => _submitting = false);
    Navigator.push(
      context,
      pageRoute(MasterOtpScreen(phone: widget.phone, registration: data)),
    );
  }

  void _showRegistrationError(
    Object error,
    AppLanguage language, {
    required StateSetter update,
  }) {
    update(() {
      _submitting = false;
      if (error is ApiException) {
        if (error.code == ApiErrors.phoneTaken) {
          _phoneTaken = true;
          _formError = error.localized(language);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) showPhoneTakenDialog(context, widget.phone);
          });
          return;
        }
        if (error.code == ApiErrors.nicknameTaken) {
          _nicknameSuggestions = error.nicknameSuggestions;
          _serverErrors[_MasterRegistrationScreenState._nicknameIndex] = error
              .localized(language);
          return;
        }
        if (error.code == ApiErrors.validation) {
          const fieldIndex = {
            'name': _MasterRegistrationScreenState._nameIndex,
            'nickname': _MasterRegistrationScreenState._nicknameIndex,
            'address': _MasterRegistrationScreenState._addressIndex,
            'description': _MasterRegistrationScreenState._aboutIndex,
            'instagram_url': _MasterRegistrationScreenState._instagramIndex,
            'tiktok_url': _MasterRegistrationScreenState._tiktokIndex,
            'banner': -1,
            'photo': -2,
          };
          for (final e in error.fieldErrors.entries) {
            final index = fieldIndex[e.key];
            if (index != null) _serverErrors[index] = e.value;
          }
          if (_serverErrors.isNotEmpty) return;
        }
      }
      _formError = apiErrorMessage(error, language);
    });
  }
}
