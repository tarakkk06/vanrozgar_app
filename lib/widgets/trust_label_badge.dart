import 'package:flutter/material.dart';
import '../models/trust_label.dart';
import '../theme/app_theme.dart';

class TrustLabelBadge extends StatelessWidget {
  final TrustLabel trustLabel;
  final bool isCompact;

  const TrustLabelBadge({
    Key? key,
    required this.trustLabel,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color statusBg;
    IconData statusIcon;

    switch (trustLabel.checkStatus) {
      case CheckStatus.confirmed:
        statusColor = AppColors.usefulGreen;
        statusBg = AppColors.usefulGreenBg;
        statusIcon = Icons.verified;
        break;
      case CheckStatus.changed:
        statusColor = AppColors.infoBlue;
        statusBg = AppColors.infoBlueBg;
        statusIcon = Icons.edit_location_alt;
        break;
      case CheckStatus.rejected:
        statusColor = AppColors.notUsefulRed;
        statusBg = AppColors.notUsefulRedBg;
        statusIcon = Icons.cancel;
        break;
      case CheckStatus.toBeVerified:
        statusColor = AppColors.partlyUsefulYellow;
        statusBg = AppColors.partlyUsefulYellowBg;
        statusIcon = Icons.pending_actions;
        break;
    }

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusBg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withOpacity(0.4), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 13, color: statusColor),
            const SizedBox(width: 4),
            Text(
              trustLabel.checkStatusDisplay,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 13, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      trustLabel.checkStatusDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  trustLabel.confidenceDisplay,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Source: ${trustLabel.source} (${trustLabel.sourceDate})',
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
          if (trustLabel.verifiedBy != null) ...[
            const SizedBox(height: 2),
            Text(
              'Verified By: ${trustLabel.verifiedBy}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
