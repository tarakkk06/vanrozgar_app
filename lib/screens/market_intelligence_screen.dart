import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/market_price.dart';
import '../providers/app_state_provider.dart';
import '../theme/app_theme.dart';

class MarketIntelligenceScreen extends StatelessWidget {
  const MarketIntelligenceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final prices = provider.marketPrices;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Market Intelligence (बाजारभाव माहिती)', style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Market Overview Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B4332), Color(0xFF2D765C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Agmarknet Daily Price Feed',
                        style: TextStyle(color: Colors.white, fontSize: 14.5, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Live Feed', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Nagpur, Ramtek, Kalamna & Pune wholesale mandi price indices for forest and allied commodities.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const Text(
              'Commodity Prices & Mandi Hubs',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            const SizedBox(height: 10),

            ...prices.map((p) => _buildPriceCard(p)),

            const SizedBox(height: 16),

            // Value Addition Margin Insight Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.trending_up, color: AppColors.usefulGreen, size: 20),
                      SizedBox(width: 8),
                      Text('Value Addition Profit Multipliers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildMultiplierRow('Raw Bamboo (₹15) → Treated Furniture Culm', '₹55 - ₹70/pc', '4.2x Multiplier'),
                  _buildMultiplierRow('Raw Mahua Flower (₹35) → Vacuum Packed Sanitized', '₹95/kg', '2.7x Multiplier'),
                  _buildMultiplierRow('Raw Honey in Comb (₹180) → Food-Grade Bottled Pure Honey', '₹480/kg', '2.6x Multiplier'),
                  _buildMultiplierRow('Raw Sal Leaves (₹10/bundle) → Hydraulic Pressed Dona & Plates', '₹45/100 pcs', '4.5x Multiplier'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(MarketPrice p) {
    Color trendColor = p.trend == PriceTrend.rising
        ? AppColors.usefulGreen
        : (p.trend == PriceTrend.stable ? AppColors.infoBlue : AppColors.notUsefulRed);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.commodityName,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
                    ),
                    Text(
                      p.marathiCommodityName,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: trendColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.trendIcon,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: trendColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Modal Price', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  Text(
                    '₹${p.modalPricePerKg.toStringAsFixed(0)} / ${p.unit}',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mandi Range', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  Text(
                    '₹${p.minPricePerKg.toStringAsFixed(0)} - ₹${p.maxPricePerKg.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Mandi Hub', style: TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
                  Text(
                    '${p.mandiName} (${p.distanceKm.round()} km)',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500, color: AppColors.textMain),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiplierRow(String step, String val, String mult) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(step, style: const TextStyle(fontSize: 12, color: AppColors.textMain)),
                Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.usefulGreenBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(mult, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.usefulGreen)),
          ),
        ],
      ),
    );
  }
}
