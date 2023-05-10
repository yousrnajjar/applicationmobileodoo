import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartpay/api/auth/session.dart';

class SessionNotifier extends StateNotifier<Session> {
  SessionNotifier() : super(Session("", "", ""));

  void setSession(Session newSession) {
    state = newSession;
  }
}

final sessionProvider = StateNotifierProvider<SessionNotifier, Session>(
  (ref) => SessionNotifier(),
);
