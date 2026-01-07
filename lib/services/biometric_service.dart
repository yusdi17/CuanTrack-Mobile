import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  // 1. Cek apakah HP support fingerprint?
  Future<bool> isBiometricAvailable() async {
    try {
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint("Error checking biometric: $e");
      return false;
    }
  }

  // 2. Tampilkan Dialog Sidik Jari
  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Scan sidik jari untuk masuk', 
        options: const AuthenticationOptions(
          stickyAuth: true, 
          biometricOnly: true, 
        ),
      );
    } on PlatformException catch (e) {
      debugPrint("Error authenticating: $e");
      return false;
    }
  }
}