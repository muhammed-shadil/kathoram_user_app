class CoinPack {
  final int coins;
  final int price;
  final bool isValuePack;
  final String? topLabel; // e.g. "400 Coins"

  const CoinPack({
    required this.coins,
    required this.price,
    this.isValuePack = false,
    this.topLabel,
  });
}