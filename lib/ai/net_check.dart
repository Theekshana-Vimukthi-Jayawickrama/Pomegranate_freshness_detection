import 'package:connectivity_plus/connectivity_plus.dart';

class NetCheck {
  static Future<bool> hasInternet() async {
    final res = await Connectivity().checkConnectivity();
    return res != ConnectivityResult.none;
  }
}
