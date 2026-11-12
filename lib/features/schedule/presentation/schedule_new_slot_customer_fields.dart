part of '../../../app/komekci_app.dart';

extension _NewSlotCustomerFields on _NewSlotAppointmentSheetState {
  List<Widget> _customerFields({
    required AppLanguage language,
    required StateSetter update,
  }) {
    final tokens = context.appTokens;
    return [
      _NewBookingSectionTitle(
        number: 1,
        title: AppStrings.scheduleChooseACustomer.select(language),
      ),
      const SizedBox(height: 10),
      if (_mode == _NewSlotCustomerMode.existing && _selectedCustomer != null)
        Material(
          color: tokens.surfaceElevated == tokens.surface
              ? tokens.surface
              : tokens.accent.withValues(alpha: .08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: tokens.accent, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _pickExistingCustomer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  _CustomerAvatar(customer: _selectedCustomer!, radius: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedCustomer!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: tokens.textPrimary,
                          ),
                        ),
                        if (_selectedCustomer!.phone.isNotEmpty)
                          Text(
                            _selectedCustomer!.phone,
                            style: TextStyle(
                              fontSize: 12,
                              color: tokens.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.profileChange.select(language),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: tokens.accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      else ...[
        _ChoiceCard(
          icon: Icons.people_outline,
          title: AppStrings.scheduleChooseFromCustomers.select(language),
          subtitle: AppStrings.schedulePickAnExistingCustomer.select(language),
          selected: false,
          onTap: _pickExistingCustomer,
        ),
        const SizedBox(height: 8),
        _ChoiceCard(
          icon: Icons.person_add_alt_1,
          title: AppStrings.scheduleAddANewCustomer.select(language),
          subtitle: AppStrings.scheduleAddANewCustomerManually.select(language),
          selected: _mode == _NewSlotCustomerMode.brandNew,
          onTap: () => update(() => _mode = _NewSlotCustomerMode.brandNew),
        ),
      ],
      if (_mode == _NewSlotCustomerMode.brandNew) ...[
        const SizedBox(height: 12),
        _FormField(
          controller: _newNameController,
          hint: AppStrings.scheduleFirstAndLastName.select(language),
          invalid: _showErrors && _newNameController.text.trim().isEmpty,
          onChanged: () => update(() {}),
        ),
        const SizedBox(height: 10),
        _FormField(
          controller: _newPhoneController,
          hint: '65 123456',
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => FocusScope.of(context).unfocus(),
          prefixIcon: phonePrefix(context, fontSize: 14),
          inputFormatters: [_PhoneNumberFormatter()],
          invalid: _showErrors && !_newCustomerOk,
          onChanged: () => update(() {}),
        ),
      ],
      if (_showErrors && !_customerOk) _ErrorText(language: language),
      const SizedBox(height: 22),
    ];
  }
}
