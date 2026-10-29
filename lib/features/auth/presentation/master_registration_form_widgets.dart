part of '../../../app/komekci_app.dart';

extension _MasterRegistrationFormWidgets on _MasterRegistrationScreenState {
  Widget _label(AppThemeTokens tokens, String text, {bool required = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 2),
    child: Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        if (required)
          Text(
            ' *',
            style: TextStyle(fontSize: 13, color: tokens.danger, fontWeight: FontWeight.w700),
          ),
      ],
    ),
  );

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 6, bottom: 16),
    child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
  );

  /// Wide banner with the round profile photo overlapping its bottom edge.
  Widget _buildPhotoHeader(AppThemeTokens tokens, _Tr t, {required StateSetter update}) {
    final bannerError = _serverErrors[-1] != null || (_showErrors && _banner == null);
    final photoError = _serverErrors[-2] != null || (_showErrors && _photo == null);
    // The Stack is tall enough to contain the whole circle: a tap outside a
    // parent's bounds is never delivered to its children, so a circle hanging
    // out of the banner would only react on the part that overlaps it.
    return Column(
      children: [
        SizedBox(
          // 150 banner; the ring (10 + 4 + 92 + 4 + 10, ~123 px tall) is centred
          // on the banner's bottom edge and must fit inside this box.
          height: 214,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 150,
                child: GestureDetector(
                  onTap: _pickBanner,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: tokens.surfaceElevated,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: bannerError ? tokens.danger : (_banner != null ? tokens.accent : tokens.border), width: bannerError || _banner != null ? 2.5 : 1.5),
                    ),
                    child: _banner != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(21),
                                child: Image.file(_banner!, fit: BoxFit.cover),
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: const AppIcon(Icons.edit_outlined, color: Colors.white, size: 15),
                                ),
                              ),
                            ],
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 34),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AppIcon(Icons.image_outlined, size: 30, color: bannerError ? tokens.danger : tokens.textSecondary),
                                const SizedBox(height: 8),
                                Text(
                                  t(tk: 'Baner suraty goşuň *', ru: 'Добавьте баннер *', en: 'Add a banner *'),
                                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: bannerError ? tokens.danger : tokens.textPrimary),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  t(tk: 'Profiliňiziň ýokarsynda görner', ru: 'Отображается вверху профиля', en: 'Shown at the top of your profile'),
                                  style: TextStyle(fontSize: 11.5, color: tokens.textSecondary),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
              Positioned(
                top: 88,
                left: 0,
                right: 0,
                child: Center(
                  // The whole ring (and the caption below) opens the picker,
                  // not just the photo itself.
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _pickPhoto,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: tokens.surface,
                          border: Border.all(color: photoError ? tokens.danger : (_photo != null ? tokens.accent : tokens.border), width: 1.6),
                        ),
                        child: AvatarPicker(
                          file: _photo,
                          radius: 46,
                          onPicked: (file) => update(() {
                            _photo = file;
                            _serverErrors.remove(-2);
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _pickPhoto,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 24),
            child: Text(
              _photo == null
                  ? t(tk: 'Profil suratyny goşuň *', ru: 'Добавьте фото профиля *', en: 'Add a profile photo *')
                  : t(tk: 'Suraty üýtgetmek üçin basyň', ru: 'Нажмите, чтобы изменить фото', en: 'Tap to change the photo'),
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: photoError ? tokens.danger : tokens.textSecondary),
            ),
          ),
        ),
        if (_serverErrors[-1] != null) _FieldError(_serverErrors[-1]!),
        if (_serverErrors[-2] != null) _FieldError(_serverErrors[-2]!),
      ],
    );
  }

  /// One filled text field with its label and any error underneath.
  Widget _field(
    AppThemeTokens tokens,
    _Tr t, {
    required int index,
    required String label,
    required String hint,
    required IconData icon,
    bool required = true,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    TextCapitalization capitalization = TextCapitalization.none,
    Widget? suffix,
    ValueChanged<String>? onChanged,
    List<TextInputFormatter>? formatters,
  }) {
    final serverError = _serverErrors[index];
    final missing = _showErrors && _missing(index);
    final message = serverError ?? (missing ? t(tk: 'Bu meýdan hökmany', ru: 'Обязательное поле', en: 'This field is required') : null);
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(tokens, label, required: required),
          TextField(
            controller: _controllers[index],
            maxLines: maxLines,
            minLines: maxLines > 1 ? maxLines : null,
            maxLength: maxLength,
            buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
            keyboardType: keyboardType,
            textCapitalization: capitalization,
            inputFormatters: formatters,
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
            decoration: registrationDecoration(tokens, hint: hint, icon: icon, suffix: suffix, error: message != null),
            onChanged: (value) {
              _clearError(index);
              onChanged?.call(value);
            },
          ),
          if (message != null) _FieldError(message),
        ],
      ),
    );
  }

}
