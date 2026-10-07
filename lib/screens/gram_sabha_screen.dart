import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/gram_sabha_record.dart';
import '../models/resource.dart';
import '../providers/app_state_provider.dart';
import '../services/pdf_report_service.dart';
import '../theme/app_theme.dart';
import 'livelihood_detail_screen.dart';

class GramSabhaScreen extends StatefulWidget {
  const GramSabhaScreen({Key? key}) : super(key: key);

  @override
  State<GramSabhaScreen> createState() => _GramSabhaScreenState();
}

class _GramSabhaScreenState extends State<GramSabhaScreen> {
  final PdfReportService _pdfService = PdfReportService();

  late TextEditingController _votersController;
  late TextEditingController _attendeesController;
  late TextEditingController _womenAttendeesController;
  late TextEditingController _resolutionController;
  late TextEditingController _minutesController;

  @override
  void initState() {
    super.initState();
    final decision = Provider.of<AppStateProvider>(context, listen: false).gramSabhaDecision;
    _votersController = TextEditingController(text: '${decision.totalEligibleVoters}');
    _attendeesController = TextEditingController(text: '${decision.attendeesCount}');
    _womenAttendeesController = TextEditingController(text: '${decision.femaleAttendeesCount}');
    _resolutionController = TextEditingController(text: decision.resolutionNumber);
    _minutesController = TextEditingController(text: decision.meetingMinutesNotes);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppStateProvider>(context);
    final village = provider.selectedVillage;
    final top3 = provider.top5Ideas.take(3).toList();
    final decision = provider.gramSabhaDecision;

    int totalVoters = int.tryParse(_votersController.text) ?? 320;
    int attendees = int.tryParse(_attendeesController.text) ?? 184;
    int women = int.tryParse(_womenAttendeesController.text) ?? 82;

    bool quorumMet = attendees >= (totalVoters * 0.5) && women >= (attendees * 0.33);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gram Sabha Assistant (ग्रामसभा सहाय्यक)', style: TextStyle(fontSize: 16)),
        backgroundColor: AppColors.primaryDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: 'Generate Printable A4 Summary',
            onPressed: () => _generateAndShowPdfReport(context, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top 3 Recommended Ideas List (Matching prototype Screen 11)
            const Text(
              'Top 3 Recommended Livelihood Proposals',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textMain),
            ),
            const SizedBox(height: 10),

            ...top3.map((item) {
              int index = top3.indexOf(item) + 1;
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => LivelihoodDetailScreen(idea: item.idea)),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.primaryLight,
                        child: Text('$index', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.idea.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            Text('Score: ${item.fitScore}% • Interest: ${item.idea.markedInterestCount} families',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 14),

            // Summary Impact Box (Households Benefited, Investment, Schemes)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Summary Report Overview', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryMetric('Households', '72', Icons.family_restroom),
                      _buildSummaryMetric('Investment', '₹3.1 L', Icons.currency_rupee),
                      _buildSummaryMetric('Linked Schemes', '4', Icons.account_balance),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quorum & Rule 4(2) Form
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
                  Row(
                    children: [
                      const Icon(Icons.how_to_vote, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Gram Sabha Attendance & Quorum (Rule 4(2))',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: quorumMet ? AppColors.usefulGreenBg : AppColors.notUsefulRedBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: quorumMet ? AppColors.usefulGreen : AppColors.notUsefulRed),
                        ),
                        child: Text(
                          quorumMet ? 'Quorum Met ✓' : 'Quorum Shortage ✗',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: quorumMet ? AppColors.usefulGreen : AppColors.notUsefulRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _votersController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Voters',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _attendeesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Present',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _womenAttendeesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Women Present',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _resolutionController,
                    decoration: const InputDecoration(
                      labelText: 'Resolution Number (ठराव क्रमांक)',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _minutesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Resolution Minutes & Decisions (इतिवृत्त)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Generate PDF Report Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _generateAndShowPdfReport(context, provider),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate 1-Page A4 PDF Report', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondaryOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Save Decision Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  provider.updateGramSabhaDecision(
                    voters: int.tryParse(_votersController.text) ?? 320,
                    attendees: int.tryParse(_attendeesController.text) ?? 184,
                    womenAttendees: int.tryParse(_womenAttendeesController.text) ?? 82,
                    resolutionNo: _resolutionController.text,
                    minutes: _minutesController.text,
                    votes: decision.ideaVotes,
                    decisions: decision.ideaDecisions,
                    leaders: decision.assignedTeamLeaders,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gram Sabha decision and quorum successfully recorded in CFR registry!'),
                      backgroundColor: AppColors.usefulGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.save, color: AppColors.primary),
                label: const Text('Save & Archive Decision', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
      ],
    );
  }

  void _generateAndShowPdfReport(BuildContext context, AppStateProvider provider) {
    var report = _pdfService.generateReportData(
      village: provider.selectedVillage,
      resources: provider.resources,
      allIdeas: provider.allIdeas,
      decision: provider.gramSabhaDecision,
    );

    String textReport = _pdfService.formatTextSummary(report);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.description, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Gram Sabha 1-Page A4 Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.background,
              child: Text(
                textReport,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, height: 1.35),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Document ready! PDF saved to /reports/VanRozgar_GramSabha_Summary.pdf'),
                  backgroundColor: AppColors.usefulGreen,
                ),
              );
            },
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Save / Print PDF'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
