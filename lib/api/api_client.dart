import 'package:dio/dio.dart';
// Re-exported too (not just imported): the code generator's callApi
// emission needs `Options` in scope to send per-call headers, and every
// screen that calls an API already imports this file — re-exporting avoids
// adding a second dio import to every one of them.
export 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/app_state.dart';

// Base URLs — override at build time via --dart-define / --dart-define-from-file
// (the exported repo ships env/dev.json, env/staging.json, env/prod.json).
const String walletBaseUrl = String.fromEnvironment(
  'WALLET_BASE_URL',
  defaultValue: 'https://api.crypto-trading-app.example.com/v1',
);
const String authBaseUrl = String.fromEnvironment(
  'AUTH_BASE_URL',
  defaultValue: 'https://api.crypto-trading-app.example.com/v1',
);

class DesignApiClients {
  final ProviderContainer
  _container; // used by request-time interceptors to read app state
  DesignApiClients(this._container);

  late final Dio wallet = _wallet();
  Dio _wallet() {
    final dio = Dio(
      BaseOptions(baseUrl: walletBaseUrl, headers: <String, dynamic>{}),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _container.read(appStateProvider)['authToken'];
          if (token != null && token.toString().isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
    return dio;
  }

  late final Dio auth = _auth();
  Dio _auth() {
    final dio = Dio(
      BaseOptions(baseUrl: authBaseUrl, headers: <String, dynamic>{}),
    );
    return dio;
  }

  // ── Endpoint catalog: every API this app calls, one method each. ──
  //
  // Every method returns the raw Dio Response — the decoded JSON body is
  // `response.data`. `query:` adds extra query parameters to any call;
  // an omitted optional parameter is left out of the request entirely
  // (apiBody drops null values), it is not sent as null.

  /// POST /orders/buy — Buy coin (group: Wallet)
  ///
  /// - [coinId] body field `coinId`
  /// - [amount] body field `amount`
  Future<Response<dynamic>> walletBuyCoin({
    Object? coinId,
    Object? amount,
    Map<String, dynamic>? query,
  }) => wallet.request<dynamic>(
    '/orders/buy',
    data: apiBody(<String, dynamic>{'coinId': coinId, 'amount': amount}),
    queryParameters: query,
    options: Options(method: 'POST'),
  );

  /// POST /orders/sell — Sell coin (group: Wallet)
  ///
  /// - [coinId] body field `coinId`
  /// - [amount] body field `amount`
  Future<Response<dynamic>> walletSellCoin({
    Object? coinId,
    Object? amount,
    Map<String, dynamic>? query,
  }) => wallet.request<dynamic>(
    '/orders/sell',
    data: apiBody(<String, dynamic>{'coinId': coinId, 'amount': amount}),
    queryParameters: query,
    options: Options(method: 'POST'),
  );

  /// POST /wallet/deposit — Deposit funds (group: Wallet)
  ///
  /// - [amount] body field `amount`
  ///
  /// Response fields: `newBalance`.
  Future<Response<dynamic>> walletDepositFunds({
    Object? amount,
    Map<String, dynamic>? query,
  }) => wallet.request<dynamic>(
    '/wallet/deposit',
    data: apiBody(<String, dynamic>{'amount': amount}),
    queryParameters: query,
    options: Options(method: 'POST'),
  );

  /// POST /wallet/withdraw — Withdraw funds (group: Wallet)
  ///
  /// - [amount] body field `amount`
  ///
  /// Response fields: `newBalance`.
  Future<Response<dynamic>> walletWithdrawFunds({
    Object? amount,
    Map<String, dynamic>? query,
  }) => wallet.request<dynamic>(
    '/wallet/withdraw',
    data: apiBody(<String, dynamic>{'amount': amount}),
    queryParameters: query,
    options: Options(method: 'POST'),
  );

  /// POST /wallet/send — Send crypto (group: Wallet)
  ///
  /// - [coinId] body field `coinId`
  /// - [address] body field `address`
  /// - [amount] body field `amount`
  /// - [note] body field `note`
  Future<Response<dynamic>> walletSendCrypto({
    Object? coinId,
    Object? address,
    Object? amount,
    Object? note,
    Map<String, dynamic>? query,
  }) => wallet.request<dynamic>(
    '/wallet/send',
    data: apiBody(<String, dynamic>{
      'coinId': coinId,
      'address': address,
      'amount': amount,
      'note': note,
    }),
    queryParameters: query,
    options: Options(method: 'POST'),
  );

  /// GET /wallet/receive-address — Get receive address (group: Wallet)
  ///
  /// - [coinId] query `coinId`
  /// - [data] request body — this endpoint declares no body template, so it is sent as given.
  ///
  /// Response fields: `address`.
  Future<Response<dynamic>> walletGetReceiveAddress({
    Object? coinId,
    Object? data,
    Map<String, dynamic>? query,
  }) => wallet.request<dynamic>(
    '/wallet/receive-address',
    data: data,
    queryParameters: apiBody(<String, dynamic>{'coinId': coinId, ...?query}),
    options: Options(method: 'GET'),
  );

  /// POST /auth/signup — Sign up (group: Auth)
  ///
  /// - [name] body field `name`
  /// - [email] body field `email`
  /// - [phone] body field `phone`
  /// - [password] body field `password`
  ///
  /// Response fields: `message`.
  Future<Response<dynamic>> authSignUp({
    Object? name,
    Object? email,
    Object? phone,
    Object? password,
    Map<String, dynamic>? query,
  }) => auth.request<dynamic>(
    '/auth/signup',
    data: apiBody(<String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
    }),
    queryParameters: query,
    options: Options(method: 'POST'),
  );

  /// POST /auth/login — Log in (group: Auth)
  ///
  /// - [email] body field `email`
  /// - [password] body field `password`
  ///
  /// Response fields: `token`, `user`.
  Future<Response<dynamic>> authLogIn({
    Object? email,
    Object? password,
    Map<String, dynamic>? query,
  }) => auth.request<dynamic>(
    '/auth/login',
    data: apiBody(<String, dynamic>{'email': email, 'password': password}),
    queryParameters: query,
    options: Options(method: 'POST'),
  );

  /// POST /auth/otp/verify — Verify OTP (group: Auth)
  ///
  /// - [email] body field `email`
  /// - [code] body field `code`
  ///
  /// Response fields: `token`, `user`.
  Future<Response<dynamic>> authVerifyOTP({
    Object? email,
    Object? code,
    Map<String, dynamic>? query,
  }) => auth.request<dynamic>(
    '/auth/otp/verify',
    data: apiBody(<String, dynamic>{'email': email, 'code': code}),
    queryParameters: query,
    options: Options(method: 'POST'),
  );

  /// POST /auth/otp/resend — Resend OTP (group: Auth)
  ///
  /// - [email] body field `email`
  Future<Response<dynamic>> authResendOTP({
    Object? email,
    Map<String, dynamic>? query,
  }) => auth.request<dynamic>(
    '/auth/otp/resend',
    data: apiBody(<String, dynamic>{'email': email}),
    queryParameters: query,
    options: Options(method: 'POST'),
  );

  /// POST /auth/forgot-password — Forgot password (group: Auth)
  ///
  /// - [email] body field `email`
  Future<Response<dynamic>> authForgotPassword({
    Object? email,
    Map<String, dynamic>? query,
  }) => auth.request<dynamic>(
    '/auth/forgot-password',
    data: apiBody(<String, dynamic>{'email': email}),
    queryParameters: query,
    options: Options(method: 'POST'),
  );
}

late final DesignApiClients apiClients;
void initApiClients(ProviderContainer container) =>
    apiClients = DesignApiClients(container);

/// Request-body sanitizer for every generated callApi.
///
/// A body template key whose value resolves to null means "this call has no
/// value for that field" — either the request-body placeholder was left
/// unmapped, or the step deliberately maps it to null (e.g. an optional date
/// filter the user has not set). Real backends distinguish "absent" from
/// "present but empty/null" and reject the latter: IRIS answers an empty
/// fromDate with 'should pass date-YYYYMMDD keyword validation', so an
/// unfiltered transaction search failed outright. Dropping the key is what the
/// hand-written client does, and what the DSL already means.
///
/// Only NULL is dropped. An empty string is a value someone chose to send; a
/// step that wants a field omitted maps it to null.
Map<String, dynamic> apiBody(Map<String, dynamic> body) {
  final out = <String, dynamic>{};
  body.forEach((k, v) {
    if (v != null) out[k] = v;
  });
  return out;
}

/// The message to SHOW for a failed request — what a callApi step's errorVar
/// receives before its onError steps run. (No backticks in this comment: the
/// whole block is a TS template literal upstream, and one would end it.)
///
/// Servers say useful things when they reject a call ('should pass
/// date-YYYYMMDD keyword validation', 'insufficient balance'), and that text
/// arrived in the response body and was thrown away, leaving the app to show a
/// hardcoded 'Something went wrong'. This digs the server's own words out of
/// the response and falls back to a plain description of the transport failure
/// only when there are none.
///
/// Deliberately never returns a raw exception toString(): 'DioException
/// [connection error]: ... uri=https://host/path' is not something to put in
/// front of a person, and it leaks internal URLs.
String apiErrorMessage(Object error) {
  String? fromBody(dynamic body) {
    if (body is String) return body.trim().isEmpty ? null : body.trim();
    if (body is Map) {
      // Checked in order of specificity — a body carrying both a generic
      // 'error' and a human 'message' means the message.
      for (final key in const [
        'message',
        'errorMessage',
        'error_description',
        'description',
        'error',
        'detail',
        'title',
      ]) {
        final v = body[key];
        if (v is String && v.trim().isNotEmpty) return v.trim();
        // Nested one level: { error: { message: '…' } }.
        if (v is Map) {
          final inner = fromBody(v);
          if (inner != null) return inner;
        }
      }
      // A list of validation failures — show the first, which is the one the
      // user has to fix first anyway.
      for (final key in const ['errors', 'messages']) {
        final v = body[key];
        if (v is List && v.isNotEmpty) {
          final first = fromBody(v.first);
          if (first != null) return first;
        }
      }
    }
    return null;
  }

  if (error is DioException) {
    final fromResponse = fromBody(error.response?.data);
    if (fromResponse != null) return fromResponse;
    final status = error.response?.statusCode;
    if (status != null) return 'The server rejected this request ($status).';
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'The request timed out. Please try again.';
      case DioExceptionType.connectionError:
        return 'Could not reach the server. Check your connection and try again.';
      case DioExceptionType.cancel:
        return 'The request was cancelled.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}
