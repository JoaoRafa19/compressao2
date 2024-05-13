import 'package:compressao2/src/core/enviroment.dart';
import 'package:compressao2/src/core/rest_client.dart';
import 'package:compressao2/src/repositories/image_repository.dart';
import 'package:compressao2/src/repositories/image_repository_impl.dart';
import 'package:flutter_getit/flutter_getit.dart';

class MainBinding extends ApplicationBindings {
  @override
  List<Bind<Object>> bindings() => [
        Bind.lazySingleton((i) => RestClient(Env.backendBaseUrl)),
        Bind.lazySingleton<ImageRepository>((i) => ImageRepositoryImpl(i())),
      ];
}
