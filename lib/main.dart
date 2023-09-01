import 'dart:async';
import 'dart:io';

import 'package:esara/application/core/blocs/login/login_bloc.dart';
import 'package:esara/application/core/blocs/network/network_bloc.dart';
import 'package:esara/application/core/blocs/patient/patient_bloc.dart';
import 'package:esara/application/core/blocs/profile/profile_bloc.dart';
import 'package:esara/application/core/screens/home/home_page_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'application/core/screens/login/login_screen.dart';
import 'application/core/utils/theme/TAppTheme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory());

  runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => NetworkBloc(),
      ),
      BlocProvider(
        create: (context) => LoginBloc(),
      ),
      BlocProvider(
        create: (context) => ProfileBloc(),
      ),
      BlocProvider(
        create: (context) => PatientBloc(),
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _createFolderInAppDocDir('audio');
    _createFolderInAppDocDir('video');
  }

  Future<String> _createFolderInAppDocDir(String folderName) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory appDocDirFolder =
        Directory('${appDocDir.path}/esara/$folderName/');

    if (await appDocDirFolder.exists()) {
      return appDocDirFolder.path;
    } else {
      final Directory appDocDirNewFolder =
          await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'e-sara',
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}
