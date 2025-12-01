import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import '../../../routes/app_routes.dart';
import '../../../services/storage_service.dart';
import '../../../widgets/app_background.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    // Remove native splash after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FlutterNativeSplash.remove();
    });
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(Duration(seconds: 2));

    final storage = Get.find<StorageService>();
    final agent = storage.getAgent();

    if (agent != null) {
      // User is logged in, go to home
      Get.offNamed(AppRoutes.home);
    } else {
      // User is not logged in, go to login
      Get.offNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.25;

    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Image.asset(
            'assets/images/logo.png',
            width: logoSize,
            height: logoSize,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
