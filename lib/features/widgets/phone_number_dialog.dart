import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kathoram_user_app/theme/app_colors.dart';

/// Asks for a 10-digit Indian mobile number before a payment.
///
/// Shown when /payment/initiate answers responseCode 130 (PHONE_REQUIRED):
/// Cashfree needs a phone number and Google sign-in users don't have one.
/// Pops with the entered number, or `null` if the user cancels.
class PhoneNumberDialog extends StatefulWidget {
  /// Error from the previous attempt (e.g. the backend's
  /// "Enter a valid 10-digit mobile number").
  final String? errorText;
  final String initialValue;

  const PhoneNumberDialog({
    super.key,
    this.errorText,
    this.initialValue = '',
  });

  @override
  State<PhoneNumberDialog> createState() => _PhoneNumberDialogState();
}

class _PhoneNumberDialogState extends State<PhoneNumberDialog> {
  static const _invalidMessage = 'Enter a valid 10-digit mobile number';

  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _error = widget.errorText;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final phone = _controller.text.trim();
    if (phone.length != 10) {
      setState(() => _error = _invalidMessage);
      return;
    }
    // The backend does the full validation; a rejected number comes back
    // here as [errorText].
    Navigator.of(context).pop(phone);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Mobile number required',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your mobile number to continue with the payment. '
            'You will only be asked once.',
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              prefixText: '+91 ',
              hintText: '10-digit mobile number',
              counterText: '',
              errorText: _error,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(
            'Continue',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
