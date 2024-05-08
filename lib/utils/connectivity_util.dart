import 'package:connectivity/connectivity.dart';

class ConnectivityUtil {
  static Future<bool> isDeviceConnected() async {
    final ConnectivityResult connectivityResult =
        await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
