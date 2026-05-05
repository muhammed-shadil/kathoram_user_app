import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../features/authentication/controller/auth_controller.dart';
import '../../features/home/controller/home_controller.dart';
import '../../services/zego_call_service.dart';

class UserTile extends StatefulWidget {
  final int index;

  const UserTile({super.key, required this.index});

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile>
    with SingleTickerProviderStateMixin {
  final HomeController _homeController = Get.find<HomeController>();

  AnimationController? _animController;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkAndStartAnimation();
  }

  @override
  void didUpdateWidget(covariant UserTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When Flutter moves this widget to a new index (via ValueKey),
    // check if it should play the entrance animation at the top.
    if (oldWidget.index != widget.index) {
      _checkAndStartAnimation();
    }
  }

  /// If this tile is at position 0 and was just moved there, start the
  /// slide-in + fade-in entrance animation.
  void _checkAndStartAnimation() {
    if (widget.index != 0) return;
    if (widget.index >= _homeController.staffList.length) return;

    final staff = _homeController.staffList[widget.index];
    if (_homeController.recentlyMovedToTopId.value == staff.id) {
      _startEntranceAnimation();
      // Clear the flag after this frame so other tiles don't re-trigger.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_homeController.recentlyMovedToTopId.value == staff.id) {
          _homeController.recentlyMovedToTopId.value = null;
        }
      });
    }
  }

  void _startEntranceAnimation() {
    _animController?.dispose();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animController!,
      curve: Curves.easeIn,
    ));
    _animController!.forward().then((_) {
      // Clean up after animation completes to remove the wrapper widgets.
      if (mounted) {
        setState(() {
          _animController?.dispose();
          _animController = null;
          _slideAnimation = null;
          _fadeAnimation = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _animController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.index >= _homeController.staffList.length) {
        return const SizedBox.shrink();
      }
      final staff = _homeController.staffList[widget.index];

      Color statusColor;
      String statusText;
      IconData callIcon;

      if (staff.isOnline) {
        statusColor = Colors.green;
        statusText = "Online";
        callIcon = Icons.call;
      } else if (staff.isOnCall) {
        statusColor = Colors.orange;
        statusText = "On Call";
        callIcon = Icons.call;
      } else {
        statusColor = Colors.red;
        statusText = "Offline";
        callIcon = Icons.headset;
      }

      final name = staff.name.isNotEmpty ? staff.name : "User";
      final initial = name[0].toUpperCase();
      final isLoading = _homeController.isCallLoading.value;

      Widget tile = Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            /// IMAGE
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: staff.profileImage.isNotEmpty
                  ? Image.network(
                      staff.profileImage,
                      height: 70,
                      width: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildInitialAvatar(initial),
                    )
                  : _buildInitialAvatar(initial),
            ),

            const SizedBox(width: 10),

            /// TEXT SECTION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name.capitalizeFirst ?? "User",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  if (staff.language.isNotEmpty)
                    Text(
                      staff.language,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Text("${staff.age} yrs"),
                      const SizedBox(width: 10),
                      Image.asset(
                        "assets/images/coin.png",
                        height: 16,
                        width: 16,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildInitialAvatar(initial),
                      ),
                      const SizedBox(width: 4),
                      Text("${staff.coinsPerSec}/Sec"),
                    ],
                  ),
                ],
              ),
            ),

            /// RIGHT SIDE (STATUS + CALL BUTTON)
            Column(
              children: [
                /// STATUS
                Row(
                  children: [
                    Icon(Icons.circle, size: 10, color: statusColor),
                    const SizedBox(width: 5),
                    Text(
                      statusText,
                      style: TextStyle(fontSize: 12, color: statusColor),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                /// CALL BUTTON
                InkWell(
                  onTap: isLoading
                      ? null
                      : () {
                          if (!staff.isOnline) {
                            Fluttertoast.showToast(
                              msg:
                                  "This user is currently ${staff.isOnCall ? 'on another call' : 'offline'}",
                            );
                            return;
                          }

                          final authController = Get.find<AuthController>();
                          final currentUser = authController.userProfile.value;
                          if (currentUser == null) {
                            Fluttertoast.showToast(msg: "Please login first");
                            return;
                          }

                          // Insufficient-coins guard: user must have at least
                          // enough coins for one second of this staff's rate.
                          if (currentUser.userCoins < staff.coinsPerSec) {
                            Fluttertoast.showToast(
                              msg:
                                  "Insufficient coins to call this user. Please add coins.",
                            );
                            return;
                          }

                          ZegoCallService.instance.sendAudioCallToStaff(
                            staffUserID: staff.id,
                            staffUserName: staff.name,
                            callerName: currentUser.name,
                          );
                        },
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: isLoading ? Colors.grey : statusColor,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(callIcon, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

      // Wrap with entrance animation when the tile was just moved to the top.
      if (_animController != null &&
          _slideAnimation != null &&
          _fadeAnimation != null) {
        return SlideTransition(
          position: _slideAnimation!,
          child: FadeTransition(
            opacity: _fadeAnimation!,
            child: tile,
          ),
        );
      }

      return tile;
    });
  }

  Widget _buildInitialAvatar(String initial) {
    return Container(
      height: 70,
      width: 70,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
          ),
        ),
      ),
    );
  }
}
