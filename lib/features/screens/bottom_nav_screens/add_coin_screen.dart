import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kathoram_user_app/features/authentication/controller/auth_controller.dart';
import 'package:kathoram_user_app/features/home/controller/home_controller.dart';
import 'package:kathoram_user_app/features/home/model/plan_model.dart';
import 'package:kathoram_user_app/features/screens/payment_screen.dart';
import 'package:kathoram_user_app/features/widgets/shimmer_loaders.dart';

class AddCoinsScreen extends StatefulWidget {
  const AddCoinsScreen({super.key});

  @override
  State<AddCoinsScreen> createState() => _AddCoinsScreenState();
}

class _AddCoinsScreenState extends State<AddCoinsScreen> {
  bool _showSuccess = false;
  late final HomeController homeController;
  late final AuthController authController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();
    authController = Get.find<AuthController>();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !homeController.isPlansLoading.value &&
          homeController.hasMorePages.value) {
        homeController.fetchPlans(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Pull-to-refresh: re-pull the plans AND the coin balance shown in the app
  /// bar. Run together so the indicator stays up until both have landed.
  Future<void> _refresh() async {
    await Future.wait([
      homeController.fetchPlans(),
      authController.checkIsLogin(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: const Text(
          'Add Coins',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Obx(() {
              final coins = authController.userProfile.value?.userCoins ?? 0;
              return Row(
                children: [
                  Image.asset('assets/images/coin.png', width: 24),
                  const SizedBox(width: 5),
                  Text(
                    '$coins',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.black,
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),

      /// BODY
      body: Stack(
        children: [
          Obx(() {
            final plansList = homeController.plans;
            final isLoading = homeController.isPlansLoading.value;

            if (isLoading && plansList.isEmpty) {
              return const PlansGridShimmer();
            }

            if (plansList.isEmpty) {
              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView(
                  // Without this the short placeholder content isn't
                  // overscrollable, so the pull gesture never reaches the
                  // RefreshIndicator.
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 200),
                    Center(
                      child: Text(
                        'No plans available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: GridView.builder(
                    controller: _scrollController,
                    // A handful of plans doesn't fill the viewport, and the
                    // default physics refuse to scroll non-overflowing content
                    // — which also swallows the pull-to-refresh gesture.
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: plansList.length + (isLoading ? 1 : 0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemBuilder: (context, index) {
                      // Loading indicator at the end
                      if (index >= plansList.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final plan = plansList[index];

                      return _buildPlanCard(plan);
                    },
                  ),
                ),
              ),
            );
          }),

          /// SUCCESS POPUP
          if (_showSuccess)
            GestureDetector(
              onTap: () => setState(() => _showSuccess = false),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    width: 260,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/done.png',
                          width: 70,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Coin Added!',
                          style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(PlanModel plan) {
    return GestureDetector(
      onTap: () async {
        final result = await Get.to(
          () => PaymentScreen(plan: plan),
        );

        if (result == true) {
          // Refresh user profile to ensure coins are updated
          await authController.checkIsLogin();
          setState(() => _showSuccess = true);
        }
      },
      child: Stack(
        children: [
          /// CARD
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              image: const DecorationImage(
                image: AssetImage('assets/images/Rectangle3.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/coins_3.png',
                  height: 70,
                ),
                const SizedBox(height: 2),
                Text(
                  '${plan.noOfCoins} Coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    '₹${plan.amount}',
                    style: const TextStyle(
                      color: Color(0xFF1565C0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// PACK BADGE — shown only when the backend tagged this plan with a
          /// packName (e.g. "value pack"). The label is the API value itself,
          /// not a hardcoded string.
          if (plan.hasPackName)
            Positioned(
              top: 4,
              left: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  plan.packName!.trim().capitalizeFirst ??
                      plan.packName!.trim(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
