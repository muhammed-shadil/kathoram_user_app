import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:kathoram_user_app/features/home/controller/home_controller.dart';
import 'package:kathoram_user_app/features/home/model/call_history_model.dart';
import 'package:kathoram_user_app/features/widgets/shimmer_loaders.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  late final HomeController homeController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    homeController = Get.find<HomeController>();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !homeController.isCallHistoryLoading.value &&
          homeController.callHistoryHasMorePages.value) {
        homeController.fetchCallHistory(loadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: SafeArea(
          child: Column(
            children: [
              // ── HEADER ──
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    'Call History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // ── LIST ──
              Expanded(
                child: Obx(() {
                  final history = homeController.callHistoryList;
                  final isLoading = homeController.isCallHistoryLoading.value;

                  if (isLoading && history.isEmpty) {
                    return const CallHistoryShimmer();
                  }

                  if (history.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => homeController.fetchCallHistory(),
                      child: ListView(
                        children: const [
                          SizedBox(height: 200),
                          Center(
                            child: Text(
                              'No call history',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => homeController.fetchCallHistory(),
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: history.length + (isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= history.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return _buildCallHistoryTile(history[index]);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallHistoryTile(CallHistoryModel call) {
    // Status icon and color
    Color statusColor;
    IconData statusIcon;

    if (call.isEnded) {
      statusColor = Colors.green;
      statusIcon = Icons.call_made;
    } else if (call.isMissed) {
      statusColor = Colors.red;
      statusIcon = Icons.call_missed;
    } else if (call.isCancelled) {
      statusColor = Colors.orange;
      statusIcon = Icons.call_end;
    } else {
      statusColor = Colors.blue;
      statusIcon = Icons.call;
    }

    final name = call.receiverDetails.name.isNotEmpty
        ? call.receiverDetails.name
        : "Unknown";
    final initial = name[0].toUpperCase();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          /// AVATAR
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              initial,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// NAME + DATE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.capitalizeFirst ?? "Unknown",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  call.formattedStartTime,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          /// STATUS + DURATION / COINS
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(statusIcon, size: 16, color: statusColor),
                  const SizedBox(width: 4),
                  Text(
                    call.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (call.isEnded) ...[
                Text(
                  call.formattedDuration,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/images/coin.png', height: 14),
                    const SizedBox(width: 3),
                    Text(
                      '${call.coinsUsed}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
              if (call.isMissed || call.isCancelled)
                Text(
                  call.disconnectReason.replaceAll('_', ' '),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
