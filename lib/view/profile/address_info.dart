import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/services/alert_service.dart';
import 'package:voiceclub_partner/core/constants/enums.dart';
import 'package:voiceclub_partner/data/models/rewards/gifts.dart';
import 'package:voiceclub_partner/view/milestone/controllers/milestone_rewards_controller.dart';
import 'package:voiceclub_partner/view/widgets/custom_button.dart';
import 'package:voiceclub_partner/features/onboarding/core/localizations/locales/locale_keys.dart';

class AddressInfoScreen extends StatefulWidget {
  final RewardGift gift;

  const AddressInfoScreen({super.key, required this.gift});

  @override
  State<AddressInfoScreen> createState() => _AddressInfoScreenState();
}

class _AddressInfoScreenState extends State<AddressInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _flatController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();
  final _altPhoneController = TextEditingController();
  IndianState? _selectedState;

  // Max limits
  static const int maxName = 50;
  static const int maxFlat = 50;
  static const int maxStreet = 100;
  static const int maxCity = 30;
  static const int maxZip = 6;
  static const int maxPhone = 10;
  static const int maxAltPhone = 10;

  final controller = Get.find<MilestoneRewardsController>();

  @override
  void dispose() {
    _nameController.dispose();
    _flatController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    _altPhoneController.dispose();
    super.dispose();
  }

  String capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }

  void _onSendAddress() {
    if (_formKey.currentState?.validate() ?? false) {
      // Combine all address fields into a comma-separated string
      final String formattedAddress = [
        _nameController.text.trim(),
        _flatController.text.trim(),
        _streetController.text.trim(),
        _cityController.text.trim(),
        _selectedState != null ? _formatStateName(_selectedState!) : '',
        _zipController.text.trim(),
        'Phone: ${_phoneController.text.trim()}',
        _altPhoneController.text.isNotEmpty
            ? 'Alt Phone: ${_altPhoneController.text.trim()}'
            : '',
      ].where((element) => element.isNotEmpty).join(', ');
      Get.back();
      controller.claimGift(
        giftId: widget.gift.id!,
        type: GiftType.GIFT.name,
        address: formattedAddress,
        amount: widget.gift.cashAmount?.toInt() ?? 0,
      );
    } else {
      AlertService.showSnackBar(
        snackBarType: SnackBarType.Error,
        title: LocaleKeys.liveInvalidInput.tr,
        subtitle: LocaleKeys.livePleaseCorrectTheErrorsIn.tr,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: Text(LocaleKeys.liveAddAddress.tr),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                LocaleKeys.liveRequired2.tr,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _nameController,
                label: LocaleKeys.liveEnterYourFullName.tr,
                maxLength: maxName,
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Full name is required'
                            : null,
                textCapitalization: TextCapitalization.words,
              ),
              _buildTextField(
                controller: _flatController,
                label: LocaleKeys.liveFlatHouseNoFloorBuilding.tr,
                maxLength: maxFlat,
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Flat/House/Building is required'
                            : null,
                textCapitalization: TextCapitalization.words,
              ),
              _buildTextField(
                controller: _streetController,
                label: LocaleKeys.liveStreetAddress.tr,
                maxLength: maxStreet,
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'Street address is required'
                            : null,
                textCapitalization: TextCapitalization.words,
              ),
              _buildTextField(
                controller: _cityController,
                label: LocaleKeys.liveCity.tr,
                maxLength: maxCity,
                validator:
                    (v) =>
                        v == null || v.trim().isEmpty
                            ? 'City is required'
                            : null,
                textCapitalization: TextCapitalization.words,
              ),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildStateDropdown()),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _zipController,
                      label: LocaleKeys.liveZipCode.tr,
                      maxLength: maxZip,
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Zip code is required';
                        }
                        if (v.length != maxZip) {
                          return 'Zip code must be 6 digits';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              _buildTextField(
                controller: _phoneController,
                label: LocaleKeys.livePhoneNumber.tr,
                maxLength: maxPhone,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Phone number is required';
                  }
                  if (v.length != maxPhone) {
                    return 'Phone number must be 10 digits';
                  }
                  return null;
                },
              ),
              _buildTextField(
                controller: _altPhoneController,
                label: LocaleKeys.liveAlternateMobileNumber.tr,
                maxLength: maxAltPhone,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Alternate mobile number is required';
                  }
                  if (v.length != maxAltPhone) {
                    return 'Alternate number must be 10 digits';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: LocaleKeys.liveSendAddress.tr,
                onTap: _onSendAddress,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int? maxLength,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          counterText: '',
        ),
        onChanged: (value) {
          final cursorPos = controller.selection;
          controller.text = capitalize(value);
          controller.selection = cursorPos;
        },
      ),
    );
  }

  Widget _buildStateDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<IndianState>(
        initialValue: _selectedState,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: 'State*',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        items:
            IndianState.values
                .map(
                  (state) => DropdownMenuItem(
                    value: state,
                    child: Text(_formatStateName(state)),
                  ),
                )
                .toList(),
        onChanged: (val) {
          setState(() {
            _selectedState = val;
          });
        },
        validator: (val) => val == null ? 'State is required' : null,
      ),
    );
  }

  String _formatStateName(IndianState state) {
    final name = state.name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    );
    return capitalize(name.trim().replaceAll('And ', 'and '));
  }
}
