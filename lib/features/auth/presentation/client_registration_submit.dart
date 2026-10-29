part of '../../../app/komekci_app.dart';

extension _ClientRegistrationSubmit on _ClientRegistrationScreenState {
  String? _validateName(_Tr t) {
    final length = _nameController.text.trim().length;
    if (length < 2 || length > 50) {
      return t(
        tk: 'Ady 2-50 harp aralygynda giriziň',
        ru: 'Имя должно быть от 2 до 50 символов',
        en: 'Name must be 2-50 characters',
      );
    }
    return null;
  }

  String? _validateNickname(_Tr t) {
    if (!nicknamePattern.hasMatch(_nickname)) {
      return t(
        tk: '3-20 harp: kiçi harp, san we _ (sanly başlanyp bilmez)',
        ru: '3-20 символов: строчные буквы, цифры и _ (не с цифры)',
        en: '3-20 chars: lowercase letters, numbers and _ (no leading digit)',
      );
    }
    if (_nicknameState == _NicknameState.taken) {
      return t(
        tk: 'Bu lakam eýesiz däl',
        ru: 'Этот никнейм уже занят',
        en: 'This nickname is taken',
      );
    }
    return null;
  }

  String? _validatePhone(_Tr t) {
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) {
      return t(
        tk: 'Telefon belgini dolduryň (8 san)',
        ru: 'Введите номер полностью (8 цифр)',
        en: 'Enter the full number (8 digits)',
      );
    }
    return null;
  }

  Future<void> _submitRegistration(_Tr t, {required StateSetter update}) async {
    if (_submitting) return;
    final nameError = _validateName(t);
    final nicknameError = _validateNickname(t);
    final phoneError = _validatePhone(t);
    final photoError = _photo == null
        ? t(
            tk: 'Profil suraty hökmany',
            ru: 'Фото профиля обязательно',
            en: 'A profile photo is required',
          )
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
          _nicknameError = t(
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
