import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthProvider with ChangeNotifier {
  final Box _authBox = Hive.box('auth');
  final _secureStorage = const FlutterSecureStorage();
  bool _isAuthenticated = false;

  AuthProvider() {
    _checkAuth();
  }

  bool get isAuthenticated => _isAuthenticated;

  Future<void> _checkAuth() async {
    final pin = await _secureStorage.read(key: 'parentalPin');
    _isAuthenticated = pin != null && _authBox.get('lastAuthTime') != null;
    notifyListeners();
  }

  Future<bool> login(String pin) async {
    final storedPin = await _secureStorage.read(key: 'parentalPin');

    if (storedPin == null) {
      // First time login, set the PIN
      await _secureStorage.write(key: 'parentalPin', value: pin);
      _authBox.put('lastAuthTime', DateTime.now().toIso8601String());
      _isAuthenticated = true;
      notifyListeners();
      return true;
    } else if (storedPin == pin) {
      // Correct PIN
      _authBox.put('lastAuthTime', DateTime.now().toIso8601String());
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() {
    _authBox.delete('lastAuthTime');
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> changePin(String oldPin, String newPin) async {
    final storedPin = await _secureStorage.read(key: 'parentalPin');

    if (storedPin == oldPin) {
      await _secureStorage.write(key: 'parentalPin', value: newPin);
      return true;
    }

    return false;
  }
}
