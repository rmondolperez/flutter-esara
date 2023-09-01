import 'dart:convert';
import 'dart:io';
import 'package:esara/application/core/constants/text_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../constants/image_string.dart';
import '../../blocs/login/login_bloc.dart';
import '../../blocs/network/network_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../home/home_page_screen.dart';
import '../home/widgets/placeholder_dialog_widget.dart';
import '../profile/user_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController ciController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var isRememberMe = ValueNotifier<bool>(false);

  @override
  void initState() {
    _createFolderInAppDocDir('audio');
    _createFolderInAppDocDir('video');
    super.initState();
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

  late List<FileSystemEntity> _folders;

  Future<void> getDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final dir = directory.path;
    String pdfDirectory = '$dir/';
    final myDir = Directory(pdfDirectory);
    _folders = myDir.listSync(recursive: true, followLinks: false);
  }

  Widget buildEmail() {
    final loginBloc = BlocProvider.of<LoginBloc>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          tCi,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
              ]),
          height: 60,
          child: TextFormField(
            onChanged: (ci) {
              loginBloc.add(LoginUserCiChanged(ci: ci));
            },
            controller: ciController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(
                  Icons.email,
                  color: Color(0xff5ac18e),
                ),
                hintText: tCi,
                hintStyle: TextStyle(
                  color: Colors.black38,
                )),
          ),
        ),
      ],
    );
  }

  Widget buildPassword() {
    final loginBloc = BlocProvider.of<LoginBloc>(context, listen: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          tPassword,
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
              ]),
          height: 60,
          child: TextFormField(
            onChanged: (password) {
              loginBloc.add(LoginUserPasswordChanged(password: password));
            },
            controller: passwordController,
            obscureText: true,
            style: const TextStyle(color: Colors.black87),
            decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.only(top: 14),
                prefixIcon: Icon(
                  Icons.key,
                  color: Color(0xff5ac18e),
                ),
                hintText: tPassword,
                hintStyle: TextStyle(
                  color: Colors.black38,
                )),
          ),
        ),
      ],
    );
  }

  Widget buildLoginBtn() {
    return BlocBuilder<LoginBloc, LoginState>(
      builder: (context, state) {
        if (state is LoginInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is LoginSuccess) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()));
          });
        } else if (state is LoginFailure) {
          SchedulerBinding.instance.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (ctx) => PlaceholderDialog(
                title: tInfoDialogOption3,
                message: tTextErrorLogin,
                actions: [
                  TextButton(
                    onPressed: () {
                      context.read<LoginBloc>().add(LoginFormInitial());
                      Navigator.of(ctx).pop();
                    },
                    child: const Text(tInfo9),
                  ),
                ],
              ),
            );
          });
        }
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                elevation: 5,
                padding: const EdgeInsets.all(15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15))),
            onPressed: () {
              context.read<LoginBloc>().add(LoginFormSubmitting());
            },
            child: const Text(
              'Acceder',
              style: TextStyle(
                  color: Color(0xff5ac18e),
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget buildSignUpBtn() {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const UserProfileScreen(
                    newUser: true,
                  ))),
      child: Visibility(
        visible: true,
        child: RichText(
            text: const TextSpan(children: [
          TextSpan(
              text: tTextNoAccountFile,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500)),
          TextSpan(
              text: tTextRegister,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold))
        ])),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var profileBloc = BlocProvider.of<ProfileBloc>(context, listen: false);
    return Scaffold(
        body: Stack(children: [
      SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                          Color(0xff5ac18e),
                          Color(0xcc5ac18e),
                          Color(0x995ac18e),
                          Color(0x665ac18e),
                        ])),
                    child: Form(
                      key: formKey,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(120),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: 120,
                                      height: 120,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(120),
                                        child: (profileBloc
                                                .state.avatar.isEmpty)
                                            ? const Image(
                                                image:
                                                    AssetImage(tProfileImage))
                                            : Image.memory(
                                                const Base64Decoder().convert(
                                                    profileBloc.state.avatar),
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 50,
                            ),
                            buildEmail(),
                            const SizedBox(
                              height: 30,
                            ),
                            buildPassword(),
                            const SizedBox(
                              height: 15,
                            ),
                            const SizedBox(
                              height: 35,
                            ),
                            Visibility(
                              visible: context
                                  .watch<NetworkBloc>()
                                  .state
                                  .hasNetworkConnected,
                              child: buildLoginBtn(),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Visibility(
                              visible: context
                                  .watch<NetworkBloc>()
                                  .state
                                  .hasNetworkConnected,
                              child: buildSignUpBtn(),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Visibility(
                              visible: !context
                                  .watch<NetworkBloc>()
                                  .state
                                  .hasNetworkConnected,
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: Colors.grey),
                                child: const Center(
                                  child: Text(
                                    'No conectado',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ]));
  }
}
