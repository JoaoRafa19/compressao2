import 'dart:async';
import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:compressao2/src/core/app_binding.dart';
import 'package:compressao2/src/modules/camera/camera_module.dart';
import 'package:compressao2/src/modules/home/home_module.dart';
import 'package:compressao2/src/pages/splash_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getit/flutter_getit.dart';

late List<CameraDescription> _cameras;

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    _cameras = await availableCameras();
    runApp(const MainModule());
  }, (error, stack) {
    log('Erro não tratado', error: error, stackTrace: stack);
    throw error;
  });
}

class MainModule extends StatelessWidget {
  const MainModule({super.key});

  @override
  Widget build(BuildContext context) {
    return Main(
      binding: MainBinding(),
      pageBuilders: [
        FlutterGetItPageBuilder(page: (_) => const SplashPage(), path: '/')
      ],
      didStart: () {
        FlutterGetItBindingRegister.registerPermanentBinding(
          'CAMERAS',
          [
            Bind.lazySingleton((i) => _cameras),
          ],
        );
      },
      modules: [
        HomeModule(),
        CameraModule(),
      ],
    );
  }
}

class Main extends StatelessWidget {
  final List<FlutterGetItPageRouter>? pages;
  final List<FlutterGetItPageBuilder>? pageBuilders;
  final ApplicationBindings? binding;
  final List<FlutterGetItModule>? modules;
  final VoidCallback? didStart;

  const Main(
      {super.key,
      this.pages,
      this.pageBuilders,
      this.binding,
      this.modules,
      this.didStart});

  @override
  Widget build(BuildContext context) {
    return FlutterGetIt(
        debugMode: kDebugMode,
        bindings: binding,
        pages: [...pages ?? [], ...pageBuilders ?? []],
        modules: [...modules ?? []],
        builder: (context, routes, flutterGetItNavObserver) {
          if (didStart != null) {
            didStart?.call();
          }
          return MaterialApp(
            title: 'POC Compressão',
            routes: routes,
            initialRoute: '/',
            navigatorObservers: [
              flutterGetItNavObserver,
            ],
          );
        });
  }
}
