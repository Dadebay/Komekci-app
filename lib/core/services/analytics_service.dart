import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  AnalyticsService(this._analytics);
  final FirebaseAnalytics _analytics;

  Future<void> screen(String name) =>
      _analytics.logScreenView(screenName: name);
  Future<void> action(String name, {Map<String, Object>? parameters}) =>
      _analytics.logEvent(name: name, parameters: parameters);
  Future<void> search(String query) =>
      _analytics.logSearch(searchTerm: query.trim());
}
