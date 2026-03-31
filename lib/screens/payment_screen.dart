import 'package:flutter/material.dart';
import 'package:kathoram_app/widgets/custom_button.dart';



import 'package:flutter/material.dart';
import 'package:kathoram_app/models/coins_model.dart';
import 'package:kathoram_app/widgets/pay_bottom_sheet.dart';

class PaymentScreen extends StatelessWidget {
  final CoinPack pack;

  const PaymentScreen({super.key, required this.pack});

//Bottomsheet

 void _showPaymentBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentBottomSheet(amount: pack.price),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Summary Card ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1E88E5),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  // Total Coins
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Coins',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        '${pack.coins}',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      Text(
                        '₹${pack.price}',
                        style:
                            const TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Divider(
                    color: Color(0xFFE0E0E0),
                    thickness: 1,
                    height: 1,
                  ),

                  const SizedBox(height: 12),

                  // Total Payable Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable Amount',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        '₹${pack.price}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E88E5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Proceed To Pay Button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: CustomButton(
                text: 'Proceed To Pay',
                onPressed: () {
                  _showPaymentBottomSheet(context);
                }, 
                isReversed: false,
            ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
// class PaymentScreen extends StatelessWidget {
//   final int coins;
//   final int price;

//   const PaymentScreen({
//     super.key,
//     required this.coins,
//     required this.price,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade100,
//       appBar: AppBar(
//         backgroundColor: Colors.grey.shade100,
//         elevation: 0,
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Payment',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.w700,
//             color: Colors.black,
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // ── Payment Summary Card ──
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: const Color.fromARGB(255, 240, 240, 243),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: const Color(0xFF1E88E5),
//                   width: 1.5,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // ── Total Coins row ──
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Total Coins',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Text(
//                         '$coins',
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 8),

//                   // ── Amount row ──
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Amount',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Text(
//                         '₹$price',
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 12),

//                   // ── Divider ──
//                   const Divider(
//                     color: Color(0xFFE0E0E0),
//                     thickness: 1,
//                     height: 1,
//                   ),

//                   const SizedBox(height: 12),

//                   // ── Total Payable Amount row ──
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Total Payable Amount',
//                         style: TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.black,
//                         ),
//                       ),
//                       Text(
//                         '₹$price',
//                         style: const TextStyle(
//                           fontSize: 14,
//                           fontWeight: FontWeight.w700,
//                           color: Color(0xFF1E88E5),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),

//             const Spacer(),

//             // ── Proceed To Pay Button ──
//             SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: CustomButton(
//                   text: 'Proceed To Pay',
//                   onPressed: () {
//       showModalBottomSheet(
//         context: context,
//         isScrollControlled: true,
//         backgroundColor: Colors.transparent,
//         builder: (_) => StatefulBuilder(
//           builder: (context, setSheetState) {
//             String selected = 'netbanking';
//             return _PaymentBottomSheet(
//               amount: amount,
//               selectedMethod: selected,
//               onMethodSelected: (method) {
//                 setSheetState(() => selected = method);
//               },
//               onPay: () {
//                 // TODO: handle payment
//                 Navigator.pop(context);
//               },
//             );
//           },
//         ),
//       );
//     },
//                   isReversed: false,
//                 )
//                 //  ElevatedButton(
//                 //   onPressed: () {
//                 //     // TODO: handle payment
//                 //   },
//                 //   style: ElevatedButton.styleFrom(
//                 //     backgroundColor: const Color(0xFF1E88E5),
//                 //     shape: RoundedRectangleBorder(
//                 //       borderRadius: BorderRadius.circular(30),
//                 //     ),
//                 //     elevation: 0,
//                 //   ),
//                 //   child: const Text(
//                 //     'Proceed To Pay',
//                 //     style: TextStyle(
//                 //       color: Colors.white,
//                 //       fontSize: 16,
//                 //       fontWeight: FontWeight.w600,
//                 //     ),
//                 //   ),
//                 // ),

//                 ),

//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
// }
