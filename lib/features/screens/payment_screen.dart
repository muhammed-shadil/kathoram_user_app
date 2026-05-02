import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kathoram_user_app/features/home/controller/home_controller.dart';
import 'package:kathoram_user_app/features/home/model/plan_model.dart';
import 'package:kathoram_user_app/features/widgets/custom_button.dart';

class PaymentScreen extends StatelessWidget {
  final PlanModel plan;

  const PaymentScreen({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 18),
          onPressed: () => Get.back(),
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
                        '${plan.noOfCoins}',
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
                        '₹${plan.amount}',
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
                        '₹${plan.amount}',
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
            Obx(() {
              final isLoading = homeController.isPaymentLoading.value;
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(
                        text: 'Proceed To Pay',
                        onPressed: () {
                          homeController.initiatePayment(
                            plan.id,
                            onSuccess: () {
                              Get.back(result: true);
                            },
                          );
                        },
                        isReversed: false,
                      ),
              );
            }),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
