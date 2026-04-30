import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import '../../features/authentication/controller/auth_controller.dart';
import '../../features/home/controller/home_controller.dart';
import '../../services/zego_call_service.dart';

class UserTile extends StatelessWidget {
  final int index;

  const UserTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Obx(() {
      if (index >= homeController.staffList.length) {
        return const SizedBox.shrink();
      }
      final staff = homeController.staffList[index];

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
      final isLoading = homeController.isCallLoading.value;

      return Container(
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
