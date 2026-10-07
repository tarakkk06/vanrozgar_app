enum CheckStatus {
  toBeVerified,
  confirmed,
  changed,
  rejected,
}

enum ConfidenceLevel {
  high, // Committee confirmed
  medium, // Official layer not yet checked on ground
  low, // Guessed from 7/12 or incomplete
}

class TrustLabel {
  final String source;
  final String sourceDate;
  final CheckStatus checkStatus;
  final ConfidenceLevel confidence;
  final String? verifiedBy;
  final String? verificationNote;

  const TrustLabel({
    required this.source,
    required this.sourceDate,
    this.checkStatus = CheckStatus.toBeVerified,
    this.confidence = ConfidenceLevel.medium,
    this.verifiedBy,
    this.verificationNote,
  });

  String get checkStatusDisplay {
    switch (checkStatus) {
      case CheckStatus.toBeVerified:
        return 'To be verified';
      case CheckStatus.confirmed:
        return 'Ground Confirmed';
      case CheckStatus.changed:
        return 'Updated on Ground';
      case CheckStatus.rejected:
        return 'Rejected';
    }
  }

  String get confidenceDisplay {
    switch (confidence) {
      case ConfidenceLevel.high:
        return 'High Confidence';
      case ConfidenceLevel.medium:
        return 'Medium Confidence';
      case ConfidenceLevel.low:
        return 'Low / Guessed';
    }
  }

  TrustLabel copyWith({
    String? source,
    String? sourceDate,
    CheckStatus? checkStatus,
    ConfidenceLevel? confidence,
    String? verifiedBy,
    String? verificationNote,
  }) {
    return TrustLabel(
      source: source ?? this.source,
      sourceDate: sourceDate ?? this.sourceDate,
      checkStatus: checkStatus ?? this.checkStatus,
      confidence: confidence ?? this.confidence,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verificationNote: verificationNote ?? this.verificationNote,
    );
  }
}
