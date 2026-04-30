import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// REUSABLE SHIMMER BUILDING BLOCKS
// ═══════════════════════════════════════════════════════════════════════════════

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class ShimmerCircle extends StatelessWidget {
  final double size;

  const ShimmerCircle({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

Widget _shimmerWrap({required Widget child}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: child,
  );
}

// ═══════════════════════════════════════════════════════════════════════════════
// STAFF LIST SHIMMER (Home Screen)
// ═══════════════════════════════════════════════════════════════════════════════

class StaffListShimmer extends StatelessWidget {
  final int itemCount;
  const StaffListShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 12),
      itemCount: itemCount,
      itemBuilder: (_, __) => _shimmerWrap(child: _staffTileShimmer()),
    );
  }

  Widget _staffTileShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const ShimmerBox(width: 70, height: 70, radius: 12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 120, height: 14),
                SizedBox(height: 8),
                ShimmerBox(width: 80, height: 12),
                SizedBox(height: 8),
                ShimmerBox(width: 100, height: 12),
              ],
            ),
          ),
          Column(
            children: const [
              ShimmerBox(width: 60, height: 12),
              SizedBox(height: 10),
              ShimmerCircle(size: 44),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// CALL HISTORY SHIMMER
// ═══════════════════════════════════════════════════════════════════════════════

class CallHistoryShimmer extends StatelessWidget {
  final int itemCount;
  const CallHistoryShimmer({super.key, this.itemCount = 8});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => _shimmerWrap(child: _historyTileShimmer()),
    );
  }

  Widget _historyTileShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const ShimmerCircle(size: 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerBox(width: 110, height: 14),
                SizedBox(height: 6),
                ShimmerBox(width: 80, height: 11),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              ShimmerBox(width: 60, height: 12),
              SizedBox(height: 6),
              ShimmerBox(width: 40, height: 11),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PLANS / COINS GRID SHIMMER
// ═══════════════════════════════════════════════════════════════════════════════

class PlansGridShimmer extends StatelessWidget {
  final int itemCount;
  const PlansGridShimmer({super.key, this.itemCount = 6});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
      ),
      itemBuilder: (_, __) => _shimmerWrap(child: _planCardShimmer()),
    );
  }

  Widget _planCardShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          ShimmerCircle(size: 60),
          SizedBox(height: 10),
          ShimmerBox(width: 80, height: 14),
          SizedBox(height: 8),
          ShimmerBox(width: 60, height: 24, radius: 25),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// PROFILE SHIMMER
// ═══════════════════════════════════════════════════════════════════════════════

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return _shimmerWrap(
      child: Column(
        children: [
          const SizedBox(height: 60),
          const ShimmerBox(width: 80, height: 18),
          const SizedBox(height: 55),
          const ShimmerCircle(size: 90),
          const SizedBox(height: 10),
          const ShimmerBox(width: 120, height: 16),
          const SizedBox(height: 6),
          const ShimmerBox(width: 100, height: 12),
          const SizedBox(height: 20),
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: ShimmerBox(
                width: double.infinity,
                height: 48,
                radius: 30,
              ),
            ),
          ),
          const SizedBox(height: 10),
          ...List.generate(
            2,
            (_) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: ShimmerBox(
                width: double.infinity,
                height: 48,
                radius: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
