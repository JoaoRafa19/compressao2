import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:compressao2/src/modules/camera/camera_confirm/camera_confirm_controller.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:signals_flutter/signals_flutter.dart';

class CameraConfirmPage extends StatefulWidget {
  const CameraConfirmPage({super.key});

  @override
  State<CameraConfirmPage> createState() => _CameraConfirmPageState();
}

class _CameraConfirmPageState extends State<CameraConfirmPage> {
  final controller = Injector.get<CameraConfirmController>();

  late OverlayEntry overlay = OverlayEntry(builder: (c) {
    return SizedBox.expand(
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
          child: Container(
            decoration:
                BoxDecoration(color: Colors.grey.shade200.withOpacity(0.01)),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Visibility(
                    visible: controller.errorMessage.value?.isNotEmpty == true,
                    child: Text(
                      controller.errorMessage.value ?? "",
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                        fontStyle: FontStyle.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const CircularProgressIndicator(
                    strokeWidth: 5,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  });

  @override
  initState() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    controller.pathRemoteStorage.listen(context, () {
      if (controller.pathRemoteStorage.value?.isNotEmpty == true) {
        Navigator.of(context).pop();
        Navigator.of(context).pop(controller.pathRemoteStorage.value);
      }
    });
    controller.errorMessage.listen(context, () {
      if (controller.errorMessage.value != null) {
        final message = controller.errorMessage.value;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message ?? '')));
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sizeOf = MediaQuery.sizeOf(context);
    final foto = ModalRoute.of(context)!.settings.arguments as XFile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Page'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: sizeOf.width * .85,
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange),
            ),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  'CONFIRA SUA FOTO',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: sizeOf.width * .5,
                    child: DottedBorder(
                      borderType: BorderType.RRect,
                      strokeWidth: 4,
                      strokeCap: StrokeCap.square,
                      color: Colors.orange,
                      radius: const Radius.circular(16),
                      dashPattern: const [1, 10, 1, 3],
                      child: Image.file(
                        File(foto.path),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('VOLTAR')),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            controller.loading.set(true);
                            Overlay.of(context).insert(overlay);
                            final c = ScaffoldMessenger.of(context);
                            try {
                              final imageBytes = await foto.readAsBytes();
                              final fileName = foto.name;
                              await controller.uploadImage(
                                  imageBytes, fileName);
                            } on Exception catch (e) {
                              log("Erro ao salvar mensagem", error: e);
                              overlay.remove();
                              c.showSnackBar(const SnackBar(
                                  content: Text("Erro ao salvar a forto!")));
                            }

                            overlay.remove();
                            controller.loading.set(false);
                          },
                          child: const Text('SALVAR'),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
