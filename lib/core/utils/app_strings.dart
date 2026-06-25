class AppStrings {
  static String currentLang = 'en';

  static final Map<String, Map<String, String>> data = {
    'en': {
      'welcome': 'Welcome to',
      'username': 'Username',
      'password': 'Password',
      'remember': 'Remember Me',
      'signin': 'SIGN IN',
    },
    'hi': {
      'welcome': 'स्वागत है',
      'username': 'उपयोगकर्ता नाम',
      'password': 'पासवर्ड',
      'remember': 'मुझे याद रखें',
      'signin': 'साइन इन',
    },
    'te': {
      'welcome': 'స్వాగతం',
      'username': 'వినియోగదారు పేరు',
      'password': 'పాస్‌వర్డ్',
      'remember': 'నన్ను గుర్తుంచుకోండి',
      'signin': 'సైన్ ఇన్',
    },
    'ta': {
      'welcome': 'வரவேற்கிறோம்',
      'username': 'பயனர் பெயர்',
      'password': 'கடவுச்சொல்',
      'remember': 'என்னை நினைவில் கொள்',
      'signin': 'உள்நுழைக',
    },
    'or': {
      'welcome': 'ସ୍ୱାଗତ',
      'username': 'ଉପଯୋଗକର୍ତ୍ତା ନାମ',
      'password': 'ପାସୱାର୍ଡ',
      'remember': 'ମୋତେ ମନେ ରଖ',
      'signin': 'ସାଇନ୍ ଇନ୍',
    },
    'bn': {
      'welcome': 'স্বাগতম',
      'username': 'ব্যবহারকারীর নাম',
      'password': 'পাসওয়ার্ড',
      'remember': 'আমাকে মনে রাখুন',
      'signin': 'সাইন ইন',
    },
    'ml': {
      'welcome': 'സ്വാഗതം',
      'username': 'ഉപയോക്തൃനാമം',
      'password': 'പാസ്‌വേഡ്',
      'remember': 'എന്നെ ഓർമ്മിക്കുക',
      'signin': 'സൈൻ ഇൻ',
    },
  };

  static String get(String key) {
    return data[currentLang]?[key] ?? key;
  }
}