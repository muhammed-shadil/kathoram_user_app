import 'package:flutter/material.dart';

class PaymentBottomSheet extends StatefulWidget {
  final int amount;
  const PaymentBottomSheet({required this.amount});
 
  @override
  State<PaymentBottomSheet> createState() => PaymentBottomSheetState();
}
 
class PaymentBottomSheetState extends State<PaymentBottomSheet> {
  String _selected = 'netbanking';
 
  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'qr',
      'icon': Icons.qr_code,
      'title': 'Show QR Code',
      'subtitle': 'Scan with any UPI app',
    },
    {
      'id': 'upi',
      'icon': Icons.alternate_email,
      'title': 'UPI ID',
      'subtitle': 'PhonePe, Gpay, Paytm, BHIM & more',
    },
    {
      'id': 'card',
      'icon': Icons.credit_card,
      'title': 'Card',
      'subtitle': 'Visa, Mastercard, Rupay & more',
    },
    {
      'id': 'netbanking',
      'icon': Icons.account_balance,
      'title': 'Net Banking',
      'subtitle': 'Choose your bank to complete payment',
    },
  ];
 
  final List<Map<String, dynamic>> _banks = [
    {'name': 'HDFC-S', 'icon': Icons.account_balance},
    {'name': 'UCO-S', 'icon': Icons.account_balance},
    {'name': 'SBIN-S', 'icon': Icons.account_balance},
    {'name': 'Others', 'icon': Icons.more_horiz},
  ];
 
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
 
          // ── Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'KATHORAM',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '₹${widget.amount}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
 
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE0E0E0), thickness: 1),
 
          // ── Payment Methods ──
          ..._methods.map((method) {
            final bool isSelected = _selected == method['id'];
            return InkWell(
              onTap: () => setState(() => _selected = method['id']),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      method['icon'] as IconData,
                      color: isSelected
                          ? const Color(0xFF1E88E5)
                          : Colors.grey,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? const Color(0xFF1E88E5)
                                  : Colors.black87,
                            ),
                          ),
                          Text(
                            method['subtitle'],
                            style: const TextStyle(
                                fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    // Net Banking = green check, others = radio
                    if (method['id'] == 'netbanking' && isSelected)
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20)
                    else
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF1E88E5)
                                : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF1E88E5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                  ],
                ),
              ),
            );
          }),
 
          // ── Banks row (only when net banking selected) ──
          if (_selected == 'netbanking')
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _banks.map((bank) {
                  final bool isActive = bank['name'] == 'HDFC-S';
                  return Column(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF1E88E5)
                                : Colors.grey.shade300,
                            width: isActive ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          bank['icon'] as IconData,
                          color: isActive
                              ? const Color(0xFF1E88E5)
                              : Colors.grey.shade600,
                          size: 26,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        bank['name'],
                        style: TextStyle(
                          fontSize: 11,
                          color: isActive
                              ? const Color(0xFF1E88E5)
                              : Colors.grey.shade600,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
 
          // ── Powered by PhonePe ──
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Powered by ',
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                Icon(Icons.phone_android,
                    size: 14, color: Color(0xFF5F259F)),
                Text(' PhonePe',
                    style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF5F259F),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
 
          const Divider(color: Color(0xFFE0E0E0), thickness: 1),
          const SizedBox(height: 12),
 
          // ── PAY Button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  
                  Navigator.pop(context);// close bottom sheet
                    Navigator.pop(context,true); // close PaymentScreen, pass true as result
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5F259F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'PAY ₹${widget.amount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}