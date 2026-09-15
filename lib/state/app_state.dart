import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App state: every design variable keyed by name. Bound props read this map
/// (via the screen's _ctx); actions write it through [AppStateNotifier.setVar].
class AppStateNotifier extends Notifier<Map<String, dynamic>> {
  static const List<String> _persisted = <String>['onboardingSeen'];
  static const List<String> _secured = <String>['authToken'];
  static final FlutterSecureStorage _secureStore = FlutterSecureStorage();
  @override
  Map<String, dynamic> build() {
    _hydrate();
    return <String, dynamic>{
      'onboardPage': 0,
      'signupName': '',
      'signupEmail': '',
      'signupPhone': '',
      'signupPassword': '',
      'signupConfirmPassword': '',
      'signupAgreeTerms': false,
      'signupLoading': false,
      'signupError': '',
      'loginEmail': '',
      'loginPassword': '',
      'loginLoading': false,
      'loginError': '',
      'otpCode': '',
      'otpLoading': false,
      'otpError': '',
      'otpResendLoading': false,
      'otpResent': false,
      'forgotEmail': '',
      'forgotLoading': false,
      'forgotSent': false,
      'marketTab': 0,
      'chartRange': '1H',
      'buyAmount': 0,
      'buyLoading': false,
      'sellAmount': 0,
      'sellLoading': false,
      'depositAmount': 0,
      'depositLoading': false,
      'withdrawAmount': 0,
      'withdrawLoading': false,
      'sendAddress': '',
      'sendCryptoAmount': '',
      'sendNote': '',
      'sendLoading': false,
      'searchQuery': '',
      'spinLoading': false,
      'onboardingSeen': false,
      'authToken': '',
      'currentUser': {
        'id': 'u_demo01',
        'name': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '+1 555 010 4821',
      },
      'pendingAuthEmail': '',
      'trendingCoins': [
        {
          'id': 'btc',
          'symbol': 'BTC',
          'name': 'Bitcoin',
          'color': '#F7931A',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/btc.png',
          'price': 98509.75,
          'change': 9.77,
          'up': true,
        },
        {
          'id': 'eth',
          'symbol': 'ETH',
          'name': 'Ethereum',
          'color': '#627EEA',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/eth.png',
          'price': 3421.5,
          'change': 3.42,
          'up': true,
        },
        {
          'id': 'band',
          'symbol': 'BAND',
          'name': 'Band Protocol',
          'color': '#516AFF',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/band.png',
          'price': 1.28,
          'change': -2.15,
          'up': false,
        },
        {
          'id': 'ada',
          'symbol': 'ADA',
          'name': 'Cardano',
          'color': '#0033AD',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/ada.png',
          'price': 0.62,
          'change': 4.87,
          'up': true,
        },
        {
          'id': 'trx',
          'symbol': 'TRX',
          'name': 'TRON',
          'color': '#EB0029',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/trx.png',
          'price': 0.134,
          'change': -1.02,
          'up': false,
        },
        {
          'id': 'usdt',
          'symbol': 'USDT',
          'name': 'Tether',
          'color': '#26A17B',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/usdt.png',
          'price': 1,
          'change': 0.01,
          'up': true,
        },
        {
          'id': 'doge',
          'symbol': 'DOGE',
          'name': 'Dogecoin',
          'color': '#C2A633',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/doge.png',
          'price': 0.158,
          'change': 6.34,
          'up': true,
        },
        {
          'id': 'bnb',
          'symbol': 'BNB',
          'name': 'BNB',
          'color': '#F3BA2F',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/bnb.png',
          'price': 612.4,
          'change': -0.87,
          'up': false,
        },
      ],
      'portfolioHoldings': [
        {
          'id': 'eth',
          'symbol': 'ETH',
          'name': 'Ethereum',
          'color': '#627EEA',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/eth.png',
          'qty': '1.245000',
          'price': 3421.5,
          'change': 3.42,
          'up': true,
        },
        {
          'id': 'ada',
          'symbol': 'ADA',
          'name': 'Cardano',
          'color': '#0033AD',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/ada.png',
          'qty': '1500.000000',
          'price': 0.62,
          'change': 4.87,
          'up': true,
        },
        {
          'id': 'trx',
          'symbol': 'TRX',
          'name': 'TRON',
          'color': '#EB0029',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/trx.png',
          'qty': '8200.000000',
          'price': 0.134,
          'change': -1.02,
          'up': false,
        },
      ],
      'portfolioValue': 6288.57,
      'portfolioChangePct': 3.8,
      'referralCount': 12,
      'couponsWon': 6,
      'hideBalance': false,
      'portfolioInvested': '5800.00',
      'portfolioAvailable': '1250.40',
      'remainingSpins': 1,
      'referralCode': 'CRYPTO-8K2F',
      'selectedCoin': const <String, dynamic>{},
      'receiveAddress': '34HuwzDnSwxVRNCoyFCpQnRBXV2sVVmGUY',
      'transactions': [
        {
          'id': 't1',
          'coin': 'BTC',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/btc.png',
          'color': '#F7931A',
          'type': 'Buy',
          'amount': '0.0421 BTC',
          'value': 4149.86,
          'date': '2026-09-10',
          'status': 'Completed',
        },
        {
          'id': 't2',
          'coin': 'ETH',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/eth.png',
          'color': '#627EEA',
          'type': 'Sell',
          'amount': '0.5000 ETH',
          'value': 1710.75,
          'date': '2026-09-08',
          'status': 'Completed',
        },
        {
          'id': 't3',
          'coin': 'ADA',
          'icon':
              'https://cdn.jsdelivr.net/gh/spothq/cryptocurrency-icons@master/128/color/ada.png',
          'color': '#0033AD',
          'type': 'Deposit',
          'amount': '500.0000 ADA',
          'value': 310,
          'date': '2026-09-05',
          'status': 'Completed',
        },
      ],
      'notifyPriceAlerts': true,
      'notifyTransactions': true,
      'notifyPromotions': false,
      'biometricEnabled': false,
      'twoFactorEnabled': true,
      'homeBanners': [
        {
          'title': 'Learn how to get started',
          'subtitle': 'Beginner\'s guide to crypto trading',
          'icon': 'help',
        },
        {
          'title': 'Make your first investment',
          'subtitle': 'Start growing your portfolio today',
          'icon': 'chart',
        },
        {
          'title': 'Refer & win crypto',
          'subtitle': 'Invite friends and earn free tokens',
          'icon': 'gift',
        },
        {
          'title': 'Spin & win free tokens',
          'subtitle': 'Try your luck on the daily spin wheel',
          'icon': 'star',
        },
      ],
      'referralQualified': 5,
      'bankAccountName': 'Chase Bank •••• 4821',
    };
  }

  /// Immutably sets [name] to [value] so watching consumers rebuild.
  void setVar(String name, dynamic value) {
    state = <String, dynamic>{...state, name: value};
    if (_persisted.contains(name)) _persist(name, value);
    if (_secured.contains(name)) _persistSecure(name, value);
  }

  /// Merges [patch] into the current state (used by callApi assignments that
  /// spread an object result).
  void mergeState(Map<String, dynamic> patch) {
    state = <String, dynamic>{...state, ...patch};
  }

  // ── Typed writes ────────────────────────────────────────────────────────
  // One setter per design variable: `appState.passcode = v` instead of
  // `setVar('passcode', v)`, so a misspelled variable is a compile error.
  // Values stay dynamic — an API response assigns untyped JSON, and the
  // matching getter in [AppStateVars] already coerces on the way out.
  set onboardPage(dynamic v) => setVar('onboardPage', v);
  set signupName(dynamic v) => setVar('signupName', v);
  set signupEmail(dynamic v) => setVar('signupEmail', v);
  set signupPhone(dynamic v) => setVar('signupPhone', v);
  set signupPassword(dynamic v) => setVar('signupPassword', v);
  set signupConfirmPassword(dynamic v) => setVar('signupConfirmPassword', v);
  set signupAgreeTerms(dynamic v) => setVar('signupAgreeTerms', v);
  set signupLoading(dynamic v) => setVar('signupLoading', v);
  set signupError(dynamic v) => setVar('signupError', v);
  set loginEmail(dynamic v) => setVar('loginEmail', v);
  set loginPassword(dynamic v) => setVar('loginPassword', v);
  set loginLoading(dynamic v) => setVar('loginLoading', v);
  set loginError(dynamic v) => setVar('loginError', v);
  set otpCode(dynamic v) => setVar('otpCode', v);
  set otpLoading(dynamic v) => setVar('otpLoading', v);
  set otpError(dynamic v) => setVar('otpError', v);
  set otpResendLoading(dynamic v) => setVar('otpResendLoading', v);
  set otpResent(dynamic v) => setVar('otpResent', v);
  set forgotEmail(dynamic v) => setVar('forgotEmail', v);
  set forgotLoading(dynamic v) => setVar('forgotLoading', v);
  set forgotSent(dynamic v) => setVar('forgotSent', v);
  set marketTab(dynamic v) => setVar('marketTab', v);
  set chartRange(dynamic v) => setVar('chartRange', v);
  set buyAmount(dynamic v) => setVar('buyAmount', v);
  set buyLoading(dynamic v) => setVar('buyLoading', v);
  set sellAmount(dynamic v) => setVar('sellAmount', v);
  set sellLoading(dynamic v) => setVar('sellLoading', v);
  set depositAmount(dynamic v) => setVar('depositAmount', v);
  set depositLoading(dynamic v) => setVar('depositLoading', v);
  set withdrawAmount(dynamic v) => setVar('withdrawAmount', v);
  set withdrawLoading(dynamic v) => setVar('withdrawLoading', v);
  set sendAddress(dynamic v) => setVar('sendAddress', v);
  set sendCryptoAmount(dynamic v) => setVar('sendCryptoAmount', v);
  set sendNote(dynamic v) => setVar('sendNote', v);
  set sendLoading(dynamic v) => setVar('sendLoading', v);
  set searchQuery(dynamic v) => setVar('searchQuery', v);
  set spinLoading(dynamic v) => setVar('spinLoading', v);
  set onboardingSeen(dynamic v) => setVar('onboardingSeen', v);
  set authToken(dynamic v) => setVar('authToken', v);
  set currentUser(dynamic v) => setVar('currentUser', v);
  set pendingAuthEmail(dynamic v) => setVar('pendingAuthEmail', v);
  set trendingCoins(dynamic v) => setVar('trendingCoins', v);
  set portfolioHoldings(dynamic v) => setVar('portfolioHoldings', v);
  set portfolioValue(dynamic v) => setVar('portfolioValue', v);
  set portfolioChangePct(dynamic v) => setVar('portfolioChangePct', v);
  set referralCount(dynamic v) => setVar('referralCount', v);
  set couponsWon(dynamic v) => setVar('couponsWon', v);
  set hideBalance(dynamic v) => setVar('hideBalance', v);
  set portfolioInvested(dynamic v) => setVar('portfolioInvested', v);
  set portfolioAvailable(dynamic v) => setVar('portfolioAvailable', v);
  set remainingSpins(dynamic v) => setVar('remainingSpins', v);
  set referralCode(dynamic v) => setVar('referralCode', v);
  set selectedCoin(dynamic v) => setVar('selectedCoin', v);
  set receiveAddress(dynamic v) => setVar('receiveAddress', v);
  set transactions(dynamic v) => setVar('transactions', v);
  set notifyPriceAlerts(dynamic v) => setVar('notifyPriceAlerts', v);
  set notifyTransactions(dynamic v) => setVar('notifyTransactions', v);
  set notifyPromotions(dynamic v) => setVar('notifyPromotions', v);
  set biometricEnabled(dynamic v) => setVar('biometricEnabled', v);
  set twoFactorEnabled(dynamic v) => setVar('twoFactorEnabled', v);
  set homeBanners(dynamic v) => setVar('homeBanners', v);
  set referralQualified(dynamic v) => setVar('referralQualified', v);
  set bankAccountName(dynamic v) => setVar('bankAccountName', v);

  /// Loads persisted variables from storage, then merges them over the seeded
  /// defaults so watching consumers rebuild once storage is ready.
  Future<void> _hydrate() async {
    final loaded = <String, dynamic>{};
    final prefs = await SharedPreferences.getInstance();
    for (final key in _persisted) {
      final raw = prefs.getString('appstate.$key');
      if (raw != null) {
        try {
          loaded[key] = jsonDecode(raw);
        } catch (_) {}
      }
    }
    for (final key in _secured) {
      final raw = await _secureStore.read(key: 'appstate.$key');
      if (raw != null) {
        try {
          loaded[key] = jsonDecode(raw);
        } catch (_) {}
      }
    }
    if (loaded.isNotEmpty) state = <String, dynamic>{...state, ...loaded};
  }

  Future<void> _persist(String name, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appstate.$name', jsonEncode(value));
  }

  Future<void> _persistSecure(String name, dynamic value) async {
    await _secureStore.write(key: 'appstate.$name', value: jsonEncode(value));
  }
}

final appStateProvider =
    NotifierProvider<AppStateNotifier, Map<String, dynamic>>(
      AppStateNotifier.new,
    );

/// The app's state as the generated screens see it — the very
/// `Map<String, dynamic>` the store holds, named so a `_build` method's
/// signature reads `AppStateView state` instead of `Map<String, dynamic>`.
typedef AppStateView = Map<String, dynamic>;

/// Typed, null-safe reads of the state map: `state.balance` instead of
/// `state['balance'] as num`. One getter per design variable, named after it.
/// Reads only — writes go through the matching setter on
/// [AppStateNotifier] (`appState.balance = v`) or, by name, through
/// [AppStateNotifier.setVar].
extension AppStateVars on Map<String, dynamic> {
  num get onboardPage =>
      this['onboardPage'] is num ? this['onboardPage'] as num : 0;
  String get signupName =>
      this['signupName'] is String ? this['signupName'] as String : '';
  String get signupEmail =>
      this['signupEmail'] is String ? this['signupEmail'] as String : '';
  String get signupPhone =>
      this['signupPhone'] is String ? this['signupPhone'] as String : '';
  String get signupPassword =>
      this['signupPassword'] is String ? this['signupPassword'] as String : '';
  String get signupConfirmPassword => this['signupConfirmPassword'] is String
      ? this['signupConfirmPassword'] as String
      : '';
  bool get signupAgreeTerms => this['signupAgreeTerms'] == true;
  bool get signupLoading => this['signupLoading'] == true;
  String get signupError =>
      this['signupError'] is String ? this['signupError'] as String : '';
  String get loginEmail =>
      this['loginEmail'] is String ? this['loginEmail'] as String : '';
  String get loginPassword =>
      this['loginPassword'] is String ? this['loginPassword'] as String : '';
  bool get loginLoading => this['loginLoading'] == true;
  String get loginError =>
      this['loginError'] is String ? this['loginError'] as String : '';
  String get otpCode =>
      this['otpCode'] is String ? this['otpCode'] as String : '';
  bool get otpLoading => this['otpLoading'] == true;
  String get otpError =>
      this['otpError'] is String ? this['otpError'] as String : '';
  bool get otpResendLoading => this['otpResendLoading'] == true;
  bool get otpResent => this['otpResent'] == true;
  String get forgotEmail =>
      this['forgotEmail'] is String ? this['forgotEmail'] as String : '';
  bool get forgotLoading => this['forgotLoading'] == true;
  bool get forgotSent => this['forgotSent'] == true;
  num get marketTab => this['marketTab'] is num ? this['marketTab'] as num : 0;
  String get chartRange =>
      this['chartRange'] is String ? this['chartRange'] as String : '';
  String get buyAmount =>
      this['buyAmount'] is String ? this['buyAmount'] as String : '';
  bool get buyLoading => this['buyLoading'] == true;
  String get sellAmount =>
      this['sellAmount'] is String ? this['sellAmount'] as String : '';
  bool get sellLoading => this['sellLoading'] == true;
  String get depositAmount =>
      this['depositAmount'] is String ? this['depositAmount'] as String : '';
  bool get depositLoading => this['depositLoading'] == true;
  String get withdrawAmount =>
      this['withdrawAmount'] is String ? this['withdrawAmount'] as String : '';
  bool get withdrawLoading => this['withdrawLoading'] == true;
  String get sendAddress =>
      this['sendAddress'] is String ? this['sendAddress'] as String : '';
  String get sendCryptoAmount => this['sendCryptoAmount'] is String
      ? this['sendCryptoAmount'] as String
      : '';
  String get sendNote =>
      this['sendNote'] is String ? this['sendNote'] as String : '';
  bool get sendLoading => this['sendLoading'] == true;
  String get searchQuery =>
      this['searchQuery'] is String ? this['searchQuery'] as String : '';
  bool get spinLoading => this['spinLoading'] == true;
  bool get onboardingSeen => this['onboardingSeen'] == true;
  String get authToken =>
      this['authToken'] is String ? this['authToken'] as String : '';
  dynamic get currentUser => this['currentUser'];
  String get pendingAuthEmail => this['pendingAuthEmail'] is String
      ? this['pendingAuthEmail'] as String
      : '';
  List<dynamic> get trendingCoins => this['trendingCoins'] is List
      ? this['trendingCoins'] as List<dynamic>
      : const <dynamic>[];
  List<dynamic> get portfolioHoldings => this['portfolioHoldings'] is List
      ? this['portfolioHoldings'] as List<dynamic>
      : const <dynamic>[];
  num get portfolioValue =>
      this['portfolioValue'] is num ? this['portfolioValue'] as num : 0;
  num get portfolioChangePct =>
      this['portfolioChangePct'] is num ? this['portfolioChangePct'] as num : 0;
  num get referralCount =>
      this['referralCount'] is num ? this['referralCount'] as num : 0;
  num get couponsWon =>
      this['couponsWon'] is num ? this['couponsWon'] as num : 0;
  bool get hideBalance => this['hideBalance'] == true;
  num get portfolioInvested =>
      this['portfolioInvested'] is num ? this['portfolioInvested'] as num : 0;
  num get portfolioAvailable =>
      this['portfolioAvailable'] is num ? this['portfolioAvailable'] as num : 0;
  num get remainingSpins =>
      this['remainingSpins'] is num ? this['remainingSpins'] as num : 0;
  String get referralCode =>
      this['referralCode'] is String ? this['referralCode'] as String : '';
  dynamic get selectedCoin => this['selectedCoin'];
  String get receiveAddress =>
      this['receiveAddress'] is String ? this['receiveAddress'] as String : '';
  List<dynamic> get transactions => this['transactions'] is List
      ? this['transactions'] as List<dynamic>
      : const <dynamic>[];
  bool get notifyPriceAlerts => this['notifyPriceAlerts'] == true;
  bool get notifyTransactions => this['notifyTransactions'] == true;
  bool get notifyPromotions => this['notifyPromotions'] == true;
  bool get biometricEnabled => this['biometricEnabled'] == true;
  bool get twoFactorEnabled => this['twoFactorEnabled'] == true;
  List<dynamic> get homeBanners => this['homeBanners'] is List
      ? this['homeBanners'] as List<dynamic>
      : const <dynamic>[];
  num get referralQualified =>
      this['referralQualified'] is num ? this['referralQualified'] as num : 0;
  String get bankAccountName => this['bankAccountName'] is String
      ? this['bankAccountName'] as String
      : '';
}
