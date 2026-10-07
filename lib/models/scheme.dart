enum SchemeType {
  government,
  ngo,
}

class Scheme {
  final String id;
  final String title;
  final String marathiTitle;
  final SchemeType type;
  final String authorityOrNgo;
  final String description;
  final String subsidyOrSupport;
  final String eligibleBeneficiaries;
  final List<String> linkedIdeaIds;
  final String applicationProcess;
  final String contactPerson;
  final String lastCheckedDate;
  final String officialPortalUrl;

  const Scheme({
    required this.id,
    required this.title,
    required this.marathiTitle,
    required this.type,
    required this.authorityOrNgo,
    required this.description,
    required this.subsidyOrSupport,
    required this.eligibleBeneficiaries,
    required this.linkedIdeaIds,
    required this.applicationProcess,
    required this.contactPerson,
    required this.lastCheckedDate,
    required this.officialPortalUrl,
  });

  bool get isReviewRequired {
    // If last checked is older than 3 months
    return false;
  }
}
