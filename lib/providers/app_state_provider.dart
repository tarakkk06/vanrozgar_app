import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_user.dart';
import '../models/trust_label.dart';
import '../models/village.dart';
import '../models/resource.dart';
import '../models/livelihood_idea.dart';
import '../models/scheme.dart';
import '../models/market_price.dart';
import '../models/gram_sabha_record.dart';
import '../models/land_record_7_12.dart';
import '../models/chat_message.dart';
import '../services/mock_data_service.dart';
import '../services/livelihood_engine.dart';
import '../services/voice_ai_service.dart';
import '../services/auth_service.dart';
import '../services/geo_api_service.dart';
import '../services/mahabhumi_api_service.dart';
import '../services/realtime_data_service.dart';

class AppStateProvider with ChangeNotifier {
  final MockDataService _mockData = MockDataService();
  final LivelihoodEngine _engine = LivelihoodEngine();
  final VoiceAIService _voiceAI = VoiceAIService();
  final AuthService _auth = AuthService();
  final GeoApiService _geoApi = GeoApiService();
  final MahabhumiApiService _mahabhumi = MahabhumiApiService();
  final RealtimeDataService _realtimeData = RealtimeDataService();

  String _langCode = 'en'; // 'mr', 'hi', 'en'
  String _userRole = 'villager'; // 'villager', 'committee', 'admin'
  int _currentTabIndex = 0;
  AppUser? _currentUser;
  bool _sessionReady = false;
  bool _liveSyncing = false;
  String _liveStatus = 'Offline catalog';
  DateTime? _lastLiveSync;
  List<OsmMapFeature> _mapFeatures = [];
  LandRecord712? _latestLandRecord;
  StreamSubscription<List<Map<String, dynamic>>>? _resourceUpdates;

  late List<Village> _villages;
  late Village _selectedVillage;
  late List<ResourceItem> _resources;
  late List<LivelihoodIdea> _allIdeas;
  late List<Scheme> _schemes;
  late List<MarketPrice> _marketPrices;
  late GramSabhaDecision _gramSabhaDecision;
  final List<ChatMessage> _chatHistory = [];

  bool _isVoiceRecording = false;
  bool _isProcessingAI = false;

  AppStateProvider() {
    _initializeData();
    restoreSession();
  }

  @override
  void dispose() {
    unawaited(_resourceUpdates?.cancel());
    super.dispose();
  }

  void _initializeData() {
    _villages = _mockData.getVillages();
    _selectedVillage = _villages.first;
    _resources = _mockData.getResourcesForVillage(_selectedVillage);
    _allIdeas = _mockData.getAll22LivelihoodIdeas();
    _schemes = _mockData.getSchemes();
    _marketPrices = _mockData.getMarketPrices();
    _gramSabhaDecision =
        _mockData.getSampleGramSabhaDecision(_selectedVillage.id);

    _chatHistory.add(ChatMessage(
      id: 'msg_welcome',
      sender: MessageSender.assistant,
      text: _getWelcomeGreeting(),
      audioText: _getWelcomeGreeting(),
      actionableTips: [
        'विचारू शकता: "आमच्या गावात कोणता व्यवसाय करावा?"',
        'विचारा: "बांबू प्रक्रिया केंद्रासाठी काय लागेल?"',
        'विचारा: "तलावात मत्स्यपालनाचा नफा किती होईल?"'
      ],
    ));
  }

  String get langCode => _langCode;
  String get userRole => _currentUser?.role ?? _userRole;
  int get currentTabIndex => _currentTabIndex;
  bool get isCommittee =>
      _currentUser != null &&
      (_currentUser!.role == 'committee' || _currentUser!.role == 'admin');
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get firebaseConfigured => _auth.isConfigured;
  bool get landRecordsConfigured => _mahabhumi.isConfigured;
  bool get sessionReady => _sessionReady;
  bool get liveSyncing => _liveSyncing;
  String get liveStatus => _liveStatus;
  DateTime? get lastLiveSync => _lastLiveSync;
  List<OsmMapFeature> get mapFeatures => _mapFeatures;
  LandRecord712? get latestLandRecord => _latestLandRecord;
  String get displayName => _currentUser?.displayName ?? 'Guest';

  List<Village> get villages {
    final user = _currentUser;
    if (user == null) return _villages;
    return _villages
        .where((v) => user.canAccessVillage(v.id, v.district))
        .toList();
  }

  Village get selectedVillage => _selectedVillage;
  List<ResourceItem> get resources => _resources;
  List<LivelihoodIdea> get allIdeas => _allIdeas;
  List<Scheme> get schemes => _schemes;
  List<MarketPrice> get marketPrices => _marketPrices;
  GramSabhaDecision get gramSabhaDecision => _gramSabhaDecision;
  List<ChatMessage> get chatHistory => _chatHistory;
  bool get isVoiceRecording => _isVoiceRecording;
  bool get isProcessingAI => _isProcessingAI;
  LivelihoodEngine get engine => _engine;

  List<LivelihoodRankResult> get top5Ideas {
    return _engine.getTop5Ideas(
      allIdeas: _allIdeas,
      villageResources: _resources,
      profile: _selectedVillage.profile,
    );
  }

  List<LivelihoodRankResult> get gatedAndHeldBackIdeas {
    return _engine.getGatedAndHeldBackIdeas(
      allIdeas: _allIdeas,
      villageResources: _resources,
      profile: _selectedVillage.profile,
    );
  }

  Future<void> restoreSession() async {
    try {
      final user = await _auth.restoreSession();
      _currentUser = user;
      if (user != null) {
        _userRole = user.role;
        final accessible = villages;
        if (accessible.isNotEmpty &&
            !accessible.any((v) => v.id == _selectedVillage.id)) {
          selectVillage(accessible.first.id);
        }
      }
      _subscribeToResourceUpdates();
    } catch (error) {
      _liveStatus = 'Could not restore Firebase session: $error';
    } finally {
      _sessionReady = true;
      notifyListeners();
    }
  }

  Future<void> sendOtp(String phone) => _auth.sendOtp(phone);

  Future<void> verifyOtpAndLogin(String phone, String otp) async {
    final user = await _auth.verifyOtp(phone, otp);
    _currentUser = user;
    _userRole = user.role;
    final accessible = villages;
    if (accessible.isNotEmpty) {
      selectVillage(accessible.first.id);
    }
    _subscribeToResourceUpdates();
    notifyListeners();
  }

  Future<void> logout() async {
    await _resourceUpdates?.cancel();
    _resourceUpdates = null;
    await _auth.clearSession();
    _currentUser = null;
    _userRole = 'villager';
    notifyListeners();
  }

  void setLanguage(String code) {
    _langCode = code;
    notifyListeners();
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void selectVillage(String villageId) {
    final pool = villages.isNotEmpty ? villages : _villages;
    var found =
        pool.firstWhere((v) => v.id == villageId, orElse: () => pool.first);
    _selectedVillage = found;
    _resources = _mockData.getResourcesForVillage(found);
    _mapFeatures = [];
    _latestLandRecord = null;
    _gramSabhaDecision = _mockData.getSampleGramSabhaDecision(found.id);
    notifyListeners();
    _subscribeToResourceUpdates();
    refreshLiveVillageData();
  }

  Future<void> refreshLiveVillageData() async {
    _liveSyncing = true;
    _liveStatus = 'Refreshing map data…';
    notifyListeners();
    try {
      final place = await _geoApi.geocodeVillage(_selectedVillage);
      if (place != null) {
        _selectedVillage = Village(
          id: _selectedVillage.id,
          name: _selectedVillage.name,
          marathiName: _selectedVillage.marathiName,
          hindiName: _selectedVillage.hindiName,
          taluka: _selectedVillage.taluka,
          district: _selectedVillage.district,
          cfrAreaHectares: _selectedVillage.cfrAreaHectares,
          approvalDate: _selectedVillage.approvalDate,
          recognitionStatus: _selectedVillage.recognitionStatus,
          householdCount: _selectedVillage.householdCount,
          totalPopulation: _selectedVillage.totalPopulation,
          latitude: place.latitude,
          longitude: place.longitude,
          surveyNumbers: _selectedVillage.surveyNumbers,
          waterScore: _selectedVillage.waterScore,
          landScore: _selectedVillage.landScore,
          forestScore: _selectedVillage.forestScore,
          skillsScore: _selectedVillage.skillsScore,
          marketScore: _selectedVillage.marketScore,
          infrastructureScore: _selectedVillage.infrastructureScore,
          sustainabilityScore: _selectedVillage.sustainabilityScore,
          trustLabel: _selectedVillage.trustLabel,
          profile: _selectedVillage.profile,
        );
        _resources = _mockData.getResourcesForVillage(_selectedVillage);
      }
      _mapFeatures = await _geoApi.fetchNearbyMapFeatures(
        _selectedVillage.latitude,
        _selectedVillage.longitude,
      );
      final survey = _selectedVillage.surveyNumbers.isNotEmpty
          ? _selectedVillage.surveyNumbers.first
          : 'CFR-1';
      _latestLandRecord = await _mahabhumi.fetch712Record(
        district: _selectedVillage.district,
        taluka: _selectedVillage.taluka,
        village: _selectedVillage.name,
        surveyNumber: survey,
      );
      _lastLiveSync = DateTime.now();
      _liveStatus = _latestLandRecord == null
          ? 'Map refreshed${place == null ? '' : ' (${place.source})'}; '
              '7/12 unavailable — authorized API not configured'
          : 'Map and 7/12 data refreshed';
    } catch (error) {
      _latestLandRecord = null;
      _liveStatus = 'Live data refresh failed: $error';
    } finally {
      _liveSyncing = false;
      notifyListeners();
    }
  }

  Future<LandRecord712?> fetch712ForSurvey(String surveyNumber) async {
    final record = await _mahabhumi.fetch712Record(
      district: _selectedVillage.district,
      taluka: _selectedVillage.taluka,
      village: _selectedVillage.name,
      surveyNumber: surveyNumber,
    );
    _latestLandRecord = record;
    notifyListeners();
    return record;
  }

  void _subscribeToResourceUpdates() {
    unawaited(_resourceUpdates?.cancel());
    _resourceUpdates = null;
    if (!_auth.isConfigured || _currentUser == null) return;

    _resourceUpdates =
        _realtimeData.watchResourceVerifications(_selectedVillage.id).listen(
      _applyResourceUpdates,
      onError: (Object error) {
        _liveStatus = 'Realtime resource sync failed: $error';
        notifyListeners();
      },
    );
  }

  void _applyResourceUpdates(List<Map<String, dynamic>> updates) {
    for (final update in updates) {
      final resourceId = update['id'] as String?;
      final index =
          _resources.indexWhere((resource) => resource.id == resourceId);
      if (index < 0) continue;
      final resource = _resources[index];
      final statusName = update['status'] as String?;
      final status = CheckStatus.values.firstWhere(
        (value) => value.name == statusName,
        orElse: () => resource.trustLabel.checkStatus,
      );
      resource.updateFieldCheck(
        newA: (update['availabilityA'] as num?)?.toDouble() ??
            resource.availabilityA,
        newC: (update['conditionC'] as num?)?.toDouble() ?? resource.conditionC,
        newS: (update['seasonalityS'] as num?)?.toDouble() ??
            resource.seasonalityS,
        newR: (update['reachR'] as num?)?.toDouble() ?? resource.reachR,
        newReason: update['reason'] as String? ?? resource.plainReason,
        verifiedBy: update['verifiedBy'] as String? ?? '',
        verificationNote: update['verificationNote'] as String? ?? '',
        status: status,
      );
    }
    _liveStatus = 'Resource verification updates are synced in realtime';
    notifyListeners();
  }

  void verifyResourceGroundCheck({
    required String resourceId,
    required double newA,
    required double newC,
    required double newS,
    required double newR,
    required String reason,
    required String verifiedBy,
    required String note,
    required CheckStatus status,
  }) {
    int index = _resources.indexWhere((r) => r.id == resourceId);
    if (index != -1) {
      _resources[index].updateFieldCheck(
        newA: newA,
        newC: newC,
        newS: newS,
        newR: newR,
        newReason: reason,
        verifiedBy: verifiedBy,
        verificationNote: note,
        status: status,
      );
      notifyListeners();
      if (_auth.isConfigured && _currentUser != null) {
        unawaited(_persistResourceVerification(
          resourceId: resourceId,
          availability: newA,
          condition: newC,
          seasonality: newS,
          reach: newR,
          reason: reason,
          verifiedBy: verifiedBy,
          note: note,
          status: status,
        ));
      }
    }
  }

  Future<void> _persistResourceVerification({
    required String resourceId,
    required double availability,
    required double condition,
    required double seasonality,
    required double reach,
    required String reason,
    required String verifiedBy,
    required String note,
    required CheckStatus status,
  }) async {
    try {
      await _realtimeData.saveResourceVerification(
        villageId: _selectedVillage.id,
        resourceId: resourceId,
        availability: availability,
        condition: condition,
        seasonality: seasonality,
        reach: reach,
        reason: reason,
        verifiedBy: verifiedBy,
        note: note,
        status: status.name,
      );
      _liveStatus = 'Verification saved to shared realtime data';
    } catch (error) {
      _liveStatus = 'Could not sync verification: $error';
    }
    notifyListeners();
  }

  void markIdeaInterest(String ideaId) {
    int index = _allIdeas.indexWhere((i) => i.id == ideaId);
    if (index != -1) {
      _allIdeas[index].markedInterestCount++;
      notifyListeners();
    }
  }

  void updateGramSabhaDecision({
    required int voters,
    required int attendees,
    required int womenAttendees,
    required String resolutionNo,
    required String minutes,
    required Map<String, int> votes,
    required Map<String, DecisionStatus> decisions,
    required Map<String, String> leaders,
  }) {
    _gramSabhaDecision.totalEligibleVoters = voters;
    _gramSabhaDecision.attendeesCount = attendees;
    _gramSabhaDecision.femaleAttendeesCount = womenAttendees;
    _gramSabhaDecision.resolutionNumber = resolutionNo;
    _gramSabhaDecision.meetingMinutesNotes = minutes;
    _gramSabhaDecision.ideaVotes = votes;
    _gramSabhaDecision.ideaDecisions = decisions;
    _gramSabhaDecision.assignedTeamLeaders = leaders;
    _gramSabhaDecision.evaluateQuorum();
    _gramSabhaDecision.updatedAt = DateTime.now();
    notifyListeners();
  }

  void updateVillageProfile(VillageProfile newProfile) {
    _selectedVillage = Village(
      id: _selectedVillage.id,
      name: _selectedVillage.name,
      marathiName: _selectedVillage.marathiName,
      hindiName: _selectedVillage.hindiName,
      taluka: _selectedVillage.taluka,
      district: _selectedVillage.district,
      cfrAreaHectares: _selectedVillage.cfrAreaHectares,
      approvalDate: _selectedVillage.approvalDate,
      recognitionStatus: _selectedVillage.recognitionStatus,
      householdCount: _selectedVillage.householdCount,
      totalPopulation: _selectedVillage.totalPopulation,
      latitude: _selectedVillage.latitude,
      longitude: _selectedVillage.longitude,
      surveyNumbers: _selectedVillage.surveyNumbers,
      waterScore: _selectedVillage.waterScore,
      landScore: _selectedVillage.landScore,
      forestScore: _selectedVillage.forestScore,
      skillsScore: (newProfile.skillsScore * 100).round(),
      marketScore: (newProfile.marketAccessScore * 100).round(),
      infrastructureScore: _selectedVillage.infrastructureScore,
      sustainabilityScore: _selectedVillage.sustainabilityScore,
      trustLabel: _selectedVillage.trustLabel,
      profile: newProfile,
    );
    notifyListeners();
  }

  Future<void> sendChatMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.user,
      text: text,
    );
    _chatHistory.add(userMsg);
    _isProcessingAI = true;
    notifyListeners();

    // AI Processing with Number Rule verification
    await Future.delayed(const Duration(milliseconds: 600));
    final aiResponse = await _voiceAI.processQuery(
      prompt: text,
      currentVillage: _selectedVillage,
      langCode: _langCode,
    );

    _chatHistory.add(aiResponse);
    _isProcessingAI = false;
    notifyListeners();
  }

  void toggleVoiceRecording() {
    _isVoiceRecording = !_isVoiceRecording;
    notifyListeners();
  }

  void toggleAudioPlayback(String messageId) {
    for (int i = 0; i < _chatHistory.length; i++) {
      if (_chatHistory[i].id == messageId) {
        _chatHistory[i] = _chatHistory[i].copyWith(
          isAudioPlaying: !_chatHistory[i].isAudioPlaying,
        );
      } else {
        _chatHistory[i] = _chatHistory[i].copyWith(isAudioPlaying: false);
      }
    }
    notifyListeners();
  }

  String _getWelcomeGreeting() {
    if (_langCode == 'mr') {
      return 'नमस्कार! मी वनरोजगार व्हॉईस एआय सहाय्यक आहे. आपल्या गावातील वन हक्क, उपलब्ध संसाधने, बाजारभाव किंवा रोजगाराच्या संधींविषयी प्रश्न विचारा.';
    } else if (_langCode == 'hi') {
      return 'नमस्ते! मैं वनरोजगार AI सहायक हूँ। अपने गाँव के वन अधिकार, जल व वन संसाधन या आजीविका संबंधी कोई भी प्रश्न पूछें।';
    }
    return 'Hello! I am your VanRozgar AI Livelihood Assistant. Ask me anything about forest resources, market prices, or livelihood planning.';
  }

  String t(String key) {
    const Map<String, Map<String, String>> translations = {
      'app_title': {
        'en': 'VanRozgar 2.0',
        'mr': 'वनरोजगार २.०',
        'hi': 'वनरोजगार २.०'
      },
      'subtitle': {
        'en': 'AI-Powered Village Livelihood Intelligence Platform',
        'mr': 'वन हक्कांतून शाश्वत आजीविका निर्मिती प्लॅटफॉर्म',
        'hi': 'वन अधिकारों से सतत आजीविका निर्माण'
      },
      'tagline_rule': {
        'en': 'The app suggests, people check, the Gram Sabha decides.',
        'mr': 'ॲप सुचवते, लोक तपासतात, ग्रामसभा ठरवते.',
        'hi': 'ऐप सुझाव देता है, लोग जांचते हैं, ग्राम सभा तय करती है।'
      },
      'nav_home': {'en': 'Home', 'mr': 'मुख्य', 'hi': 'होम'},
      'nav_map': {'en': 'GIS Map', 'mr': 'नकाशा', 'hi': 'मानचित्र'},
      'nav_ideas': {'en': 'Ideas', 'mr': 'रोजगार योजना', 'hi': 'योजनाएं'},
      'nav_simulator': {
        'en': 'Simulator',
        'mr': 'सिम्युलेटर',
        'hi': 'सिम्युलेटर'
      },
      'nav_voice': {'en': 'Voice AI', 'mr': 'व्हॉईस AI', 'hi': 'वॉइस AI'},
      'nav_schemes': {
        'en': 'Schemes',
        'mr': 'शासकीय योजना',
        'hi': 'सरकारी योजना'
      },
      'nav_gram_sabha': {
        'en': 'Gram Sabha',
        'mr': 'ग्रामसभा',
        'hi': 'ग्राम सभा'
      },
    };

    return translations[key]?[_langCode] ?? key;
  }
}
