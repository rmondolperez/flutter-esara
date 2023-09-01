import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:esara/application/core/constants/colors.dart';
import 'package:esara/application/core/constants/text_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:material_dialogs/material_dialogs.dart';
import 'package:video_player/video_player.dart';
import '../../../../constants/image_string.dart';
import '../../blocs/patient/patient_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../data/repository.dart';
import '../../utils/model/audio_model.dart';
import '../audio/audio_file_widget.dart';
import '../profile/user_profile_screen.dart';
import '../profile/widgets/profile_menu_widget.dart';
import '../sensors/sensors_screen.dart';
import '../video/video_file_screen.dart';
import 'widgets/placeholder_dialog_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var formKey = GlobalKey<FormFieldState>();
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  List<AudioModel> audioModelList = List.empty(growable: true);
  int lastPosition = 0;
  late VideoPlayerController videoPlayerController;

  Future _recordAudio() async {
    if (!isRecorderReady) return;
    await recorder.startRecorder(toFile: 'audio');
  }

  Future _stopAudio() async {
    if (!isRecorderReady) return;
    final path = await recorder.stopRecorder();
    final audioUrl = await _getUrlFolderInAppDocDir('audio');
    await _moveMediaFile(File(path!), audioUrl, '_speech_', 'm4a');
  }

  @override
  void initState() {
    _sms();
    _initRecorder();
    super.initState();
  }

  @override
  Future<void> dispose() async {
    recorder.closeRecorder();
    super.dispose();
  }

  Future _sms() async {
    final status = await Permission.sms.request();
    if (status != PermissionStatus.granted) {
      throw 'Sms permission not granted';
    }
  }

  Future _initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw 'Microphone permission not granted';
    }

    await recorder.openRecorder();

    isRecorderReady = true;
    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  Future<void> _recordVideo(String testName) async {
    try {
      final videoFile =
          await ImagePicker().pickVideo(source: ImageSource.camera);
      if (videoFile == null) return;
      final videoUrl = await _getUrlFolderInAppDocDir('video');
      _moveMediaFile(File(videoFile.path), videoUrl, testName, 'mp4');
    } on PlatformException {}
  }

  Future<String> _getUrlFolderInAppDocDir(String folderName) async {
    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final Directory appDocDirFolder =
        Directory('${appDocDir.path}/esara/$folderName/');
    return appDocDirFolder.path;
  }

  Future<File> _moveMediaFile(File sourceFile, String newPath, String testName,
      String extension) async {
    try {
      String name = await Repository.localStorage.getToken() ?? '';
      name += '_';

      final stat = FileStat.statSync(sourceFile.path);

      return await sourceFile
          .rename('$newPath/esara$testName$name${stat.size}.$extension');
    } on FileSystemException catch (_) {
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }

  Future<List<FileSystemEntity>> _getListMediaFiles(
      String folder, String testName) async {
    final directory = Directory(await _getUrlFolderInAppDocDir(folder));

    String name = await Repository.localStorage.getToken() ?? '';
    name += '_';

    return directory
        .list()
        .where((event) => event.path.contains('_${testName}_$name'))
        .toList();
  }

  Future<FileSystemEntity> _deleteMediaFile(File mediaFileToDelete) async {
    return await mediaFileToDelete.delete();
  }

  String _fileNameCardTitle(String path) {
    final stat = FileStat.statSync(path);
    return '${stat.modified.day}/${stat.modified.month}/${stat.modified.year}';
  }

  String _fileNameCardSubTitle(String path) {
    final stat = FileStat.statSync(path);
    return '${stat.modified.hour}:${stat.modified.minute}:${stat.modified.second}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientBloc, PatientState>(
      builder: (context, state) {
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('eSARA'),
              flexibleSpace: Row(
                children: [
                  Expanded(
                    child: Container(),
                  ),
                ],
              ),
              backgroundColor: tPrimaryColor,
              bottom: TabBar(
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(10), // Creates border
                      color: Colors.greenAccent),
                  tabs: const [
                    Tab(
                      icon: Icon(
                        LineAwesomeIcons.walking,
                        size: 25,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        LineAwesomeIcons.street_view,
                        size: 25,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        LineAwesomeIcons.microphone,
                        size: 25,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        LineAwesomeIcons.hand_pointing_up,
                        size: 25,
                      ),
                    ),
                    Tab(
                      icon: Icon(
                        LineAwesomeIcons.paper__hand_,
                        size: 25,
                      ),
                    )
                  ]),
            ),
            drawer: NavigationDrawer(),
            body: TabBarView(children: [
              Container(
                child: Stack(
                  children: [
                    Positioned(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => PlaceholderDialog(
                                  title: tTextInstTest,
                                  message: tTextGaitTest,
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cerrar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    const CircleBorder()),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(2.0)),
                                backgroundColor:
                                    MaterialStateProperty.all(tPrimaryColor),
                                overlayColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.blue;
                                  }
                                })),
                            child: const Icon(
                              LineAwesomeIcons.question_circle,
                              size: 35.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    BlocBuilder<PatientBloc, PatientState>(
                      builder: (context, state) {
                        if (state is PatientUploadingGaitFile) {
                          return const Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16.0),
                              Text(tInfo10, style: TextStyle(fontSize: 14)),
                            ],
                          ));
                        } else if (state is PatientUploadGaitFileSuccess) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (ctx) => PlaceholderDialog(
                                title: tInfoDialogOption3,
                                message: tTextUploadSuccess,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(tInfo5),
                                  ),
                                ],
                              ),
                            );
                          });
                        } else if (state is PatientGaitFailure) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (ctx) => PlaceholderDialog(
                                title: tInfoDialogOption3,
                                message: tTextErrorUploadFile,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(tInfo9),
                                  ),
                                ],
                              ),
                            );
                          });
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 55.0),
                          child: FutureBuilder<List<FileSystemEntity>>(
                            future: _getListMediaFiles('video', 'gait'),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: GestureDetector(
                                                onTap: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoFileScreen(
                                                              videoPath: snapshot
                                                                  .data!
                                                                  .elementAt(
                                                                      index)
                                                                  .path),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(
                                                  LineAwesomeIcons.play_circle,
                                                  size: 60.0,
                                                ),
                                              ),
                                              title: const Text('GAIT'),
                                              subtitle: Text(
                                                '${_fileNameCardTitle(snapshot.data!.elementAt(index).path).toString()} ${_fileNameCardSubTitle(snapshot.data!.elementAt(index).path).toString()}',
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                  right: 16.0,
                                                  bottom: 16.0),
                                              child: Row(
                                                children: [
                                                  Expanded(child: Container()),
                                                  GestureDetector(
                                                    child: const Icon(
                                                      LineAwesomeIcons.trash,
                                                      color: Colors.red,
                                                      size: 25.0,
                                                    ),
                                                    onTap: () {
                                                      Dialogs.materialDialog(
                                                          color: Colors.white,
                                                          title: 'Eliminar',
                                                          msg:
                                                              tTextDeleteMediaFile,
                                                          context: context,
                                                          actions: [
                                                            IconsButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              text: 'Cerrar',
                                                              color:
                                                                  Colors.grey,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                              iconColor:
                                                                  Colors.white,
                                                            ),
                                                            IconsButton(
                                                              onPressed: () {
                                                                _deleteMediaFile(
                                                                    File(snapshot
                                                                        .data!
                                                                        .elementAt(
                                                                            index)
                                                                        .path));
                                                                setState(() {});
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              text: 'Eliminar',
                                                              color: Colors.red,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                              iconColor:
                                                                  Colors.white,
                                                            ),
                                                          ]);
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      String pathMedia =
                                                          snapshot.data!
                                                              .elementAt(index)
                                                              .path;
                                                      context
                                                          .read<PatientBloc>()
                                                          .add(UploadPacienteGaitTestSubmitting(
                                                              path: pathMedia));
                                                    },
                                                    child: const Icon(
                                                      LineAwesomeIcons.telegram,
                                                      color: tPrimaryColor,
                                                      size: 25.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await _recordVideo('_gait_');
                                setState(() {});
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      const CircleBorder()),
                                  backgroundColor:
                                      MaterialStateProperty.all(tPrimaryColor),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Colors.blue;
                                    }
                                  })),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  LineAwesomeIcons.video_1,
                                  size: 45.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Stack(
                  children: [
                    Positioned(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => PlaceholderDialog(
                                  title: tTextInstTest,
                                  message: tTextStanceTest,
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cerrar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    const CircleBorder()),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(2.0)),
                                backgroundColor:
                                    MaterialStateProperty.all(tPrimaryColor),
                                overlayColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.blue;
                                  }
                                })),
                            child: const Icon(
                              LineAwesomeIcons.question_circle,
                              size: 35.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    BlocBuilder<PatientBloc, PatientState>(
                      builder: (context, state) {
                        if (state is PatientUploadingStanceFile) {
                          return const Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16.0),
                              Text(tInfo10, style: TextStyle(fontSize: 14)),
                            ],
                          ));
                        } else if (state is PatientUploadStanceFileSuccess) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (ctx) => PlaceholderDialog(
                                title: tInfoDialogOption3,
                                message: tTextUploadSuccess,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(tInfo5),
                                  ),
                                ],
                              ),
                            );
                          });
                        } else if (state is PatientStanceFailure) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (ctx) => PlaceholderDialog(
                                title: tInfoDialogOption3,
                                message: tTextErrorUploadFile,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(tInfo9),
                                  ),
                                ],
                              ),
                            );
                          });
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 55.0),
                          child: FutureBuilder<List<FileSystemEntity>>(
                            future: _getListMediaFiles('video', 'stance'),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: GestureDetector(
                                                onTap: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoFileScreen(
                                                              videoPath: snapshot
                                                                  .data!
                                                                  .elementAt(
                                                                      index)
                                                                  .path),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(
                                                  LineAwesomeIcons.play_circle,
                                                  size: 60.0,
                                                ),
                                              ),
                                              title: const Text('STANCE'),
                                              subtitle: Text(
                                                '${_fileNameCardTitle(snapshot.data!.elementAt(index).path).toString()} ${_fileNameCardSubTitle(snapshot.data!.elementAt(index).path).toString()}',
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                  right: 16.0,
                                                  bottom: 16.0),
                                              child: Row(
                                                children: [
                                                  Expanded(child: Container()),
                                                  GestureDetector(
                                                    child: const Icon(
                                                      LineAwesomeIcons.trash,
                                                      color: Colors.red,
                                                      size: 25.0,
                                                    ),
                                                    onTap: () {
                                                      Dialogs.materialDialog(
                                                          color: Colors.white,
                                                          title: 'Eliminar',
                                                          msg:
                                                              tTextDeleteMediaFile,
                                                          context: context,
                                                          actions: [
                                                            IconsButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              text: 'Cerrar',
                                                              color:
                                                                  Colors.grey,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                              iconColor:
                                                                  Colors.white,
                                                            ),
                                                            IconsButton(
                                                              onPressed: () {
                                                                _deleteMediaFile(
                                                                    File(snapshot
                                                                        .data!
                                                                        .elementAt(
                                                                            index)
                                                                        .path));
                                                                setState(() {});
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              text: 'Eliminar',
                                                              color: Colors.red,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                              iconColor:
                                                                  Colors.white,
                                                            ),
                                                          ]);
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      String pathMedia =
                                                          snapshot.data!
                                                              .elementAt(index)
                                                              .path;
                                                      context
                                                          .read<PatientBloc>()
                                                          .add(UploadPacienteStanceTestSubmitting(
                                                              path: pathMedia));
                                                    },
                                                    child: const Icon(
                                                      LineAwesomeIcons.telegram,
                                                      color: tPrimaryColor,
                                                      size: 25.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await _recordVideo('_stance_');
                                setState(() {});
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      const CircleBorder()),
                                  backgroundColor:
                                      MaterialStateProperty.all(tPrimaryColor),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Colors.blue;
                                    }
                                  })),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  LineAwesomeIcons.video_1,
                                  size: 45.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  Positioned(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => PlaceholderDialog(
                                title: tTextInstTest,
                                message: tTextSpeechTest,
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cerrar'),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  const CircleBorder()),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(2.0)),
                              backgroundColor:
                                  MaterialStateProperty.all(tPrimaryColor),
                              overlayColor:
                                  MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return Colors.blue;
                                }
                              })),
                          child: const Icon(
                            LineAwesomeIcons.question_circle,
                            size: 35.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                  BlocBuilder<PatientBloc, PatientState>(
                    builder: (context, state) {
                      if (state is PatientUploadingSpeechFile) {
                        return const Center(
                            child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16.0),
                            Text(tInfo10, style: TextStyle(fontSize: 14)),
                          ],
                        ));
                      } else if (state is PatientUploadSpeechFileSuccess) {
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          showDialog(
                            context: context,
                            builder: (ctx) => PlaceholderDialog(
                              title: tInfoDialogOption3,
                              message: tTextUploadSuccess,
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text(tInfo5),
                                ),
                              ],
                            ),
                          );
                        });
                      } else if (state is PatientSpeechFailure) {
                        SchedulerBinding.instance.addPostFrameCallback((_) {
                          showDialog(
                            context: context,
                            builder: (ctx) => PlaceholderDialog(
                              title: tInfoDialogOption3,
                              message: tTextErrorUploadFile,
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx).pop();
                                  },
                                  child: const Text(tInfo9),
                                ),
                              ],
                            ),
                          );
                        });
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 55.0),
                        child: FutureBuilder<List<FileSystemEntity>>(
                          future: _getListMediaFiles('audio', 'speech'),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return ListView.builder(
                                itemCount: snapshot.data!.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: GestureDetector(
                                              onTap: () async {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            AudioFileWidget(
                                                              fileSystemEntity:
                                                                  snapshot.data!
                                                                      .elementAt(
                                                                          index),
                                                            )));
                                              },
                                              child: const Icon(
                                                LineAwesomeIcons.play_circle,
                                                size: 60.0,
                                              ),
                                            ),
                                            title: const Text('SPEECH'),
                                            subtitle: Text(
                                              '${_fileNameCardTitle(snapshot.data!.elementAt(index).path).toString()} ${_fileNameCardSubTitle(snapshot.data!.elementAt(index).path).toString()}',
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 8.0,
                                                right: 16.0,
                                                bottom: 16.0),
                                            child: Row(
                                              children: [
                                                Expanded(child: Container()),
                                                GestureDetector(
                                                  child: const Icon(
                                                    LineAwesomeIcons.trash,
                                                    color: Colors.red,
                                                    size: 25.0,
                                                  ),
                                                  onTap: () {
                                                    Dialogs.materialDialog(
                                                        color: Colors.white,
                                                        title: 'Eliminar',
                                                        msg:
                                                            tTextDeleteMediaFile,
                                                        context: context,
                                                        actions: [
                                                          IconsButton(
                                                            onPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            text: 'Cerrar',
                                                            color: Colors.grey,
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                            iconColor:
                                                                Colors.white,
                                                          ),
                                                          IconsButton(
                                                            onPressed: () {
                                                              _deleteMediaFile(
                                                                  File(snapshot
                                                                      .data!
                                                                      .elementAt(
                                                                          index)
                                                                      .path));
                                                              setState(() {});
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                            text: 'Eliminar',
                                                            color: Colors.red,
                                                            textStyle:
                                                                const TextStyle(
                                                                    color: Colors
                                                                        .white),
                                                            iconColor:
                                                                Colors.white,
                                                          ),
                                                        ]);
                                                  },
                                                ),
                                                const SizedBox(
                                                  width: 20.0,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    String pathMedia = snapshot
                                                        .data!
                                                        .elementAt(index)
                                                        .path;
                                                    context.read<PatientBloc>().add(
                                                        UploadPacienteSpeechTestSubmitting(
                                                            path: pathMedia));
                                                  },
                                                  child: const Icon(
                                                    LineAwesomeIcons.telegram,
                                                    color: tPrimaryColor,
                                                    size: 25.0,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      );
                    },
                  ),
                  Positioned(
                    right: 0.0,
                    bottom: 0.0,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        children: [
                          StreamBuilder<RecordingDisposition>(
                            stream: recorder.onProgress,
                            builder: (context, snapshot) {
                              final duration = snapshot.hasData
                                  ? snapshot.data!.duration
                                  : Duration.zero;

                              String twoDigits(int n) =>
                                  n.toString().padLeft(2, '0');
                              final twoDigitMinutes =
                                  twoDigits(duration.inMinutes.remainder(60));
                              final twoDigitSeconds =
                                  twoDigits(duration.inSeconds.remainder(60));
                              return Visibility(
                                visible: recorder.isRecording ? true : false,
                                child: Text(
                                  '$twoDigitMinutes:$twoDigitSeconds',
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            },
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (recorder.isRecording) {
                                await _stopAudio();
                              } else {
                                await _recordAudio();
                              }
                              setState(() {});
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    const CircleBorder()),
                                backgroundColor:
                                    MaterialStateProperty.all(tPrimaryColor),
                                overlayColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.blue;
                                  }
                                })),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(
                                recorder.isRecording
                                    ? LineAwesomeIcons.stop
                                    : LineAwesomeIcons.microphone,
                                size: 45.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: Stack(
                  children: [
                    Positioned(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => PlaceholderDialog(
                                  title: tTextInstTest,
                                  message: tTextNoseFingerTest,
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cerrar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    const CircleBorder()),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(2.0)),
                                backgroundColor:
                                    MaterialStateProperty.all(tPrimaryColor),
                                overlayColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.blue;
                                  }
                                })),
                            child: const Icon(
                              LineAwesomeIcons.question_circle,
                              size: 35.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    BlocBuilder<PatientBloc, PatientState>(
                      builder: (context, state) {
                        if (state is PatientUploadingFingerFile) {
                          return const Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16.0),
                              Text(tInfo10, style: TextStyle(fontSize: 14)),
                            ],
                          ));
                        } else if (state is PatientUploadFingerFileSuccess) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (ctx) => PlaceholderDialog(
                                title: tInfoDialogOption3,
                                message: tTextUploadSuccess,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(tInfo5),
                                  ),
                                ],
                              ),
                            );
                          });
                        } else if (state is PatientFingerFailure) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (ctx) => PlaceholderDialog(
                                title: tInfoDialogOption3,
                                message: tTextErrorUploadFile,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(tInfo9),
                                  ),
                                ],
                              ),
                            );
                          });
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 55.0),
                          child: FutureBuilder<List<FileSystemEntity>>(
                            future: _getListMediaFiles('video', 'finger'),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: GestureDetector(
                                                onTap: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoFileScreen(
                                                              videoPath: snapshot
                                                                  .data!
                                                                  .elementAt(
                                                                      index)
                                                                  .path),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(
                                                  LineAwesomeIcons.play_circle,
                                                  size: 60.0,
                                                ),
                                              ),
                                              title: const Text('FINGER'),
                                              subtitle: Text(
                                                '${_fileNameCardTitle(snapshot.data!.elementAt(index).path).toString()} ${_fileNameCardSubTitle(snapshot.data!.elementAt(index).path).toString()}',
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                  right: 16.0,
                                                  bottom: 16.0),
                                              child: Row(
                                                children: [
                                                  Expanded(child: Container()),
                                                  GestureDetector(
                                                    child: const Icon(
                                                      LineAwesomeIcons.trash,
                                                      color: Colors.red,
                                                      size: 25.0,
                                                    ),
                                                    onTap: () {
                                                      Dialogs.materialDialog(
                                                          color: Colors.white,
                                                          title: 'Eliminar',
                                                          msg:
                                                              tTextDeleteMediaFile,
                                                          context: context,
                                                          actions: [
                                                            IconsButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              text: 'Cerrar',
                                                              color:
                                                                  Colors.grey,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                              iconColor:
                                                                  Colors.white,
                                                            ),
                                                            IconsButton(
                                                              onPressed: () {
                                                                _deleteMediaFile(
                                                                    File(snapshot
                                                                        .data!
                                                                        .elementAt(
                                                                            index)
                                                                        .path));
                                                                setState(() {});
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              text: 'Eliminar',
                                                              color: Colors.red,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                              iconColor:
                                                                  Colors.white,
                                                            ),
                                                          ]);
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      String pathMedia =
                                                          snapshot.data!
                                                              .elementAt(index)
                                                              .path;
                                                      context
                                                          .read<PatientBloc>()
                                                          .add(UploadPacienteFingerTestSubmitting(
                                                              path: pathMedia));
                                                    },
                                                    child: const Icon(
                                                      LineAwesomeIcons.telegram,
                                                      color: tPrimaryColor,
                                                      size: 25.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await _recordVideo('_finger_');
                                setState(() {});
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      const CircleBorder()),
                                  backgroundColor:
                                      MaterialStateProperty.all(tPrimaryColor),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Colors.blue;
                                    }
                                  })),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  LineAwesomeIcons.video_1,
                                  size: 45.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Stack(
                  children: [
                    Positioned(
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => PlaceholderDialog(
                                  title: tTextInstTest,
                                  message: tTextHandMoveTest,
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('Cerrar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    const CircleBorder()),
                                padding: MaterialStateProperty.all(
                                    const EdgeInsets.all(2.0)),
                                backgroundColor:
                                    MaterialStateProperty.all(tPrimaryColor),
                                overlayColor:
                                    MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return Colors.blue;
                                  }
                                })),
                            child: const Icon(
                              LineAwesomeIcons.question_circle,
                              size: 35.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    BlocBuilder<PatientBloc, PatientState>(
                      builder: (context, state) {
                        if (state is PatientUploadingHandFile) {
                          return const Center(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16.0),
                              Text(tInfo10, style: TextStyle(fontSize: 14)),
                            ],
                          ));
                        } else if (state is PatientUploadHandFileSuccess) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (ctx) => PlaceholderDialog(
                                title: tInfoDialogOption3,
                                message: tTextUploadSuccess,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(tInfo5),
                                  ),
                                ],
                              ),
                            );
                          });
                        } else if (state is PatientHandFailure) {
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            showDialog(
                              context: context,
                              builder: (ctx) => PlaceholderDialog(
                                title: tInfoDialogOption3,
                                message: tTextErrorUploadFile,
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                    },
                                    child: const Text(tInfo9),
                                  ),
                                ],
                              ),
                            );
                          });
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 55.0),
                          child: FutureBuilder<List<FileSystemEntity>>(
                            future: _getListMediaFiles('video', 'hand'),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return ListView.builder(
                                  itemCount: snapshot.data!.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: GestureDetector(
                                                onTap: () async {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VideoFileScreen(
                                                              videoPath: snapshot
                                                                  .data!
                                                                  .elementAt(
                                                                      index)
                                                                  .path),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(
                                                  LineAwesomeIcons.play_circle,
                                                  size: 60.0,
                                                ),
                                              ),
                                              title: const Text('HAND'),
                                              subtitle: Text(
                                                '${_fileNameCardTitle(snapshot.data!.elementAt(index).path).toString()} ${_fileNameCardSubTitle(snapshot.data!.elementAt(index).path).toString()}',
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0,
                                                  right: 16.0,
                                                  bottom: 16.0),
                                              child: Row(
                                                children: [
                                                  Expanded(child: Container()),
                                                  GestureDetector(
                                                    child: const Icon(
                                                      LineAwesomeIcons.trash,
                                                      color: Colors.red,
                                                      size: 25.0,
                                                    ),
                                                    onTap: () {
                                                      Dialogs.materialDialog(
                                                          color: Colors.white,
                                                          title: 'Eliminar',
                                                          msg:
                                                              tTextDeleteMediaFile,
                                                          context: context,
                                                          actions: [
                                                            IconsButton(
                                                              onPressed: () {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              text: 'Cerrar',
                                                              color:
                                                                  Colors.grey,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                              iconColor:
                                                                  Colors.white,
                                                            ),
                                                            IconsButton(
                                                              onPressed: () {
                                                                _deleteMediaFile(
                                                                    File(snapshot
                                                                        .data!
                                                                        .elementAt(
                                                                            index)
                                                                        .path));
                                                                setState(() {});
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              },
                                                              text: 'Eliminar',
                                                              color: Colors.red,
                                                              textStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                              iconColor:
                                                                  Colors.white,
                                                            ),
                                                          ]);
                                                    },
                                                  ),
                                                  const SizedBox(
                                                    width: 20.0,
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      String pathMedia =
                                                          snapshot.data!
                                                              .elementAt(index)
                                                              .path;
                                                      context
                                                          .read<PatientBloc>()
                                                          .add(UploadPacienteHandTestSubmitting(
                                                              path: pathMedia));
                                                    },
                                                    child: const Icon(
                                                      LineAwesomeIcons.telegram,
                                                      color: tPrimaryColor,
                                                      size: 25.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return Container();
                              }
                            },
                          ),
                        );
                      },
                    ),
                    Positioned(
                      right: 0.0,
                      bottom: 0.0,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                await _recordVideo('_hand_');
                                setState(() {});
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      const CircleBorder()),
                                  backgroundColor:
                                      MaterialStateProperty.all(tPrimaryColor),
                                  overlayColor:
                                      MaterialStateProperty.resolveWith(
                                          (states) {
                                    if (states
                                        .contains(MaterialState.pressed)) {
                                      return Colors.blue;
                                    }
                                  })),
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(
                                  LineAwesomeIcons.video_1,
                                  size: 45.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class NavigationDrawer extends StatelessWidget {
  const NavigationDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHeader(context),
          buildMenuItems(context),
        ],
      ),
    );
  }

  Widget buildHeader(BuildContext context) {
    return Material(
      color: tPrimaryColor,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      const UserProfileScreen(newUser: false)));
        },
        child: Container(
          color: tPrimaryColor,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 20.0,
            bottom: 15.0,
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  BlocBuilder<ProfileBloc, ProfileState>(
                    builder: (context, state) {
                      var image = state.avatar ?? '';
                      return SizedBox(
                        width: 120,
                        height: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(120),
                          child: (image.isEmpty)
                              ? const Image(image: AssetImage(tProfileImage))
                              : Image.memory(
                                  const Base64Decoder().convert(image),
                                  fit: BoxFit.cover,
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // const Text(
              //   'profile.fullName',
              //   style: TextStyle(fontSize: 16.0),
              // ),
              // const Text(
              //   'profile.emailAddress',
              //   style: TextStyle(fontSize: 12.0),
              // ),
              // const SizedBox(
              //   height: 10.0,
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildMenuItems(BuildContext context) => Wrap(
        runSpacing: 16,
        children: [
          ProfileMenuWidget(
            title: tMenuDrawer3,
            icon: LineAwesomeIcons.stethoscope,
            onPress: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage())),
          ),
          ProfileMenuWidget(
            title: tMenuDrawer2,
            icon: LineAwesomeIcons.phone_volume,
            onPress: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) => const SensorsScreen(),
                ),
                (route) => route.isFirst,
              );
            },
          ),
          const Divider(),
          const SizedBox(
            height: 10,
          ),
          ProfileMenuWidget(
            title: tMenuDrawer10,
            icon: LineAwesomeIcons.alternate_sign_out,
            textColor: Colors.red,
            endIcon: false,
            onPress: () {
              showDialog(
                context: context,
                builder: (ctx) => PlaceholderDialog(
                  title: tInfoDialogOption3,
                  message: tInfoDialogOption5,
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                      child: const Text(tInfo8),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(tInfo7),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      );
}
