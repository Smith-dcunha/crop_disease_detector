import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
  _AppLocalizationsDelegate();

  // Get translations map
  static Map<String, Map<String, String>> _localizedValues = {
    'en': _enStrings,
    'hi': _hiStrings,
    'mr': _mrStrings,
    'te': _teStrings,
    'ta': _taStrings,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for all strings
  String get appName => translate('appName');
  String get appTagline => translate('appTagline');

  // Onboarding
  String get onboarding1Title => translate('onboarding1Title');
  String get onboarding1Subtitle => translate('onboarding1Subtitle');
  String get onboarding2Title => translate('onboarding2Title');
  String get onboarding2Subtitle => translate('onboarding2Subtitle');
  String get onboarding3Title => translate('onboarding3Title');
  String get onboarding3Subtitle => translate('onboarding3Subtitle');
  String get getStarted => translate('getStarted');
  String get skip => translate('skip');
  String get next => translate('next');

  // Home
  String get homeWelcome => translate('homeWelcome');
  String get homeSubtitle => translate('homeSubtitle');
  String get scanNow => translate('scanNow');
  String get recentScans => translate('recentScans');
  String get viewAll => translate('viewAll');
  String get noRecentScans => translate('noRecentScans');
  String get startFirstScan => translate('startFirstScan');

  // Stats
  String get totalScans => translate('totalScans');
  String get diseasesDetected => translate('diseasesDetected');
  String get healthyScans => translate('healthyScans');

  // Camera
  String get cameraTitle => translate('cameraTitle');
  String get cameraInstruction => translate('cameraInstruction');
  String get capturePhoto => translate('capturePhoto');
  String get retake => translate('retake');
  String get camera => translate('camera');
  String get gallery => translate('gallery');
  String get captureGuidelines => translate('captureGuidelines');

  // Analysis
  String get analyzing => translate('analyzing');
  String get processingImage => translate('processingImage');
  String get detectingDisease => translate('detectingDisease');
  String get almostDone => translate('almostDone');
  String get pleaseWait => translate('pleaseWait');

  // Results
  String get resultsTitle => translate('resultsTitle');
  String get diseaseDetected => translate('diseaseDetected');
  String get healthyCrop => translate('healthyCrop');
  String get confidence => translate('confidence');
  String get severity => translate('severity');
  String get detectedOn => translate('detectedOn');
  String get viewTreatment => translate('viewTreatment');
  String get scanAnother => translate('scanAnother');

  // History
  String get historyTitle => translate('historyTitle');
  String get allScans => translate('allScans');
  String get diseased => translate('diseased');
  String get healthy => translate('healthy');
  String get filterBy => translate('filterBy');
  String get clearHistory => translate('clearHistory');
  String get deleteConfirm => translate('deleteConfirm');
  String get clearAllConfirm => translate('clearAllConfirm');

  // Profile
  String get profileTitle => translate('profileTitle');
  String get settings => translate('settings');
  String get language => translate('language');
  String get selectLanguage => translate('selectLanguage');

  // Common
  String get ok => translate('ok');
  String get cancel => translate('cancel');
  String get delete => translate('delete');
  String get save => translate('save');

  // Messages
  String get scanSaved => translate('scanSaved');
  String get scanDeleted => translate('scanDeleted');
  String get historyCleared => translate('historyCleared');

  // Tips
  String get tipOfDay => translate('tipOfDay');
  String get tip1 => translate('tip1');
}

// English translations
const Map<String, String> _enStrings = {
  'appName': 'CropCare',
  'appTagline': 'AI-Powered Crop Disease Detection',

  'onboarding1Title': 'Detect Diseases Instantly',
  'onboarding1Subtitle': 'Capture a photo of your crop and get instant disease detection powered by AI',
  'onboarding2Title': 'Works Offline',
  'onboarding2Subtitle': 'No internet? No problem! All AI processing happens on your device',
  'onboarding3Title': 'Get Treatment Advice',
  'onboarding3Subtitle': 'Receive localized treatment recommendations and prevent crop loss',
  'getStarted': 'Get Started',
  'skip': 'Skip',
  'next': 'Next',

  'homeWelcome': 'Welcome back!',
  'homeSubtitle': 'Protect your crops with AI',
  'scanNow': 'Scan Crop',
  'recentScans': 'Recent Scans',
  'viewAll': 'View All',
  'noRecentScans': 'No scans yet',
  'startFirstScan': 'Start your first scan to detect diseases',

  'totalScans': 'Total Scans',
  'diseasesDetected': 'Diseases Found',
  'healthyScans': 'Healthy Crops',

  'cameraTitle': 'Capture Crop Image',
  'cameraInstruction': 'Position the affected leaf in the frame',
  'capturePhoto': 'Capture',
  'retake': 'Retake',
  'camera': 'Camera',
  'gallery': 'Gallery',
  'captureGuidelines': 'Capture Guidelines',

  'analyzing': 'Analyzing Image...',
  'processingImage': 'Processing your crop image',
  'detectingDisease': 'Detecting diseases',
  'almostDone': 'Almost done',
  'pleaseWait': 'Please wait...',

  'resultsTitle': 'Detection Results',
  'diseaseDetected': 'Disease Detected',
  'healthyCrop': 'Healthy Crop',
  'confidence': 'Confidence',
  'severity': 'Severity',
  'detectedOn': 'Detected on',
  'viewTreatment': 'View Treatment',
  'scanAnother': 'Scan Another',

  'historyTitle': 'Scan History',
  'allScans': 'All Scans',
  'diseased': 'Diseased',
  'healthy': 'Healthy',
  'filterBy': 'Filter by',
  'clearHistory': 'Clear History',
  'deleteConfirm': 'Are you sure you want to delete this scan?',
  'clearAllConfirm': 'Are you sure you want to clear all history?',

  'profileTitle': 'Profile',
  'settings': 'Settings',
  'language': 'Language',
  'selectLanguage': 'Select Language',

  'ok': 'OK',
  'cancel': 'Cancel',
  'delete': 'Delete',
  'save': 'Save',

  'scanSaved': 'Scan saved successfully',
  'scanDeleted': 'Scan deleted',
  'historyCleared': 'History cleared',

  'tipOfDay': 'Tip of the Day',
  'tip1': 'Use natural light for best results',
};

// Hindi translations
const Map<String, String> _hiStrings = {
  'appName': 'क्रॉपकेयर',
  'appTagline': 'एआई-संचालित फसल रोग पहचान',

  'onboarding1Title': 'तुरंत रोगों का पता लगाएं',
  'onboarding1Subtitle': 'अपनी फसल की तस्वीर लें और AI द्वारा तुरंत रोग की पहचान करें',
  'onboarding2Title': 'ऑफलाइन काम करता है',
  'onboarding2Subtitle': 'इंटरनेट नहीं? कोई समस्या नहीं! सभी AI प्रोसेसिंग आपके डिवाइस पर होती है',
  'onboarding3Title': 'उपचार सलाह प्राप्त करें',
  'onboarding3Subtitle': 'स्थानीय उपचार सुझाव प्राप्त करें और फसल नुकसान रोकें',
  'getStarted': 'शुरू करें',
  'skip': 'छोड़ें',
  'next': 'अगला',

  'homeWelcome': 'वापसी पर स्वागत है!',
  'homeSubtitle': 'AI से अपनी फसलों की रक्षा करें',
  'scanNow': 'फसल स्कैन करें',
  'recentScans': 'हाल के स्कैन',
  'viewAll': 'सभी देखें',
  'noRecentScans': 'अभी तक कोई स्कैन नहीं',
  'startFirstScan': 'रोगों का पता लगाने के लिए अपना पहला स्कैन शुरू करें',

  'totalScans': 'कुल स्कैन',
  'diseasesDetected': 'रोग मिले',
  'healthyScans': 'स्वस्थ फसलें',

  'cameraTitle': 'फसल की तस्वीर लें',
  'cameraInstruction': 'प्रभावित पत्ती को फ्रेम में रखें',
  'capturePhoto': 'तस्वीर लें',
  'retake': 'फिर से लें',
  'camera': 'कैमरा',
  'gallery': 'गैलरी',
  'captureGuidelines': 'कैप्चर दिशानिर्देश',

  'analyzing': 'छवि का विश्लेषण हो रहा है...',
  'processingImage': 'आपकी फसल की छवि संसाधित हो रही है',
  'detectingDisease': 'रोगों का पता लगाया जा रहा है',
  'almostDone': 'लगभग हो गया',
  'pleaseWait': 'कृपया प्रतीक्षा करें...',

  'resultsTitle': 'पहचान परिणाम',
  'diseaseDetected': 'रोग का पता चला',
  'healthyCrop': 'स्वस्थ फसल',
  'confidence': 'विश्वास',
  'severity': 'गंभीरता',
  'detectedOn': 'पता लगाया गया',
  'viewTreatment': 'उपचार देखें',
  'scanAnother': 'एक और स्कैन करें',

  'historyTitle': 'स्कैन इतिहास',
  'allScans': 'सभी स्कैन',
  'diseased': 'रोगग्रस्त',
  'healthy': 'स्वस्थ',
  'filterBy': 'फ़िल्टर करें',
  'clearHistory': 'इतिहास साफ़ करें',
  'deleteConfirm': 'क्या आप वाकई इस स्कैन को हटाना चाहते हैं?',
  'clearAllConfirm': 'क्या आप वाकई सभी इतिहास साफ़ करना चाहते हैं?',

  'profileTitle': 'प्रोफ़ाइल',
  'settings': 'सेटिंग्स',
  'language': 'भाषा',
  'selectLanguage': 'भाषा चुनें',

  'ok': 'ठीक है',
  'cancel': 'रद्द करें',
  'delete': 'हटाएं',
  'save': 'सहेजें',

  'scanSaved': 'स्कैन सफलतापूर्वक सहेजा गया',
  'scanDeleted': 'स्कैन हटाया गया',
  'historyCleared': 'इतिहास साफ़ किया गया',

  'tipOfDay': 'आज की टिप',
  'tip1': 'सर्वोत्तम परिणामों के लिए प्राकृतिक प्रकाश का उपयोग करें',
};

// Marathi translations
const Map<String, String> _mrStrings = {
  'appName': 'क्रॉपकेअर',
  'appTagline': 'एआय-चालित पीक रोग शोध',

  'onboarding1Title': 'त्वरित रोग शोधा',
  'onboarding1Subtitle': 'आपल्या पिकाचा फोटो घ्या आणि AI द्वारे त्वरित रोग ओळखा',
  'onboarding2Title': 'ऑफलाइन कार्य करते',
  'onboarding2Subtitle': 'इंटरनेट नाही? काही हरकत नाही! सर्व AI प्रक्रिया आपल्या डिव्हाइसवर होते',
  'onboarding3Title': 'उपचार सल्ला मिळवा',
  'onboarding3Subtitle': 'स्थानिक उपचार शिफारसी मिळवा आणि पीक नुकसान टाळा',
  'getStarted': 'सुरू करा',
  'skip': 'वगळा',
  'next': 'पुढे',

  'homeWelcome': 'परत स्वागत आहे!',
  'homeSubtitle': 'AI सह आपल्या पिकांचे संरक्षण करा',
  'scanNow': 'पीक स्कॅन करा',
  'recentScans': 'अलीकडील स्कॅन',
  'viewAll': 'सर्व पहा',
  'noRecentScans': 'अद्याप स्कॅन नाहीत',
  'startFirstScan': 'रोग शोधण्यासाठी आपले पहिले स्कॅन सुरू करा',

  'totalScans': 'एकूण स्कॅन',
  'diseasesDetected': 'रोग आढळले',
  'healthyScans': 'निरोगी पिके',

  'cameraTitle': 'पिकाचा फोटो घ्या',
  'cameraInstruction': 'प्रभावित पान फ्रेममध्ये ठेवा',
  'capturePhoto': 'फोटो घ्या',
  'retake': 'पुन्हा घ्या',
  'camera': 'कॅमेरा',
  'gallery': 'गॅलरी',
  'captureGuidelines': 'कॅप्चर मार्गदर्शक',

  'analyzing': 'प्रतिमा विश्लेषण करत आहे...',
  'processingImage': 'आपल्या पिकाची प्रतिमा प्रक्रिया करत आहे',
  'detectingDisease': 'रोग शोधत आहे',
  'almostDone': 'जवळजवळ झाले',
  'pleaseWait': 'कृपया प्रतीक्षा करा...',

  'resultsTitle': 'शोध परिणाम',
  'diseaseDetected': 'रोग आढळला',
  'healthyCrop': 'निरोगी पीक',
  'confidence': 'विश्वास',
  'severity': 'तीव्रता',
  'detectedOn': 'शोधले',
  'viewTreatment': 'उपचार पहा',
  'scanAnother': 'आणखी स्कॅन करा',

  'historyTitle': 'स्कॅन इतिहास',
  'allScans': 'सर्व स्कॅन',
  'diseased': 'रोगग्रस्त',
  'healthy': 'निरोगी',
  'filterBy': 'फिल्टर करा',
  'clearHistory': 'इतिहास साफ करा',
  'deleteConfirm': 'तुम्हाला खात्री आहे की तुम्ही हे स्कॅन हटवू इच्छिता?',
  'clearAllConfirm': 'तुम्हाला खात्री आहे की तुम्ही सर्व इतिहास साफ करू इच्छिता?',

  'profileTitle': 'प्रोफाइल',
  'settings': 'सेटिंग्ज',
  'language': 'भाषा',
  'selectLanguage': 'भाषा निवडा',

  'ok': 'ठीक आहे',
  'cancel': 'रद्द करा',
  'delete': 'हटवा',
  'save': 'जतन करा',

  'scanSaved': 'स्कॅन यशस्वीरित्या जतन केले',
  'scanDeleted': 'स्कॅन हटवले',
  'historyCleared': 'इतिहास साफ केला',

  'tipOfDay': 'आजची टीप',
  'tip1': 'सर्वोत्तम परिणामांसाठी नैसर्गिक प्रकाश वापरा',
};

// Telugu translations
const Map<String, String> _teStrings = {
  'appName': 'క్రాప్‌కేర్',
  'appTagline': 'AI-ఆధారిత పంట వ్యాధి గుర్తింపు',

  'onboarding1Title': 'తక్షణం వ్యాధులను గుర్తించండి',
  'onboarding1Subtitle': 'మీ పంట ఫోటో తీసి AI ద్వారా తక్షణ వ్యాధి గుర్తింపు పొందండి',
  'onboarding2Title': 'ఆఫ్‌లైన్‌లో పని చేస్తుంది',
  'onboarding2Subtitle': 'ఇంటర్నెట్ లేదా? సమస్య లేదు! అన్ని AI ప్రాసెసింగ్ మీ పరికరంలో జరుగుతుంది',
  'onboarding3Title': 'చికిత్స సలహా పొందండి',
  'onboarding3Subtitle': 'స్థానిక చికిత్స సిఫార్సులను పొంది పంట నష్టాన్ని నివారించండి',
  'getStarted': 'ప్రారంభించండి',
  'skip': 'దాటవేయండి',
  'next': 'తదుపరి',

  'homeWelcome': 'తిరిగి స్వాగతం!',
  'homeSubtitle': 'AI తో మీ పంటలను రక్షించండి',
  'scanNow': 'పంట స్కాన్ చేయండి',
  'recentScans': 'ఇటీవలి స్కాన్‌లు',
  'viewAll': 'అన్నీ చూడండి',
  'noRecentScans': 'ఇంకా స్కాన్‌లు లేవు',
  'startFirstScan': 'వ్యాధులను గుర్తించడానికి మీ మొదటి స్కాన్ ప్రారంభించండి',

  'totalScans': 'మొత్తం స్కాన్‌లు',
  'diseasesDetected': 'వ్యాధులు కనుగొనబడ్డాయి',
  'healthyScans': 'ఆరోగ్యకరమైన పంటలు',

  'cameraTitle': 'పంట చిత్రం తీయండి',
  'cameraInstruction': 'ప్రభావిత ఆకును ఫ్రేమ్‌లో ఉంచండి',
  'capturePhoto': 'చిత్రం తీయండి',
  'retake': 'మళ్లీ తీయండి',
  'camera': 'కెమెరా',
  'gallery': 'గ్యాలరీ',
  'captureGuidelines': 'క్యాప్చర్ మార్గదర్శకాలు',

  'analyzing': 'చిత్రాన్ని విశ్లేషిస్తోంది...',
  'processingImage': 'మీ పంట చిత్రాన్ని ప్రాసెస్ చేస్తోంది',
  'detectingDisease': 'వ్యాధులను గుర్తిస్తోంది',
  'almostDone': 'దాదాపు అయింది',
  'pleaseWait': 'దయచేసి వేచి ఉండండి...',

  'resultsTitle': 'గుర్తింపు ఫలితాలు',
  'diseaseDetected': 'వ్యాధి గుర్తించబడింది',
  'healthyCrop': 'ఆరోగ్యకరమైన పంట',
  'confidence': 'విశ్వాసం',
  'severity': 'తీవ్రత',
  'detectedOn': 'గుర్తించబడింది',
  'viewTreatment': 'చికిత్స చూడండి',
  'scanAnother': 'మరొకటి స్కాన్ చేయండి',

  'historyTitle': 'స్కాన్ చరిత్ర',
  'allScans': 'అన్ని స్కాన్‌లు',
  'diseased': 'వ్యాధిగ్రస్తమైన',
  'healthy': 'ఆరోగ్యకరమైన',
  'filterBy': 'ఫిల్టర్ చేయండి',
  'clearHistory': 'చరిత్రను క్లియర్ చేయండి',
  'deleteConfirm': 'మీరు ఖచ్చితంగా ఈ స్కాన్‌ను తొలగించాలనుకుంటున్నారా?',
  'clearAllConfirm': 'మీరు ఖచ్చితంగా మొత్తం చరిత్రను క్లియర్ చేయాలనుకుంటున్నారా?',

  'profileTitle': 'ప్రొఫైల్',
  'settings': 'సెట్టింగ్‌లు',
  'language': 'భాష',
  'selectLanguage': 'భాషను ఎంచుకోండి',

  'ok': 'సరే',
  'cancel': 'రద్దు చేయండి',
  'delete': 'తొలగించు',
  'save': 'సేవ్ చేయండి',

  'scanSaved': 'స్కాన్ విజయవంతంగా సేవ్ చేయబడింది',
  'scanDeleted': 'స్కాన్ తొలగించబడింది',
  'historyCleared': 'చరిత్ర క్లియర్ చేయబడింది',

  'tipOfDay': 'నేటి చిట్కా',
  'tip1': 'ఉత్తమ ఫలితాల కోసం సహజ కాంతిని ఉపయోగించండి',
};

// Tamil translations
const Map<String, String> _taStrings = {
  'appName': 'க்ராப்கேர்',
  'appTagline': 'AI-இயக்கப்படும் பயிர் நோய் கண்டறிதல்',

  'onboarding1Title': 'உடனடியாக நோய்களைக் கண்டறியுங்கள்',
  'onboarding1Subtitle': 'உங்கள் பயிரின் புகைப்படம் எடுத்து AI மூலம் உடனடி நோய் கண்டறிதல் பெறுங்கள்',
  'onboarding2Title': 'ஆஃப்லைனில் வேலை செய்கிறது',
  'onboarding2Subtitle': 'இணையம் இல்லையா? பிரச்சனை இல்லை! அனைத்து AI செயலாக்கமும் உங்கள் சாதனத்தில் நடக்கும்',
  'onboarding3Title': 'சிகிச்சை ஆலோசனை பெறுங்கள்',
  'onboarding3Subtitle': 'உள்ளூர் சிகிச்சை பரிந்துரைகளைப் பெற்று பயிர் இழப்பைத் தடுக்கவும்',
  'getStarted': 'தொடங்குங்கள்',
  'skip': 'தவிர்',
  'next': 'அடுத்து',

  'homeWelcome': 'மீண்டும் வரவேற்கிறோம்!',
  'homeSubtitle': 'AI மூலம் உங்கள் பயிர்களைப் பாதுகாக்கவும்',
  'scanNow': 'பயிர் ஸ்கேன் செய்யுங்கள்',
  'recentScans': 'சமீபத்திய ஸ்கேன்கள்',
  'viewAll': 'அனைத்தையும் காண்க',
  'noRecentScans': 'இன்னும் ஸ்கேன்கள் இல்லை',
  'startFirstScan': 'நோய்களைக் கண்டறிய உங்கள் முதல் ஸ்கேனைத் தொடங்குங்கள்',

  'totalScans': 'மொத்த ஸ்கேன்கள்',
  'diseasesDetected': 'நோய்கள் கண்டறியப்பட்டன',
  'healthyScans': 'ஆரோக்கியமான பயிர்கள்',

  'cameraTitle': 'பயிர் படம் எடுக்கவும்',
  'cameraInstruction': 'பாதிக்கப்பட்ட இலையை சட்டத்தில் வைக்கவும்',
  'capturePhoto': 'படம் எடு',
  'retake': 'மீண்டும் எடு',
  'camera': 'கேமரா',
  'gallery': 'கேலரி',
  'captureGuidelines': 'கேப்சர் வழிகாட்டுதல்கள்',

  'analyzing': 'படத்தை பகுப்பாய்வு செய்கிறது...',
  'processingImage': 'உங்கள் பயிர் படத்தை செயலாக்குகிறது',
  'detectingDisease': 'நோய்களைக் கண்டறிகிறது',
  'almostDone': 'கிட்டத்தட்ட முடிந்தது',
  'pleaseWait': 'தயவுசெய்து காத்திருங்கள்...',

  'resultsTitle': 'கண்டறிதல் முடிவுகள்',
  'diseaseDetected': 'நோய் கண்டறியப்பட்டது',
  'healthyCrop': 'ஆரோக்கியமான பயிர்',
  'confidence': 'நம்பிக்கை',
  'severity': 'தீவிரம்',
  'detectedOn': 'கண்டறியப்பட்டது',
  'viewTreatment': 'சிகிச்சை காண்க',
  'scanAnother': 'மற்றொன்று ஸ்கேன் செய்க',

  'historyTitle': 'ஸ்கேன் வரலாறு',
  'allScans': 'அனைத்து ஸ்கேன்கள்',
  'diseased': 'நோயுற்ற',
  'healthy': 'ஆரோக்கியமான',
  'filterBy': 'வடிகட்டு',
  'clearHistory': 'வரலாற்றை அழி',
  'deleteConfirm': 'இந்த ஸ்கேனை நிச்சயமாக நீக்க வேண்டுமா?',
  'clearAllConfirm': 'முழு வரலாற்றையும் நிச்சயமாக அழிக்க வேண்டுமா?',

  'profileTitle': 'சுயவிவரம்',
  'settings': 'அமைப்புகள்',
  'language': 'மொழி',
  'selectLanguage': 'மொழியைத் தேர்ந்தெடுக்கவும்',

  'ok': 'சரி',
  'cancel': 'ரத்து செய்',
  'delete': 'நீக்கு',
  'save': 'சேமி',

  'scanSaved': 'ஸ்கேன் வெற்றிகரமாக சேமிக்கப்பட்டது',
  'scanDeleted': 'ஸ்கேன் நீக்கப்பட்டது',
  'historyCleared': 'வரலாறு அழிக்கப்பட்டது',

  'tipOfDay': 'இன்றைய குறிப்பு',
  'tip1': 'சிறந்த முடிவுகளுக்கு இயற்கை ஒளியைப் பயன்படுத்தவும்',
};

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'hi', 'mr', 'te', 'ta'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}