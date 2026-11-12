part of '../../../app/komekci_app.dart';

extension _ClientRegistrationSubmit on _ClientRegistrationScreenState {
  String? _validateName(_Tr t) {
    final length = _nameController.text.trim().length;
    if (length < 2 || length > 50) {
      return AppStrings.profileNameMustBe250.select(context.read<LanguageProvider>().language);
    }
    return null;
  }

  String? _validateNickname(_Tr t) {
    if (!nicknamePattern.hasMatch(_nickname)) {
      return AppStrings.auth320CharsLowercaseLetters.select(context.read<LanguageProvider>().language);
    }
    if (_nicknameState == _NicknameState.taken) {
      return AppStrings.authThisNicknameIsTaken.select(context.read<LanguageProvider>().language);
    }
    return null;
  }

  String? _validatePhone(_Tr t) {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      return AppStrings.profileEnterTheFullNumber8.select(context.read<LanguageProvider>().language);
    }
    return null;
  }

  Future<void> _submitRegistration(_Tr t, {required StateSetter update}) async {
    if (_submitting) return;
    final nameError = _validateName(t);
    final nicknameError = _validateNickname(t);
    final phoneError = _validatePhone(t);
    final photoError = _photo == null
        ? AppStrings.authAProfilePhotoIsRequired.select(context.read<LanguageProvider>().language)
        : null;
    update(() {
      _nameError = nameError;
      _nicknameError = nicknameError;
      _phoneError = phoneError;
      _photoError = photoError;
      _formError = null;
      _phoneTaken = false;
    });
    if (nameError != null ||
        nicknameError != null ||
        phoneError != null ||
        photoError != null) {
      return;
    }

    final language = context.read<LanguageProvider>().language;
    final auth = context.read<AuthProvider>();
    final authRepository = context.read<AuthRepository>();
    final phone = toApiPhone(_phoneController.text);
    final nickname = _nickname;
    final data = RegistrationData(
      role: 'client',
      name: _nameController.text.trim(),
      nickname: nickname,
      phone: phone,
      locale: context.read<AppSettingsProvider>().locales.isEmpty
          ? null
          : language.name,
      photoPath: _photo?.path,
    );
    update(() => _submitting = true);
    try {
      final check = await authRepository.nicknameAvailable(nickname);
      if (!check.available) {
        if (!mounted) return;
        update(() {
          _submitting = false;
          _nicknameState = _NicknameState.taken;
          _nicknameSuggestions = check.suggestions;
          _nicknameError = AppStrings.authThisNicknameIsTaken.select(context.read<LanguageProvider>().language);
        });
        return;
      }
      await auth.register(data);
    } catch (error) {
      if (!mounted) return;
      _showError(error, language, update: update);
      return;
    }
    if (!mounted) return;
    update(() => _submitting = false);
    Navigator.push(
      context,
      pageRoute(
        OtpScreen(
          phone: phone,
          nextBuilder: (_) => const ConnectMasterScreen(),
          onResend: () => auth.register(data),
        ),
      ),
    );
  }

  void _showError(
    Object error,
    AppLanguage language, {
    required StateSetter update,
  }) {
    update(() {
      _submitting = false;
      if (error is ApiException) {
        switch (error.code) {
          case ApiErrors.nicknameTaken:
            _nicknameState = _NicknameState.taken;
            _nicknameSuggestions = error.nicknameSuggestions;
            _nicknameError = error.localized(language);
            return;
          case ApiErrors.phoneTaken:
            _phoneError = error.localized(language);
            _phoneTaken = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                showPhoneTakenDialog(
                  context,
                  toApiPhone(_phoneController.text),
                );
              }
            });
            return;
          case ApiErrors.validation:
            final fields = error.fieldErrors;
            _nameError = fields['name'];
            _nicknameError = fields['nickname'];
            _phoneError = fields['phone'];
            _photoError = fields['photo'];
            if (fields.isNotEmpty) return;
        }
      }
      _formError = apiErrorMessage(error, language);
    });
  }
}
