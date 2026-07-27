import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kathoram_user_app/features/home/controller/home_controller.dart';
import 'package:kathoram_user_app/features/screens/bottom_nav_bar.dart';
import 'package:kathoram_user_app/features/widgets/user_tile.dart';
import 'package:kathoram_user_app/features/widgets/shimmer_loaders.dart';
import 'package:kathoram_user_app/features/authentication/controller/auth_controller.dart';
import 'package:kathoram_user_app/utils/support_helper.dart';

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  late final HomeController homeController;
  final ScrollController _scrollController = ScrollController();
  Worker? _moveWorker;

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !homeController.isStaffLoading.value &&
          homeController.staffHasMorePages.value) {
        homeController.fetchStaffList(loadMore: true);
      }
    });

    // Auto-scroll to top when a staff member moves there via socket event
    _moveWorker = ever(homeController.recentlyMovedToTopId, (staffId) {
      if (staffId != null &&
          _scrollController.hasClients &&
          _scrollController.offset < 200) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _moveWorker?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Pull-to-refresh: re-pull the staff list AND the user profile, so the coin
  /// balance in the header updates too (it lives on AuthController, which
  /// fetchStaffList never touches).
  Future<void> _refresh() async {
    await Future.wait([
      homeController.fetchStaffList(),
      Get.find<AuthController>().checkIsLogin(),
    ]);
  }

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        floatingActionButton: const SupportFab(),
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFFF2F2F2),
        body: Column(
          children: [
            /// BLUE HEADER
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.23,
              width: double.infinity,
              child: Stack(
                children: [
                  /// BLUE BACKGROUND WITH CURVE
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xff1976D2),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                  ),

                  /// APP NAME
                  Positioned(
                    top: 80,
                    left: 20,
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/kathoram.png",
                          width: 40,
                          height: 40,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          "Kathoram",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  /// COINS
                  Positioned(
                    top: 60,
                    right: 20,
                    child: Obx(() {
                      final authController = Get.find<AuthController>();
                      final coins =
                          authController.userProfile.value?.userCoins ?? 0;
                      return Row(
                        children: [
                          Image.asset("assets/images/coin.png", width: 26),
                          const SizedBox(width: 2),
                          Text(
                            "$coins",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                          ),
                        ],
                      );
                    }),
                  ),

                  /// ADD COINS BUTTON
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.to(
                          () => const BottomNavBar(initialIndex: 2),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.blue),
                      label: const Text(
                        "Add Coins",
                        style: TextStyle(color: Colors.blue),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// STAFF LIST
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Obx(() {
                  final staff = homeController.staffList;
                  final isLoading = homeController.isStaffLoading.value;

                  if (isLoading && staff.isEmpty) {
                    return const StaffListShimmer();
                  }

                  if (staff.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView(
                        // Short placeholder content isn't overscrollable under
                        // the default physics, which swallows the pull gesture.
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Text(
                              'No users available',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _refresh,
                    child: ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 12),
                      itemCount: staff.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= staff.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final member = staff[index];
                        return UserTile(
                          key: ValueKey(member.id),
                          index: index,
                        );
                      },
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
