# VanRozgar 2.0 (वनरोजगार २.०)
### AI-Powered Village Livelihood Intelligence Platform
*From Forest Rights to Sustainable Livelihoods*

---

## 🌲 Overview

**VanRozgar 2.0** is an AI-powered GIS resource and livelihood planning platform built for Community Forest Resource (CFR) title-holding villages under the Forest Rights Act (FRA), 2006.

> **Live-data status:** The app currently includes a prototype village/resource catalog, not an authoritative statewide register. Firebase phone authentication, shared Firestore resource-verification updates, and live map tiles are configurable. Official 7/12 records and legal boundaries remain unavailable until an authorized API is configured; the app does not fabricate extracts or boundaries.

The foundational principle of the platform:
> **"The app suggests, people check, the Gram Sabha decides."**
> *(ॲप सुचवते, लोक तपासतात, ग्रामसभा ठरवते.)*

The app never modifies statutory boundaries or acts as a substitute for the Gram Sabha. It provides verified spatial resource intelligence, legal gatekeeping, multi-scenario what-if simulations, and voice-guided advisory in Marathi, Hindi, and English.

---

## 🚀 Core Features & Implementation Modules

### 1. Trust Label & Data Provenance (Feature 1)
Every resource, market price, and recommendation carries a verified **Trust Label**:
- **Source**: (e.g. *MRSAC Geoportal, ATREE CFR WebGIS, Agmarknet, Nagpur DLC Approvals Register*)
- **Date**: (*Feb 2018, Oct 2026*)
- **Check Status**: `To be verified`, `Confirmed`, `Changed`, `Rejected`
- **Confidence Grade**: `High` (Committee ground verified), `Medium` (Official satellite layer), `Low` (7/12 text guess)

### 2. Resource Scoring & Field Check (Feature 2)
Computes dynamic resource utility $U \in [0, 1]$:
$$U = 0.35 A + 0.25 C + 0.25 S + 0.15 R$$
- **A**: Availability in main season ($0.0 - 1.0$)
- **C**: Physical condition ($0.0 - 1.0$)
- **S**: Months active divided by $12$
- **R**: Physical reach and accessibility ($0.0 - 1.0$)

**Labels**:
- **$0.70 - 1.00$**: Useful (*उपयुक्त*)
- **$0.40 - 0.69$**: Partly Useful (*अंशतः उपयुक्त*)
- **$< 0.40$**: Not Useful (*अनुपयुक्त*)

### 3. Legal Gatekeeper & Top 5 Livelihood Ranking (Feature 3)
Applies 4 non-negotiable statutory gates before ranking:
1. **FRA Section 4(4)**: Prohibits sale, lease, or alienation of forest land.
2. **FRA Section 3(1)(l)**: Bans commercial hunting or trapping.
3. **FRA Section 5**: Prohibits commercial timber felling and harm to wildlife/sacred groves.
4. **Forest Land Conversion Gate**: Requires using existing village/indoor space; prohibits clearing natural forest.

**Fit Score Formula**:
$$F = 0.35 M + 0.20 K + 0.15 P + 0.15 E + 0.15 G$$
- **M**: Average utility score of required resources
- **K**: Market access score (from 6-question village profile)
- **P**: Village skills and SHG participation score
- **E**: Ease of startup
- **G**: Green / ecological fit

### 4. Complete 22 Livelihood Ideas Library
1. Goat Rearing & Breeding Group (शेळीपालन)
2. Community Dairy & Livestock Hub (दुग्धव्यवसाय)
3. Forest Honey & Apiculture (मधमाश्या पालन)
4. Bamboo Products & Furniture (बांबू प्रक्रिया उद्योग)
5. Forest & Native Plant Nursery (रोपवाटिका)
6. Medicinal Plant Collection & Value Addition (वनौषधी प्रक्रिया)
7. Tendu Leaf Collection, Grading & Direct Sale (तेंदू पान संकलन)
8. Fishery in Existing Ponds & Check Dams (मत्स्य व्यवसाय)
9. Desi Backyard Poultry & Egg Cluster (कुक्कुटपालन)
10. Natural Lac Cultivation on Host Trees (लाख शेती)
11. Leaf Plate (Patrawali & Dona) Unit (पत्रावळी व द्रोण)
12. Bamboo Handicrafts & Designer Decor (बांबू हस्तकला)
13. Van Dhan Minor Forest Produce (MFP) Processing (लघु वनोपज प्रक्रिया)
14. Forest Produce Sorting & Brand Packaging (पॅकेजिंग व ब्रँडिंग)
15. Herbal Oils & Personal Care Formulation (हर्बल उत्पादने)
16. Community Fodder Bank & Silage Depot (चारा बँक)
17. Certified Village Nature & Biodiversity Guides (निसर्ग मार्गदर्शक)
18. Community Eco-Tourism & Tribal Homestays (पर्यावरण पर्यटन)
19. CFR Watershed Restoration & Soil Conservation (पाणलोट विकास कामे)
20. Community Forest Patrolling & Firebreak Maintenance (वन संरक्षण व वनवणवा नियंत्रण)
21. Mulberry & Tasar Silk Sericulture (रेशीम कीटक संगोपन)
22. Indoor Oyster & Paddy Straw Mushroom Cultivation (अळंबी उत्पादन)

### 5. What-If Livelihood Simulator
Allows Gram Sabha committees to compare single vs integrated use cases (e.g. *Fish Farming* vs *Irrigation* vs *Integrated Aquaculture + Irrigation + Desilting*) with live sliders for capital investment, water allocation, and SHG household count.

### 6. Marathi Voice AI Assistant (Feature 5)
Interactive voice assistant equipped with the **Strict Number Rule (Section 11)**:
- Verified mandi prices via Agmarknet (`data.gov.in`)
- Mathematical bounds calculated by deterministic code
- Fallback advice if data is unverified: directs users to Krishi Vigyan Kendra (KVK)
- Voice synthesis and Marathi STT simulation.

### 7. Gram Sabha Assistant & 1-Page A4 PDF Summary (Feature 4)
- Automated Quorum Validator under **FRA Rule 4(2)** ($\ge 50\%$ total voters with $\ge 33\%$ women).
- Vote tracker per idea and leader assignment.
- One-click exportable 1-page A4 summary for village meetings.

---

## 📱 Running the Flutter Application

```bash
# Navigate to the project directory
cd vanrozgar_app

# Fetch dependencies
flutter pub get

# Run on Chrome / Web
flutter run -d chrome

# Run on Android Emulator or Connected Device
flutter run -d android
```

### Firebase authentication and realtime verification

Create a Firebase project, enable **Phone** as an Authentication provider, register the Android and Web apps, and enable Cloud Firestore. For Web, add the deployed host to Firebase Authentication's authorized domains. For Android, follow Firebase's phone-auth setup for the app's signing certificate. Do not commit Firebase project values or any service credentials.

Pass the Firebase app values at run/build time (use the matching Web or Android app ID):

```powershell
flutter run -d chrome `
  --dart-define=FIREBASE_API_KEY=<web-api-key> `
  --dart-define=FIREBASE_PROJECT_ID=<project-id> `
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=<sender-id> `
  --dart-define=FIREBASE_WEB_APP_ID=<web-app-id> `
  --dart-define=FIREBASE_AUTH_DOMAIN=<project-id>.firebaseapp.com
```

For Android, replace `FIREBASE_WEB_APP_ID` with `FIREBASE_ANDROID_APP_ID` and run on the Android target. If Firebase is not configured, the app opens in prototype mode, but phone sign-in reports that setup is required and village workspaces remain behind sign-in.

Firestore collections used by the app:

- `users/{firebaseUid}`: provision `displayName`, `role`, `allowedDistricts`, and `allowedVillageIds` from a trusted admin process. Clients must not be allowed to assign their own role or access scope.
- `villages/{villageId}/resources/{resourceId}`: shared resource field-verification updates (`availabilityA`, `conditionC`, `seasonalityS`, `reachR`, `reason`, `verifiedBy`, `verificationNote`, `status`, `updatedAt`). Signed-in clients can read updates for villages they may access and submit verification updates only for authorized committee members. Enforce these conditions in Firestore Security Rules; do not deploy open rules.
- `villages/{villageId}`: provision its authoritative `district` field for the included [firestore.rules](./firestore.rules) access checks. New phone-auth users have no village/district scope until an administrator provisions their profile. Role and scope documents are server-managed.

Deploy the included rules before enabling Firestore: `firebase deploy --only firestore:rules`. The client intentionally cannot grant itself a committee/admin role or modify access profiles.

### Official 7/12 API

The public land-record portal is not treated as a public JSON API. To enable record retrieval, provide an approved HTTPS server-side API/proxy URL at build/run time using `--dart-define=MAHABHUMI_712_API_URL=<authorized-endpoint>`. The app sends the signed-in user's Firebase ID token as a Bearer token; the proxy must validate it and enforce user authorization. Keep government/vendor credentials on that server, not in the Flutter app. The endpoint receives `district`, `taluka`, `village`, and `surveyNumber` query parameters and must return the field names parsed in `lib/services/mahabhumi_api_service.dart`; responses missing required fields are rejected rather than filled with sample values. Configure browser CORS on the proxy where applicable.

### Maps and statewide catalog

The map supports OpenStreetMap street tiles and Esri World Imagery satellite tiles with attribution. These are base maps, not official cadastral/CFR boundary layers. Village/resource coordinates and statistics currently come from prototype catalog data; use an authoritative statewide source before treating them as factual. The district selector includes all 36 Maharashtra districts, but a complete real village register still needs to be supplied.

---

## 🌐 Instant Web / PWA Preview

Open `vanrozgar_app/web_preview/index.html` in any web browser to interact with the full prototype, test live sliders, speech synthesis, and GIS canvas.
