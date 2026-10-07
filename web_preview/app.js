// VanRozgar 2.0 Interactive JavaScript Engine

const villageData = {
  name: "Talavade",
  marathiName: "तळवडे",
  taluka: "Ramtek",
  district: "Nagpur",
  cfrArea: 324.5,
  households: 184,
  readiness: 78,
  waterScore: 82,
  landScore: 74,
  forestScore: 89,
  skillsScore: 68,
  marketScore: 61,
  infraScore: 72,
  sustainScore: 85
};

const resourcesList = [
  {
    id: "res_check_dam_1",
    name: "Talavade Nala Check Dam",
    marathi: "तळवडे नाला सिमेंट बंधारा",
    type: "Check Dam",
    lat: 18.5674,
    lng: 73.9123,
    a: 0.60,
    c: 0.40,
    s: 0.33,
    r: 0.80,
    area: "0.8 ha",
    pinX: 28,
    pinY: 35,
    reason: "Check dam has water only 4 months; moderate siltation and minor leakage in weir.",
    aiAssessment: "Water present, moderate siltation, usable for seasonal fisheries and rabi irrigation.",
    tags: ["Check Dam", "Water Level: 60%", "Condition: Partially Damaged", "Map Match: 92%"],
    survey: "14/CFR"
  },
  {
    id: "res_pond_1",
    name: "Gaon Talao (Perennial Pond)",
    marathi: "गाव तलाव (बारमाही)",
    type: "Pond",
    lat: 18.5690,
    lng: 73.9145,
    a: 0.90,
    c: 0.80,
    s: 0.83,
    r: 0.95,
    area: "2.4 ha",
    pinX: 62,
    pinY: 42,
    reason: "Perennial water available 10 months with good catchment and sturdy outlet.",
    aiAssessment: "Optimal for multi-tier fish culture (Rohu/Catla) and livestock hydration.",
    tags: ["Pond Body", "Water Level: 85%", "Condition: Good", "Map Match: 96%"],
    survey: "18/1"
  },
  {
    id: "res_bamboo_1",
    name: "CFR Bamboo Forest Stand",
    marathi: "सामुदायिक वन बांबू क्षेत्र",
    type: "Bamboo",
    lat: 18.5640,
    lng: 73.9100,
    a: 0.95,
    c: 0.90,
    s: 1.00,
    r: 0.75,
    area: "85.0 ha",
    pinX: 20,
    pinY: 72,
    reason: "High culm density (Manvel & Manga). Annual sustainable harvest > 45,000 culms.",
    aiAssessment: "Prime raw material for furniture, bamboo blinds, craft and bio-charcoal.",
    tags: ["Bamboo Forest", "Culm Density: High", "Maturity: 3-4 Yrs"],
    survey: "Comp-142"
  },
  {
    id: "res_grazing_1",
    name: "Gairan & Fodder Reserve",
    marathi: "गायराण व चारा कुरण",
    type: "Grazing",
    lat: 18.5720,
    lng: 73.9180,
    a: 0.70,
    c: 0.55,
    s: 0.58,
    r: 0.90,
    area: "34.0 ha",
    pinX: 78,
    pinY: 65,
    reason: "Abundant biomass during monsoon. Requires rotational grazing to prevent overgrazing.",
    aiAssessment: "Ideal support base for 250+ indigenous goats and 60 dairy cattle.",
    tags: ["Grazing Land", "Grass Biomass: Moderate"],
    survey: "22/Gairan"
  }
];

const livelihoodIdeas = [
  {
    id: "idea_bamboo",
    rank: 1,
    title: "Bamboo Craft & Product Value Addition",
    marathi: "बांबू प्रक्रिया व फर्निचर निर्मिती",
    score: 92,
    revenue: "₹6.5L - ₹8.2L / yr",
    investment: "₹2.20 L",
    labor: "320 days",
    reason: "High culm density in CFR forest + active weaving skills + surging furniture demand in Nagpur.",
    legal: "FRA 2006 Sec 3(1)(c) - Minor Forest Produce Ownership",
    passed: true
  },
  {
    id: "idea_fish",
    rank: 2,
    title: "Fishery in Existing Ponds & Check Dams",
    marathi: "अस्तित्वातील तलावातील मत्स्य व्यवसाय",
    score: 87,
    revenue: "₹3.1L - ₹5.4L / yr",
    investment: "₹1.50 L",
    labor: "180 days",
    reason: "Perennial pond available for 10 months; composite carp provides fast cash returns.",
    legal: "FRA 2006 Sec 3(1)(d) - Water Bodies & Fisheries Rights in CFR",
    passed: true
  },
  {
    id: "idea_goat",
    rank: 3,
    title: "Goat Rearing & Breeding Group",
    marathi: "शेळीपालन व पैदास गट",
    score: 78,
    revenue: "₹3.2L - ₹4.8L / yr",
    investment: "₹1.80 L",
    labor: "220 days",
    reason: "Secured grazing entitlement in CFR order + 5 active SHG groups for collective rearing.",
    legal: "FRA 2006 Sec 3(1)(d) - Grazing Entitlement",
    passed: true
  },
  {
    id: "idea_honey",
    rank: 4,
    title: "Forest Honey & Apiculture Value Chain",
    marathi: "वन मध संकलन व मधमाश्या पालन",
    score: 75,
    revenue: "₹2.8L - ₹4.2L / yr",
    investment: "₹1.10 L",
    labor: "160 days",
    reason: "Rich flowering deciduous forest; zero land conversion needed with high retail pricing.",
    legal: "FRA 2006 Sec 3(1)(c) - Minor Forest Produce Rights",
    passed: true
  },
  {
    id: "idea_mfp",
    rank: 5,
    title: "Van Dhan Minor Forest Produce Processing",
    marathi: "वन धन लघु वनोपज प्रक्रिया केंद्र",
    score: 71,
    revenue: "₹5.5L - ₹8.0L / yr",
    investment: "₹2.00 L",
    labor: "310 days",
    reason: "Abundant Mahua, Tamarind & Gum; supported by 100% TRIFED Van Dhan grant.",
    legal: "FRA 2006 Sec 3(1)(c) & TRIFED Van Dhan Mission",
    passed: true
  },
  // Gated Ideas
  {
    id: "idea_timber",
    title: "Commercial Teak Timber Felling",
    marathi: "व्यावसायिक सागवान लाकूडतोड",
    score: 0,
    passed: false,
    reason: "LEGAL GATE REJECTION: Violates FRA Sec 5 (Prohibits commercial tree felling & biodiversity destruction)."
  },
  {
    id: "idea_lease",
    title: "Commercial Resort Forest Land Lease",
    marathi: "वन जमीन खाजगी रिसॉर्टला भाडेतत्त्वावर देणे",
    score: 0,
    passed: false,
    reason: "LEGAL GATE REJECTION: Violates FRA Sec 4(4) (Strictly bans alienation, lease, or sale of forest land)."
  }
];

let currentLang = 'mr';
let currentRole = 'committee';
let activeScreen = 'home';
let selectedRes = resourcesList[0];

// State Initialization
document.addEventListener('DOMContentLoaded', () => {
  renderMapCanvas();
  renderTopIdeas();
  setupEventListeners();
  updateReadinessScores();
});

function calculateUtilityScore(a, c, s, r) {
  const score = (0.35 * a) + (0.25 * c) + (0.25 * s) + (0.15 * r);
  return parseFloat(Math.min(Math.max(score, 0), 1).toFixed(2));
}

function getUtilityLabel(score) {
  if (score >= 0.70) return { text: "Useful", marathi: "उपयुक्त", color: "var(--useful-green)", bg: "var(--useful-green-bg)" };
  if (score >= 0.40) return { text: "Partly Useful", marathi: "अंशतः उपयुक्त", color: "var(--partly-yellow)", bg: "var(--partly-yellow-bg)" };
  return { text: "Not Useful", marathi: "अनुपयुक्त", color: "var(--not-useful-red)", bg: "var(--not-useful-red-bg)" };
}

function renderMapCanvas() {
  const canvas = document.getElementById('gisMapCanvas');
  if (!canvas) return;
  const ctx = canvas.getContext('2d');
  const w = canvas.width;
  const h = canvas.height;

  // Background
  ctx.fillStyle = '#173627';
  ctx.fillRect(0, 0, w, h);

  // Terrain contours
  ctx.fillStyle = '#214D38';
  ctx.beginPath();
  ctx.arc(w/2, h/2, 110, 0, Math.PI * 2);
  ctx.fill();

  // CFR Boundary Polygon (Purple shade)
  ctx.fillStyle = 'rgba(124, 58, 237, 0.18)';
  ctx.strokeStyle = '#8B5CF6';
  ctx.lineWidth = 2.5;
  ctx.beginPath();
  ctx.moveTo(w * 0.15, h * 0.2);
  ctx.lineTo(w * 0.85, h * 0.15);
  ctx.lineTo(w * 0.90, h * 0.80);
  ctx.lineTo(w * 0.45, h * 0.90);
  ctx.lineTo(w * 0.10, h * 0.75);
  ctx.closePath();
  ctx.fill();
  ctx.stroke();

  // Water stream line
  ctx.strokeStyle = '#38BDF8';
  ctx.lineWidth = 3;
  ctx.beginPath();
  ctx.moveTo(w * 0.28, h * 0.35);
  ctx.quadraticCurveTo(w * 0.45, h * 0.40, w * 0.62, h * 0.42);
  ctx.stroke();

  // Village Boundary (Dashed)
  ctx.strokeStyle = 'rgba(255, 255, 255, 0.5)';
  ctx.setLineDash([6, 6]);
  ctx.lineWidth = 1.5;
  ctx.beginPath();
  ctx.arc(w/2, h/2, 100, 0, Math.PI * 2);
  ctx.stroke();
  ctx.setLineDash([]);

  // Survey parcel numbers
  ctx.fillStyle = 'rgba(255, 255, 255, 0.7)';
  ctx.font = '9px Inter, sans-serif';
  ctx.fillText('Survey #14/CFR', w * 0.18, h * 0.3);
  ctx.fillText('Survey #18/1 (Talao)', w * 0.55, h * 0.38);
  ctx.fillText('Comp 142 (Bamboo)', w * 0.12, h * 0.70);
  ctx.fillText('Survey #22 (Gairan)', w * 0.68, h * 0.62);
}

function renderTopIdeas() {
  const container = document.getElementById('ideas-list-container');
  if (!container) return;

  container.innerHTML = livelihoodIdeas.filter(i => i.passed).map((idea, idx) => `
    <div class="action-card" style="text-align: left; padding: 12px; margin-bottom: 10px; border-left: 4px solid var(--primary);" onclick="openIdeaDetail('${idea.id}')">
      <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 4px;">
        <div>
          <span style="background: var(--primary-light); color: var(--primary-dark); font-weight: 800; font-size: 11px; padding: 2px 6px; border-radius: 4px;">#${idea.rank}</span>
          <strong style="font-size: 13.5px; margin-left: 4px;">${idea.title}</strong>
        </div>
        <span style="background: var(--useful-green-bg); color: var(--useful-green); font-weight: 800; font-size: 11px; padding: 2px 8px; border-radius: 6px;">Fit: ${idea.score}%</span>
      </div>
      <p style="font-size: 11px; color: var(--primary); font-weight: 600; margin-bottom: 6px;">${idea.marathi}</p>
      <p style="font-size: 11.5px; color: var(--text-main); margin-bottom: 8px;">${idea.reason}</p>
      <div style="display: flex; justify-content: space-between; font-size: 11px; color: var(--text-muted); background: var(--background); padding: 6px 8px; border-radius: 6px;">
        <span>Rev: <b style="color: var(--primary-dark);">${idea.revenue}</b></span>
        <span>Invest: <b>${idea.investment}</b></span>
        <span>Labor: <b>${idea.labor}</b></span>
      </div>
    </div>
  `).join('');
}

function setupEventListeners() {
  // Navigation tabs
  document.querySelectorAll('.nav-item').forEach(item => {
    item.addEventListener('click', () => {
      document.querySelectorAll('.nav-item').forEach(n => n.classList.remove('active'));
      item.classList.add('active');
      const target = item.dataset.target;
      showScreen(target);
    });
  });

  // Simulator Sliders
  const invSlider = document.getElementById('sim-investment');
  const waterSlider = document.getElementById('sim-water');
  const shgSlider = document.getElementById('sim-shg');

  if (invSlider) invSlider.addEventListener('input', updateSimulation);
  if (waterSlider) waterSlider.addEventListener('input', updateSimulation);
  if (shgSlider) shgSlider.addEventListener('input', updateSimulation);

  // Verification Sliders
  ['v-a', 'v-c', 'v-s', 'v-r'].forEach(id => {
    const el = document.getElementById(id);
    if (el) el.addEventListener('input', updateVerifyScore);
  });
}

function showScreen(screenId) {
  activeScreen = screenId;
  document.querySelectorAll('.screen-page').forEach(page => page.classList.remove('active-screen'));
  const targetPage = document.getElementById(`screen-${screenId}`);
  if (targetPage) targetPage.classList.add('active-screen');

  if (screenId === 'map') {
    setTimeout(renderMapCanvas, 50);
  }
}

function selectResourcePin(resId) {
  selectedRes = resourcesList.find(r => r.id === resId) || resourcesList[0];
  document.querySelectorAll('.map-pin').forEach(p => p.classList.remove('selected'));
  const pin = document.getElementById(`pin-${resId}`);
  if (pin) pin.classList.add('selected');

  const inspector = document.getElementById('resource-inspector-box');
  if (inspector) {
    const score = calculateUtilityScore(selectedRes.a, selectedRes.c, selectedRes.s, selectedRes.r);
    const label = getUtilityLabel(score);

    inspector.innerHTML = `
      <div style="display: flex; justify-content: space-between; align-items: flex-start;">
        <div>
          <h4 style="font-size: 14.5px; font-weight: 800;">${selectedRes.name}</h4>
          <p style="font-size: 11.5px; color: var(--text-muted);">${selectedRes.type} • Area: ${selectedRes.area}</p>
        </div>
        <span style="background: ${label.bg}; color: ${label.color}; font-weight: 800; font-size: 11.5px; padding: 3px 8px; border-radius: 6px;">Score: ${score} (${label.text})</span>
      </div>
      <p style="font-size: 12px; color: var(--text-main); margin: 8px 0; line-height: 1.35;">${selectedRes.reason}</p>
      <div style="display: flex; gap: 8px; margin-top: 8px;">
        <button class="btn-sm-white" style="flex: 1; background: var(--primary); color: white; padding: 8px;" onclick="openResourceDetail()">AI Analysis</button>
        <button class="btn-sm-white" style="flex: 1; background: var(--secondary-orange); color: white; padding: 8px;" onclick="openVerifyModal()">Verify on Ground</button>
      </div>
    `;
  }
}

function openResourceDetail() {
  showScreen('resource-detail');
}

function openVerifyModal() {
  showScreen('resource-verify');
  document.getElementById('v-a').value = selectedRes.a * 100;
  document.getElementById('v-c').value = selectedRes.c * 100;
  document.getElementById('v-s').value = selectedRes.s * 100;
  document.getElementById('v-r').value = selectedRes.r * 100;
  updateVerifyScore();
}

function updateVerifyScore() {
  const a = parseFloat(document.getElementById('v-a').value) / 100;
  const c = parseFloat(document.getElementById('v-c').value) / 100;
  const s = parseFloat(document.getElementById('v-s').value) / 100;
  const r = parseFloat(document.getElementById('v-r').value) / 100;

  document.getElementById('v-a-val').innerText = `${Math.round(a * 100)}%`;
  document.getElementById('v-c-val').innerText = c >= 0.7 ? 'Good' : (c >= 0.4 ? 'Moderate' : 'Poor');
  document.getElementById('v-s-val').innerText = `${Math.round(s * 12)} mo`;
  document.getElementById('v-r-val').innerText = `${Math.round(r * 100)}%`;

  const score = calculateUtilityScore(a, c, s, r);
  const label = getUtilityLabel(score);

  document.getElementById('live-score-display').innerText = score;
  document.getElementById('live-label-display').innerText = `Label: ${label.text} (${label.marathi})`;
  document.getElementById('live-label-display').style.color = label.color;
}

function saveVerification() {
  selectedRes.a = parseFloat(document.getElementById('v-a').value) / 100;
  selectedRes.c = parseFloat(document.getElementById('v-c').value) / 100;
  selectedRes.s = parseFloat(document.getElementById('v-s').value) / 100;
  selectedRes.r = parseFloat(document.getElementById('v-r').value) / 100;

  alert('Resource verification saved! Ground record updated in CFR ledger.');
  showScreen('map');
  selectResourcePin(selectedRes.id);
}

function updateSimulation() {
  const inv = parseFloat(document.getElementById('sim-investment').value);
  const water = parseFloat(document.getElementById('sim-water').value);
  const shg = parseInt(document.getElementById('sim-shg').value);

  document.getElementById('sim-inv-val').innerText = `₹${inv.toFixed(1)} Lakhs`;
  document.getElementById('sim-water-val').innerText = `${water}% / ${100 - water}%`;
  document.getElementById('sim-shg-val').innerText = `${shg} families`;

  const estRev = (2.6 + (inv * 0.65) + (shg * 0.08)).toFixed(2);
  const estDays = Math.min(480, Math.round(220 + (shg * 6)));

  document.getElementById('sim-result-rev').innerText = `₹${estRev}L`;
  document.getElementById('sim-result-days').innerText = `${estDays} days`;
  document.getElementById('sim-result-fit').innerText = `92%`;
}

function sendVoiceMessage(customText) {
  const input = document.getElementById('chat-input');
  const text = customText || input.value.trim();
  if (!text) return;

  const chatBox = document.getElementById('chat-messages-container');
  chatBox.innerHTML += `
    <div class="chat-bubble user">${text}</div>
  `;
  if (!customText) input.value = '';

  // Simulate AI Voice Response with Number Rule compliance
  setTimeout(() => {
    let reply = "";
    let numberCard = "";
    let audioSpoken = "";

    if (text.includes('व्यवसाय') || text.includes('recommend') || text.includes('कोणता')) {
      reply = "तळवडे गावातील नैसर्गिक संसाधने आणि पाण्याच्या उपलब्धतेनुसार ३ प्रमुख व्यवसाय सर्वोत्तम ठरतात:<br>१. बांबू मूल्यवर्धन (उत्पन्न: ₹६.५ ते ₹८.२ लाख)<br>२. तलावात मत्स्यपालन (उत्पन्न: ₹३.१ ते ₹५.४ लाख)<br>३. शेळीपालन व चारा बँक (उत्पन्न: ₹३.२ ते ₹४.८ लाख)";
      numberCard = `
        <div class="number-card">
          <b style="color: var(--useful-green);">✓ Number Rule Verified (Rule 11)</b><br>
          Source: नागपूर CFR कृती आराखडा व ॲगमार्कनेट (Estimate Oct 2026)<br>
          Formula: नफा = (उत्पादन × बाजारभाव) - उत्पादन खर्च
        </div>
      `;
      audioSpoken = "तुमच्या गावातील नैसर्गिक संसाधने आणि पाण्याच्या उपलब्धतेचा विचार करता बांबू प्रक्रिया, मत्स्यपालन आणि शेळीपालन हे ३ उत्तम पर्याय आहेत.";
    } else {
      reply = "बांबू मूल्यवर्धन केंद्रासाठी ग्रामसभेचा ठराव आणि वन धन विकास योजनेतून ₹१५ लाखांचे १००% अनुदान उपलब्ध आहे. बोरॉन प्रक्रियेने दर ४ पट वाढतो.";
      audioSpoken = "बांबू मूल्यवर्धन केंद्रासाठी वन धन विकास योजनेतून पंधरा लाख रुपयांचे अनुदान उपलब्ध आहे.";
    }

    chatBox.innerHTML += `
      <div class="chat-bubble ai">
        ${reply}
        ${numberCard}
        <button class="btn-sm-white" style="background: var(--primary); color: white; margin-top: 8px;" onclick="speakText('${audioSpoken}')">🔊 Listen in Marathi (ऐका)</button>
      </div>
    `;
    chatBox.scrollTop = chatBox.scrollHeight;
  }, 500);
}

function speakText(text) {
  if ('speechSynthesis' in window) {
    const utter = new SpeechSynthesisUtterance(text);
    utter.lang = 'mr-IN';
    window.speechSynthesis.speak(utter);
  } else {
    alert('Audio playback: ' + text);
  }
}

function openWhyNotOthersModal() {
  document.getElementById('whyNotOthersModal').classList.add('open');
}

function closeWhyNotOthersModal() {
  document.getElementById('whyNotOthersModal').classList.remove('open');
}

function openPdfReportModal() {
  document.getElementById('pdfReportModal').classList.add('open');
}

function closePdfReportModal() {
  document.getElementById('pdfReportModal').classList.remove('open');
}

function toggleDeviceView(mode) {
  document.querySelectorAll('.btn-toggle').forEach(b => b.classList.remove('active'));
  if (mode === 'web') {
    document.getElementById('btn-view-web').classList.add('active');
    document.getElementById('mobileFrame').classList.add('hidden-frame');
    document.getElementById('webDashboard').classList.add('active-view');
  } else {
    document.getElementById('btn-view-mobile').classList.add('active');
    document.getElementById('mobileFrame').classList.remove('hidden-frame');
    document.getElementById('webDashboard').classList.remove('active-view');
  }
}

function updateReadinessScores() {
  // Renders radar bars on home & web overview
}
