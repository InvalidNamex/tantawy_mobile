import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  final Connectivity _connectivity = Connectivity();
  final RxBool isConnected = true.obs;

  Future<ConnectivityService> init() async {
    await _checkConnectivity();
    _connectivity.onConnectivityChanged.listen((result) {
      isConnected.value = result.first != ConnectivityResult.none;
    });
    return this;
  }

  Future<void> _checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    isConnected.value = result.first != ConnectivityResult.none;
  }

  Future<bool> checkConnection() async {
    await _checkConnectivity();
    return isConnected.value;
  }
}
