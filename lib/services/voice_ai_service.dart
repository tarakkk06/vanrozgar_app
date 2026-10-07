import '../models/chat_message.dart';
import '../models/village.dart';
import '../models/market_price.dart';
import 'mock_data_service.dart';

class VoiceAIService {
  final MockDataService _mockData = MockDataService();

  Future<ChatMessage> processQuery({
    required String prompt,
    required Village currentVillage,
    required String langCode, // 'mr', 'hi', 'en'
  }) async {
    String lower = prompt.toLowerCase();

    // Check for out-of-scope topics first (legal dispute, hunting, chemical pesticides, illegal medicines)
    if (lower.contains('hunting') ||
        lower.contains('शिकार') ||
        lower.contains('trapping') ||
        lower.contains('pesticide') ||
        lower.contains('औषध मात्रा') ||
        lower.contains('lease forest') ||
        lower.contains('जमीन विक्री')) {
      return _buildOutOfScopeResponse(langCode);
    }

    // Bamboo query
    if (lower.contains('bamboo') || lower.contains('बांबू') || lower.contains('बांस')) {
      return _buildBambooResponse(langCode, currentVillage);
    }

    // Fisheries / Pond query
    if (lower.contains('fish') ||
        lower.contains('तलाव') ||
        lower.contains('मत्स्य') ||
        lower.contains('मछली')) {
      return _buildFisheriesResponse(langCode, currentVillage);
    }

    // Goat / Dairy query
    if (lower.contains('goat') ||
        lower.contains('शेळी') ||
        lower.contains('बकरी') ||
        lower.contains('dairy') ||
        lower.contains('दूध')) {
      return _buildLivestockResponse(langCode, currentVillage);
    }

    // General livelihood recommendation ("आमच्या गावात कोणता व्यवसाय करावा?")
    if (lower.contains('व्यवसाय') ||
        lower.contains('कोणता') ||
        lower.contains('व्यवसाय करावा') ||
        lower.contains('recommend') ||
        lower.contains('best') ||
        lower.contains('कमाई') ||
        lower.contains('रोजगार')) {
      return _buildTopRecommendationResponse(langCode, currentVillage);
    }

    // Weather / Crop query
    if (lower.contains('weather') ||
        lower.contains('हवामान') ||
        lower.contains('पाऊस') ||
        lower.contains('पीक') ||
        lower.contains('crop')) {
      return _buildCropWeatherResponse(langCode, currentVillage);
    }

    // Default Fallback adhering to Number Rule: "No reliable number"
    return _buildFallbackResponse(langCode);
  }

  ChatMessage _buildTopRecommendationResponse(String langCode, Village village) {
    if (langCode == 'mr') {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.assistant,
        text:
            '${village.marathiName} गावासाठी उपलब्ध नैसर्गिक संसाधने आणि बाजारभावानुसार ३ प्रमुख व्यवसाय उत्तम आहेत:\n\n'
            '१. बांबू मूल्यवर्धन व हस्तकला (अंदाजे उत्पन्न: ₹६.५ ते ₹८.२ लाख / वर्ष)\n'
            '२. गाव तलावात मत्स्यपालन (अंदाजे उत्पन्न: ₹३.१ ते ₹५.४ लाख / वर्ष)\n'
            '३. शेळीपालन गट व चारा बँक (अंदाजे उत्पन्न: ₹३.२ ते ₹४.८ लाख / वर्ष)',
        audioText:
            'तुमच्या गावातील नैसर्गिक संसाधने आणि पाण्याच्या उपलब्धतेचा विचार करता बांबू प्रक्रिया, मत्स्यपालन आणि शेळीपालन हे ३ उत्तम पर्याय आहेत.',
        hasNumber: true,
        numberRulePassed: true,
        sourceCitation: 'नागपूर CFR कृती आराखडा व ॲगमार्कनेट बाजारभाव',
        sourceDate: 'ऑक्टोबर २०२६ (Estimate)',
        calculatedFormula: 'वार्षिक नफा = (अपेक्षित उत्पादन × सरासरी बाजारभाव) - उत्पादन खर्च',
        actionableTips: [
          'ग्रामसभेत ठराव मंजूर करून वन धन विकास योजनेचा १५ लाखांचा १००% अनुदान निधी मिळवा.',
          'सिमेंट बंधाऱ्याचे गाळ काढण्याचे काम तात्काळ मनरेगा अंतर्गत मंजूर करून घ्या.',
          'बांबूवर बोरिक-बोराक्स प्रक्रिया केल्यास बाजारात ४ पट जादा दर मिळतो.'
        ],
      );
    } else if (langCode == 'hi') {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.assistant,
        text:
            '${village.hindiName} गाँव के लिए संसाधनों के आधार पर शीर्ष ३ आजीविका सुझाव:\n\n'
            '१. बांस मूल्यवर्धन एवं फर्नीचर (अनुमानित आय: ₹६.५ - ₹८.२ लाख / वर्ष)\n'
            '२. सामुदायिक तालाब में मत्स्य पालन (अनुमानित आय: ₹३.१ - ₹५.४ लाख / वर्ष)\n'
            '३. बकरी पालन एवं साइलेज चारा बैंक (अनुमानित आय: ₹३.२ - ₹४.८ लाख / वर्ष)',
        audioText:
            'गाँव के संसाधनों के आधार पर बांस प्रसंस्करण, मत्स्य पालन और बकरी पालन सबसे लाभकारी विकल्प हैं।',
        hasNumber: true,
        numberRulePassed: true,
        sourceCitation: 'CFR रिसोर्स डेटा एवं एगमार्कनेट मंडी भाव',
        sourceDate: 'अक्टूबर २०२६ (Estimate)',
        calculatedFormula: 'वार्षिक आय = (उत्पादन × मंडी मूल्य) - लागत',
        actionableTips: [
          'वन धन विकास योजना से ₹१५ लाख की ग्रांट के लिए ग्राम सभा प्रस्ताव तैयार करें।',
          'तालाब की गाद निकालने का कार्य मनरेगा से स्वीकृत कराएं।',
          'बांस पर बोरॉन ट्रीटमेंट से उत्पाद मूल्य ४ गुना बढ़ जाता है।'
        ],
      );
    } else {
      return ChatMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        sender: MessageSender.assistant,
        text:
            'Based on ${village.name}\'s CFR resource inventory, the Top 3 recommended livelihood enterprises are:\n\n'
            '1. Bamboo Craft & Product Processing (Estimated: ₹6.5L - ₹8.2L / yr)\n'
            '2. Pond Fishery Integration (Estimated: ₹3.1L - ₹5.4L / yr)\n'
            '3. Goat Rearing & Fodder Bank (Estimated: ₹3.2L - ₹4.8L / yr)',
        audioText:
            'Considering water availability and forest resources, Bamboo processing, fish farming, and goat rearing are your top opportunities.',
        hasNumber: true,
        numberRulePassed: true,
        sourceCitation: 'Nagpur CFR Inventory & Agmarknet Mandi Feed',
        sourceDate: 'Oct 2026 (Estimate)',
        calculatedFormula: 'Net Revenue = (Expected Yield × Modal Price) - Operating Cost',
        actionableTips: [
          'Apply for ₹15 Lakh 100% grant under TRIFED Van Dhan Vikas Yojana.',
          'Include check dam desilting in Gram Sabha MGNREGA labor budget.',
          'Treated bamboo commands 4x value over raw culms in Nagpur furniture hub.'
        ],
      );
    }
  }

  ChatMessage _buildBambooResponse(String langCode, Village village) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: langCode == 'mr'
          ? 'तळवडे गावाच्या ८५ हेक्टर बांबू पट्ट्यातून दरवर्षी सुमारे ४५,००० बांबूंचे शाश्वत संकलन शक्य आहे. बोरिक-बोराक्स प्रक्रिया केल्यास प्रति बांबू दर ₹१५ वरून ₹५५ ते ₹७० पर्यंत वाढतो. नागपूर व पुणे बाजारपेठेत फर्निचर व पडद्यांची मागणी उच्च आहे.'
          : 'Village bamboo stand (85 ha) has annual yield of ~45,000 culms. With Boron chemical treatment, value per culm increases from ₹15 to ₹55 - ₹70 in Nagpur and Pune craft markets.',
      hasNumber: true,
      numberRulePassed: true,
      sourceCitation: 'National Bamboo Mission & Nagpur Timber Mandi',
      sourceDate: 'Oct 2026 (Estimate)',
      calculatedFormula: 'Value Multiplier = 4.2x with Boron Dip Process',
      actionableTips: [
        'Establish 3-year rotational harvest to preserve bamboo clump root health.',
        'Apply for National Bamboo Mission machinery grant (50% subsidy).'
      ],
    );
  }

  ChatMessage _buildFisheriesResponse(String langCode, Village village) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: langCode == 'mr'
          ? 'गाव तलावात (२.४ हेक्टर) ५,००० रोहू, कटला व मृगळ मत्स्यबीज सोडल्यास ७ ते ८ महिन्यांत सुमारे २,५०० किलो उत्पादन मिळू शकते. रामटेक व नागपूर बाजारात ताजी मासे ₹१६० ते ₹२१०/किलो दराने विकली जातात. अंदाजे नफा: ₹३.१ लाख ते ₹४.५ लाख.'
          : 'Stocking 5,000 advanced fingerlings in the 2.4 ha perennial pond can yield approx 2,500 kg table fish in 8 months. Nagpur market wholesale price is ₹160 - ₹210/kg. Estimated Net Profit: ₹3.1L - ₹4.5L.',
      hasNumber: true,
      numberRulePassed: true,
      sourceCitation: 'Department of Fisheries & PMMSY Cluster Guide',
      sourceDate: 'Feb 2026 (Estimate)',
      calculatedFormula: 'Profit = (2,500 kg × ₹185/kg) - ₹1.5L (Feed & Seed cost)',
      actionableTips: [
        'Desilt inlet before monsoon to ensure minimum 1.8m water column.',
        'Avail 60% PMMSY input subsidy through Gram Sabha Matsya SHG.'
      ],
    );
  }

  ChatMessage _buildLivestockResponse(String langCode, Village village) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: langCode == 'mr'
          ? 'गावातील ३४ हेक्टर गायराण जमिनीवर ५ बचत गट मिळून ५० उस्मानाबादी शेळ्यांचे संगोपन करू शकतात. रामटेक आठवडी बाजारात जिवंत वजनावर ₹३१० ते ₹३७०/किलो दर मिळतो. उन्हाळ्यासाठी सायलेज चारा बँक तयार करणे आवश्यक आहे.'
          : '34 ha grazing commons can support 50 Osmanabadi goats across 5 SHGs. Live-weight mandi rate at Ramtek is ₹310 - ₹370/kg. Establishing a silage fodder bank is essential for summer survival.',
      hasNumber: true,
      numberRulePassed: true,
      sourceCitation: 'BAIF & Animal Husbandry Directorate',
      sourceDate: 'Oct 2026 (Estimate)',
      calculatedFormula: 'Revenue = (50 Does × 1.8 Kids/yr × 25 kg × ₹340/kg) - Feed cost',
      actionableTips: [
        'Enrol with Pashu Sakhi for deworming and PPR vaccination every 6 months.',
        'Harvest surplus August grass for silo storage before seeding.'
      ],
    );
  }

  ChatMessage _buildCropWeatherResponse(String langCode, Village village) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: langCode == 'mr'
          ? 'नागपूर जिल्ह्यात रब्बी हंगामात हरभरा (चना), रब्बी ज्वारी आणि भाजीपाला उपयुक्त आहेत. हवामान अंदाजानुसार पुढील आठवड्यात कोरडे हवामान राहील. सिंचनासाठी विहिरीतील पाण्याची पातळी समाधानकारक (५.२ मी) आहे.'
          : 'For Nagpur district Rabi season, Gram (Chana), Rabi Sorghum, and Vegetables are most suited. Weather outlook is clear with optimal soil moisture. Community well water table is healthy at 5.2m.',
      hasNumber: true,
      numberRulePassed: true,
      sourceCitation: 'IMD Agro-Meteorological Advisory & KVK Nagpur',
      sourceDate: '06 Oct 2026',
      actionableTips: [
        'Adopt drip/micro-sprinklers for winter vegetable plots to save 40% water.',
        'Seed treatment with Trichoderma prevents root wilt in gram.'
      ],
    );
  }

  ChatMessage _buildOutOfScopeResponse(String langCode) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: langCode == 'mr'
          ? 'हा विषय वन हक्क कायदे आणि सुरक्षितता धोरणांच्या कक्षेबाहेर आहे. वनजमीन विक्री, रासायनिक औषध मात्रा किंवा वन्यजीव शिकार यांसारख्या बाबींना ॲपमध्ये परवानगी नाही. कृपया अधिकृत कृषी अधिकारी किंवा कृषी विज्ञान केंद्र (KVK) शी संपर्क साधा.'
          : 'This request is outside the scope of VanRozgar safety rules (e.g. chemical pesticide dosages, land alienation, or wildlife hunting). Please consult your local Agriculture Officer or Krishi Vigyan Kendra (KVK).',
      hasNumber: false,
      numberRulePassed: false,
      actionableTips: [
        'Visit nearest Krishi Vigyan Kendra (KVK) for specialized technical advice.'
      ],
    );
  }

  ChatMessage _buildFallbackResponse(String langCode) {
    return ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      sender: MessageSender.assistant,
      text: langCode == 'mr'
          ? 'माझ्याकडे या विशिष्ट प्रश्नासाठी प्रमाणित व अचूक आकडेवारी उपलब्ध नाही. चुकीची माहिती देण्याऐवजी मी आपल्याला तालुका कृषी अधिकारी किंवा कृषी विज्ञान केंद्र (KVK) कडे विचारणा करण्याचा सल्ला देतो.'
          : 'I do not have a verified, reliable number for this specific query. Rather than providing an unverified guess, please consult the Block Agriculture Officer or Krishi Vigyan Kendra (KVK).',
      hasNumber: false,
      numberRulePassed: false,
      sourceCitation: 'Safety Gate - Number Rule Fallback',
      sourceDate: 'Live Check',
      actionableTips: [
        'Check certified crop tables at Ramtek APMC office.',
        'Verify with Gram Panchayat Agriculture Committee.'
      ],
    );
  }
}
