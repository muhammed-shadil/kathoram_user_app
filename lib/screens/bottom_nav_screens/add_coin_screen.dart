import 'package:flutter/material.dart';
import 'package:kathoram_app/models/coins_model.dart';
import 'package:kathoram_app/screens/payment_screen.dart';

class AddCoinsScreen extends StatefulWidget {
  const AddCoinsScreen({super.key});

  @override
  State<AddCoinsScreen> createState() => _AddCoinsScreenState();
}

class _AddCoinsScreenState extends State<AddCoinsScreen> {
  bool _showSuccess = false; // controls overlay

  final int currentCoins = 100;

  final List<CoinPack> packs = const [
    CoinPack(coins: 100, price: 50),
    CoinPack(coins: 200, price: 90),
    CoinPack(coins: 500, price: 300, isValuePack: true, topLabel: "400 Coins"),
    CoinPack(
      coins: 1000,
      price: 500,
      topLabel: "800 Coins",
      isValuePack: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add Coins',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Row(
              children: [
                Image.asset('assets/images/coin.png', width: 26, height: 26),
                const SizedBox(width: 6),
                Text(
                  '$currentCoins',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: packs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final pack = packs[index];

                  return GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Purchasing ${pack.coins} coins for ₹${pack.price}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        // ── Blue rectangle image as card ──
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/Rectangle3.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // ── Stars + Coins image ──
                              SizedBox(
                                height: 80,
                                width: double.infinity,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Star top-left
                                    Positioned(
                                      top: 4,
                                      right: 28,
                                      child: Image.asset(
                                        'assets/images/star 1.png',
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                    // Star top-right
                                    Positioned(
                                      top: 2,
                                      right: 14,
                                      child: Image.asset(
                                        'assets/images/star 2.png',
                                        width: 13,
                                        height: 13,
                                      ),
                                    ),
                                    // 3 coins image
                                    Positioned(
                                      bottom: 0,
                                      child: Image.asset(
                                        'assets/images/coins_3.png',
                                        height: 65,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              if (pack.topLabel != null)
                                Text(
                                  pack.topLabel!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              const SizedBox(height: 8),

                              // ── Coin count ──
                              Text(
                                '${pack.coins} Coins',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // ── Price pill ──
                              GestureDetector(
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PaymentScreen(pack: pack),
                                    ),
                                  );

                                  // if PaymentScreen returned true, show overlay
                                  if (result == true) {
                                    setState(() => _showSuccess = true);
                                  }
                                },
                                //                           onTap: () => Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (_) => PaymentScreen(pack: pack),
                                //   ),
                                // ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '₹${pack.price}',
                                    style: const TextStyle(
                                      color: Color(0xFF1565C0),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Value Pack badge — top LEFT corner ──
                        if (pack.isValuePack)
                          Positioned(
                            top: 10,
                            left: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.shade600,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Value Pack',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                        // ── Top label — top RIGHT corner ──
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Coin Added overlay ──
          if (_showSuccess)
            GestureDetector(
              onTap: () => setState(() => _showSuccess = false),
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Stack(
                    alignment: Alignment.topCenter,
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 36),
                        child: Image.asset(
                          'assets/images/white_rect.png',
                          width: 260,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Positioned(
                       bottom:70,
                        child: Image.asset(
                          'assets/images/done.png',
                          width: 72,
                          height: 72,
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        child: const Text(
                          'Coin Added!',
                          style: TextStyle(
                            color: Color(0xFF1E88E5),
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
