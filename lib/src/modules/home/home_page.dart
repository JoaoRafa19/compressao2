import 'dart:ui';

import 'package:compressao2/src/modules/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_getit/flutter_getit.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final int files = 0;

  final controller = Injector.get<HomeController>();
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
                  Watch(
                    (_) => Text(
                      controller.messages.value ?? "",
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.black,
                        fontStyle: FontStyle.normal,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  Watch((context) {
                    return CircularProgressIndicator(
                      strokeWidth: 5,
                      value: controller.sendProgress.value,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  });

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      controller.init();
    });
    controller.images.listen(context, () {
      setState(() {});
    });
    controller.erros.listen(context, () {
      if (controller.erros.value != null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("${controller.erros.value}")));
      }
    });
    controller.loading.listen(context, () {
      if (controller.loading.value) {
        Overlay.of(context).insert(overlay);
      } else {
        if (overlay.mounted) {
          overlay.remove();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final sizeOf = MediaQuery.sizeOf(context);
    return OrientationBuilder(builder: (context, orientation) {
      if (orientation == Orientation.landscape) {
        return Container();
      }
      return Scaffold(
        appBar: AppBar(
          toolbarHeight: 10,
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.black,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showMaterialBanner(
                MaterialBanner(
                    content: const Text(
                      "1.1.0+5\nPatch 7",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context)
                                .clearMaterialBanners();
                          },
                          child: const Text("Fechar")),
                    ]),
              );
            },
          ),
        ),
        drawer: const Drawer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [Text("1.1.0+5"), Text("Patch 7")],
          ),
        ),
        body: Align(
          alignment: Alignment.topCenter,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 1),
            padding: const EdgeInsets.all(40),
            width: sizeOf.width * .9,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              border: Border(
                  top: BorderSide(), left: BorderSide(), right: BorderSide()),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                    ),
                    itemCount: controller.images.value?.length,
                    itemBuilder: (context, index) {
                      if (controller.images.value != null) {
                        final imageList = Uint8List.fromList(
                            controller.images.value![index].base64Image);
                        return Card(
                          child: Container(
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                fit: BoxFit.cover,
                                image: MemoryImage(
                                  imageList,
                                ),
                              )),
                              child: SizedBox.expand(
                                child: Stack(
                                  children: [
                                    Visibility(
                                      visible: controller.images.value?[index]
                                              .isSelected ==
                                          true,
                                      child: Align(
                                          alignment: Alignment.topLeft,
                                          child: IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              await showAdaptiveDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog.adaptive(
                                                        backgroundColor:
                                                            Colors.white,
                                                        shadowColor:
                                                            Colors.white,
                                                        actionsAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        alignment:
                                                            Alignment.center,
                                                        content: const Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical:
                                                                      8.0),
                                                          child: Text.rich(
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(),
                                                            TextSpan(children: [
                                                              TextSpan(
                                                                  text:
                                                                      "Tem certeza que deseja excluir essa foto?\n"),
                                                              TextSpan(
                                                                  text:
                                                                      "Ela será removida permanentemente.")
                                                            ]),
                                                          ),
                                                        ),
                                                        actions: [
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: SizedBox(
                                                                  height: 48,
                                                                  child:
                                                                      ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                            shape:
                                                                                const RoundedRectangleBorder()),
                                                                    onPressed:
                                                                        () {
                                                                      controller.removeImage(controller
                                                                          .images
                                                                          .value?[index]);
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child: const Text(
                                                                        "Sim"),
                                                                  ),
                                                                ),
                                                              ),
                                                              Expanded(
                                                                child: SizedBox(
                                                                  height: 48,
                                                                  child: OutlinedButton(
                                                                      style: ElevatedButton.styleFrom(shape: const RoundedRectangleBorder()),
                                                                      onPressed: () {
                                                                        Navigator.of(context)
                                                                            .pop();
                                                                      },
                                                                      child: const Text("Não")),
                                                                ),
                                                              )
                                                            ],
                                                          )
                                                        ]);
                                                  });
                                            },
                                          )),
                                    ),
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Checkbox(
                                        onChanged: (val) {
                                          if (controller.images.value?[index] !=
                                              null) {
                                            var element = controller
                                                .images.value!
                                                .removeAt(index);
                                            element =
                                                element.copyWith(selected: val);
                                            controller.images.value = [
                                              element,
                                              ...controller.images.value ?? []
                                            ];
                                          }
                                        },
                                        value: controller
                                            .images.value?[index].isSelected,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        );
                      }
                      return const SizedBox.shrink();
                    },
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            if (controller.images.value
                                    ?.where((e) => e.isSelected == true)
                                    .isEmpty ==
                                true) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                      content: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.photo,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Text("Nenhuma imagem selecionada"),
                                ],
                              )));
                            }
                            await controller.sendImages();
                          },
                          child: const Text(
                            'ENVIAR',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            await Navigator.of(context).pushNamed('/camera');
                            await controller.init();
                          },
                          child: const Text(
                            'CAPTURA',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class DocumentBoxWidget extends StatelessWidget {
  final bool uploaded;
  final Widget icon;
  final String label;
  final int totalFiles;
  final VoidCallback? onTap;

  const DocumentBoxWidget(
      {super.key,
      this.onTap,
      required this.uploaded,
      required this.icon,
      required this.label,
      required this.totalFiles});

  @override
  Widget build(BuildContext context) {
    final totalFilesLabel = totalFiles > 0 ? '($totalFiles)' : '';
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: uploaded ? Colors.orange : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.orangeAccent),
          ),
          child: Column(
            children: [
              Expanded(child: icon),
              Text(
                '$label $totalFilesLabel',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
