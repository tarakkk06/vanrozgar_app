enum DecisionStatus {
  suggested,
  chosen,
  notChosen,
  deferred,
}

class GramSabhaDecision {
  final String villageId;
  final String villageName;
  DateTime meetingDate;
  int totalEligibleVoters;
  int attendeesCount;
  int femaleAttendeesCount;
  bool quorumReached; // Rule 4(2) requirement (at least 50% attendance with 1/3 women)
  Map<String, int> ideaVotes; // ideaId -> votes count
  Map<String, DecisionStatus> ideaDecisions; // ideaId -> status
  Map<String, String> assignedTeamLeaders; // ideaId -> Leader Name / SHG
  String resolutionNumber;
  String meetingMinutesNotes;
  String signedBySecretary;
  String signedBySarpanch;
  DateTime updatedAt;

  GramSabhaDecision({
    required this.villageId,
    required this.villageName,
    DateTime? meetingDate,
    this.totalEligibleVoters = 320,
    this.attendeesCount = 184,
    this.femaleAttendeesCount = 82,
    this.quorumReached = true,
    Map<String, int>? ideaVotes,
    Map<String, DecisionStatus>? ideaDecisions,
    Map<String, String>? assignedTeamLeaders,
    this.resolutionNumber = 'GS-RES-2026/04-A',
    this.meetingMinutesNotes =
        'Gram Sabha unanimously approved prioritizing Bamboo Processing and Fishery integration. SHG Mahila Mandal to lead initial procurement.',
    this.signedBySecretary = 'Shri Rajesh Meshram (FRC Secretary)',
    this.signedBySarpanch = 'Smt. Vandana Uikey (Sarpanch)',
    DateTime? updatedAt,
  })  : meetingDate = meetingDate ?? DateTime.now(),
        ideaVotes = ideaVotes ??
            {
              'idea_bamboo_processing': 142,
              'idea_fisheries': 128,
              'idea_goat_rearing': 98,
              'idea_honey_beekeeping': 85,
              'idea_medicinal_plants': 64,
            },
        ideaDecisions = ideaDecisions ??
            {
              'idea_bamboo_processing': DecisionStatus.chosen,
              'idea_fisheries': DecisionStatus.chosen,
              'idea_goat_rearing': DecisionStatus.suggested,
              'idea_honey_beekeeping': DecisionStatus.suggested,
              'idea_medicinal_plants': DecisionStatus.deferred,
            },
        assignedTeamLeaders = assignedTeamLeaders ??
            {
              'idea_bamboo_processing': 'Suresh Patil (Van Dhan Vikas Kendra)',
              'idea_fisheries': 'Anand Bhalavi (Matsya SHG)',
              'idea_goat_rearing': 'Lata Kumre (Pashu Sakhi)',
            },
        updatedAt = updatedAt ?? DateTime.now();

  bool evaluateQuorum() {
    bool isTotalQuorum = attendeesCount >= (totalEligibleVoters * 0.5);
    bool isWomenQuorum = femaleAttendeesCount >= (attendeesCount * 0.33);
    quorumReached = isTotalQuorum && isWomenQuorum;
    return quorumReached;
  }
}
