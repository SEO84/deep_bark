import 'package:flutter/foundation.dart';
import '../lib/services/auth_service.dart';

class FakeAuthService extends AuthService {
  @override
  bool get isLoggedIn => false;

  @override
  String get userId => '0';

  @override
  String get userEmail => 'test@example.com';

  @override
  String get userName => 'Test User';

  @override
  bool get notificationsEnabled => true;

  @override
  String get profileImageUrl => '';

  @override
  String get loginProvider => '';

  @override
  Future<bool> login(String email, String password) async {
    return true;
  }

  @override
  Future<bool> signup(String email, String password, String username) async {
    return true;
  }

  @override
  Future<bool> logout() async {
    return true;
  }

  @override
  Future<void> checkCurrentUser() async {}
} 