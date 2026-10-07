enum PriceTrend {
  rising,
  stable,
  falling,
}

class MarketPrice {
  final String id;
  final String commodityName;
  final String marathiCommodityName;
  final String mandiName; // e.g. Nagpur Cotton Market, Kalamna Mandi, Ramtek, Pune, Satara
  final double distanceKm;
  final double modalPricePerKg;
  final double minPricePerKg;
  final double maxPricePerKg;
  final PriceTrend trend;
  final String demandLevel; // High, Medium, Moderate
  final String source;
  final String date;
  final String unit; // 'kg', 'quintal', 'piece', 'liter'

  const MarketPrice({
    required this.id,
    required this.commodityName,
    required this.marathiCommodityName,
    required this.mandiName,
    required this.distanceKm,
    required this.modalPricePerKg,
    required this.minPricePerKg,
    required this.maxPricePerKg,
    required this.trend,
    required this.demandLevel,
    this.source = 'Agmarknet (data.gov.in)',
    required this.date,
    this.unit = 'kg',
  });

  String get trendIcon {
    switch (trend) {
      case PriceTrend.rising:
        return '▲ Rising';
      case PriceTrend.stable:
        return '■ Stable';
      case PriceTrend.falling:
        return '▼ Falling';
    }
  }
}
