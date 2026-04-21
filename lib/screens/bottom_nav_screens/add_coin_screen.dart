import 'package:flutter/material.dart';
import 'package:kathoram_app/models/coins_model.dart';
import 'package:kathoram_app/screens/payment_screen.dart';

class AddCoinsScreen extends StatefulWidget {
  const AddCoinsScreen({super.key});

  @override
  State<AddCoinsScreen> createState() => _AddCoinsScreenState();
}

class _AddCoinsScreenState extends State<AddCoinsScreen> {
  bool _showSuccess = false;
  final int currentCoins = 100;

  final List<CoinPack> packs = const [
    CoinPack(coins: 100, price: 50),
    CoinPack(coins: 200, price: 90),
    CoinPack(coins: 500, price: 300, isValuePack: true, topLabel: "400 Coins"),
    CoinPack(coins: 1000, price: 500, isValuePack: true, topLabel: "800 Coins"),
  ];

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
          onPressed: () => Navigator.pop(context),
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
            child: Row(
              children: [
                Image.asset('assets/images/coin.png', width: 24),
                const SizedBox(width: 5),
                Text(
                  '$currentCoins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      /// BODY
      body: Stack(
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: packs.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  // childAspectRatio: 2,
                ),
                itemBuilder: (context, index) {
                  final pack = packs[index];

                  return GestureDetector(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(pack: pack),
                        ),
                      );

                      if (result == true) {
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
                              if (pack.topLabel != null)
                                Text(
                                  pack.topLabel!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 8,
                                  ),
                                ),
                              const SizedBox(height: 2),
                              Text(
                                '${pack.coins} Coins',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  '₹${pack.price}',
                                  style: const TextStyle(
                                    color: Color(0xFF1565C0),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        /// VALUE PACK BADGE
                        if (pack.isValuePack)
                          Positioned(
                            top: 4,
                            left: 6,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Value Pack',
                                style: TextStyle(
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
                },
              ),
            ),
          ),

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
}
