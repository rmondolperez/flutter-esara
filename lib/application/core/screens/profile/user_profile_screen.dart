// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:esara/application/core/blocs/patient/patient_bloc.dart';
import 'package:esara/application/core/constants/colors.dart';
import 'package:esara/application/core/constants/image_string.dart';
import 'package:esara/application/core/constants/sizes.dart';
import 'package:esara/application/core/constants/text_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';

import '../../blocs/network/network_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../home/home_page_screen.dart';
import '../home/widgets/placeholder_dialog_widget.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    Key? key,
    required this.newUser,
  }) : super(key: key);
  final bool newUser;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController ciController = TextEditingController();
  TextEditingController historiaClinicaController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmacionController =
      TextEditingController();
  TextEditingController phoneEmergencyController = TextEditingController();

  final formKey = GlobalKey<FormState>();
  var emergencyPhoneListNotifier =
      ValueNotifier<List<dynamic>>(List.empty(growable: true));

  String? _image = '';

  Future<bool> _onWillPop(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomePage()));
    return Future.value(false);
  }

  List _checkPhoneEmergencyNumber(String emergencyPhone) {
    return emergencyPhoneListNotifier.value
        .where((phone) => phone == emergencyPhone)
        .toList();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    ciController.dispose();
    historiaClinicaController.dispose();
    passwordController.dispose();
    passwordConfirmacionController.dispose();
    phoneEmergencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _loadProfile(widget.newUser);
    final patientBloc = BlocProvider.of<PatientBloc>(context, listen: false);
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(tDefaultSize),
          child: Column(
            children: [
              Form(
                  key: formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: ((builder) => bottomSheet(context)));
                        },
                        child: BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            var image = state.avatar ?? '';
                            return Stack(
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(120),
                                    child: (image.isEmpty)
                                        ? const Image(
                                            image: AssetImage(tProfileImage))
                                        : Image.memory(
                                            const Base64Decoder()
                                                .convert(image),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 35,
                                    height: 35,
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: tPrimaryColor),
                                    child: const Icon(
                                      LineAwesomeIcons.alternate_pencil,
                                      color: Colors.black,
                                      size: 20,
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                      Visibility(
                        visible: widget.newUser,
                        child: TextFormField(
                            onChanged: (name) {
                              patientBloc.add(NameTextFieldEvent(name: name));
                            },
                            controller: nameController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              label: Text(tName),
                              prefixIcon: Icon(LineAwesomeIcons.user),
                            ),
                            validator: RequiredValidator(
                                errorText: '$tName requerido')),
                      ),
                      const SizedBox(
                        height: tFormHeight - 20,
                      ),
                      Visibility(
                        visible: widget.newUser,
                        child: TextFormField(
                            onChanged: (lastName) {
                              patientBloc
                                  .add(LastNameTextField(lastName: lastName));
                            },
                            controller: lastNameController,
                            keyboardType: TextInputType.text,
                            decoration: const InputDecoration(
                              label: Text(tLastName),
                              prefixIcon: Icon(LineAwesomeIcons.user),
                            ),
                            validator: RequiredValidator(
                                errorText: '$tLastName requerido')),
                      ),
                      const SizedBox(
                        height: tFormHeight - 20,
                      ),
                      Visibility(
                        visible: widget.newUser,
                        child: TextFormField(
                          maxLength: 11,
                          onChanged: (ci) {
                            patientBloc.add(CiTextField(ci: ci));
                          },
                          controller: ciController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            label: Text(tNumberId),
                            prefixIcon: Icon(LineAwesomeIcons.hospital_1),
                          ),
                          validator: MultiValidator(
                            [
                              RequiredValidator(
                                  errorText: '$tNumberId requerido'),
                              MinLengthValidator(11,
                                  errorText:
                                      '$tNumberId debe tener 11 números'),
                              MaxLengthValidator(11,
                                  errorText:
                                      '$tNumberId debe tener 11 números'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: tFormHeight - 20,
                      ),
                      Visibility(
                        visible: widget.newUser,
                        child: TextFormField(
                          maxLength: 9,
                          onChanged: (historia) {
                            patientBloc.add(HistoriaClinicaTextField(
                                historiaClinica: historia));
                          },
                          controller: historiaClinicaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            label: Text(tNumberPatient),
                            prefixIcon: Icon(LineAwesomeIcons.hospital_1),
                          ),
                          validator: MultiValidator(
                            [
                              RequiredValidator(
                                  errorText: '$tNumberPatient requerido'),
                              MinLengthValidator(9,
                                  errorText:
                                      '$tNumberPatient debe tener 9 números'),
                              MaxLengthValidator(9,
                                  errorText:
                                      '$tNumberPatient debe tener 9 números'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: tFormHeight - 20,
                      ),
                      Visibility(
                        visible: widget.newUser,
                        child: TextFormField(
                          onChanged: (password) {
                            patientBloc
                                .add(PasswordTextField(password: password));
                          },
                          obscureText: true,
                          controller: passwordController,
                          decoration: const InputDecoration(
                            label: Text(tPassword),
                            prefixIcon: Icon(LineAwesomeIcons.key),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: tFormHeight - 20,
                      ),
                      Visibility(
                        visible: !widget.newUser,
                        child: TextFormField(
                          controller: phoneEmergencyController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            label: const Text(tEmergencyPhones),
                            prefixIcon: const Icon(LineAwesomeIcons.phone),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                if ((phoneEmergencyController
                                        .text.isNotEmpty) &&
                                    (phoneEmergencyController.text.length ==
                                        8)) {
                                  var temp = _checkPhoneEmergencyNumber(
                                      phoneEmergencyController.text);
                                  if (temp.isEmpty) {
                                    emergencyPhoneListNotifier.value
                                        .add(phoneEmergencyController.text);
                                    emergencyPhoneListNotifier.value =
                                        List.from(
                                            emergencyPhoneListNotifier.value);
                                  } else {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => PlaceholderDialog(
                                        title: tInfoDialogOption3,
                                        message: tTextEmergencyPhoneExist,
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(ctx).pop(),
                                            child: const Text(tInfo5),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                } else if (phoneEmergencyController
                                        .text.isEmpty ||
                                    phoneEmergencyController.text.length != 8) {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => PlaceholderDialog(
                                      title: tInfoDialogOption3,
                                      message: tTextNoEmergencyPhoneProvide,
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(),
                                          child: const Text(tInfo5),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                var emergencyList = jsonEncode(
                                    emergencyPhoneListNotifier.value);
                                context.read<PatientBloc>().add(
                                    ChangeEmergencyNumbersEvent(
                                        emergencyNumbers: emergencyList));
                                phoneEmergencyController.text = '';
                              },
                              child: const Icon(
                                LineAwesomeIcons.plus_circle,
                                color: tPrimaryColor,
                                size: 35.0,
                              ),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null) {
                              return 'Campo requerido';
                            }
                          },
                        ),
                      ),
                      ValueListenableBuilder<List<dynamic>>(
                        valueListenable: emergencyPhoneListNotifier,
                        builder: (context, value, _) {
                          return ListView.builder(
                              primary: false,
                              shrinkWrap: true,
                              itemCount:
                                  emergencyPhoneListNotifier.value.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  leading: const Icon(
                                    LineAwesomeIcons.phone,
                                    color: tPrimaryColor,
                                  ),
                                  title: Text(emergencyPhoneListNotifier.value
                                      .elementAt(index)
                                      .toString()),
                                  trailing: GestureDetector(
                                    onTap: () {
                                      emergencyPhoneListNotifier.value
                                          .removeAt(index);
                                      emergencyPhoneListNotifier.value =
                                          List.from(
                                              emergencyPhoneListNotifier.value);
                                      var emergencyList = jsonEncode(
                                          emergencyPhoneListNotifier.value);
                                      context.read<PatientBloc>().add(
                                          ChangeEmergencyNumbersEvent(
                                              emergencyNumbers: emergencyList));
                                    },
                                    child: const Icon(
                                      LineAwesomeIcons.minus_circle,
                                      color: Colors.red,
                                    ),
                                  ),
                                );
                              });
                        },
                      ),
                      BlocBuilder<PatientBloc, PatientState>(
                        builder: (context, state) {
                          if (state is PatientRegistered) {
                            MaterialPageRoute(
                                builder: (context) => const UserProfileScreen(
                                      newUser: true,
                                    ));
                          } else if (state is PatientRegister) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (state is PatientFailure) {
                            SchedulerBinding.instance.addPostFrameCallback((_) {
                              showDialog(
                                context: context,
                                builder: (ctx) => PlaceholderDialog(
                                  title: tInfoDialogOption3,
                                  message: tTextErrorLogin,
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
                          return Visibility(
                            visible: context
                                    .watch<NetworkBloc>()
                                    .state
                                    .hasNetworkConnected &&
                                widget.newUser,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 5,
                                    padding: const EdgeInsets.all(15),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15))),
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    patientBloc
                                        .add(RegisterPacienteFormSubmitting());
                                    nameController.clear();
                                    lastNameController.clear();
                                    ciController.clear();
                                    historiaClinicaController.clear();
                                    passwordController.clear();
                                    passwordConfirmacionController.clear();
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text(
                                  tTextSave,
                                  style: TextStyle(
                                      color: Color(0xff5ac18e),
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        },
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
                      const SizedBox(
                        height: tFormHeight,
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget bottomSheet(BuildContext context) {
    return Container(
      height: 150.0,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          const Text(
            tInfo1,
            style: TextStyle(fontSize: 20.0),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  _takeImage(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.image,
                  size: 50,
                ),
                label: const Text(tInfoDialogOption1),
              ),
              const SizedBox(
                width: 50.0,
              ),
              TextButton.icon(
                onPressed: () {
                  _takeImage(ImageSource.camera);
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.camera,
                  size: 50,
                ),
                label: const Text(tInfoDialogOption2),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future _takeImage(ImageSource source) async {
    final profileBloc = BlocProvider.of<ProfileBloc>(context, listen: false);
    try {
      final image = await ImagePicker().pickImage(source: source);
      if (image == null) return;
      Uint8List imageAsByte = await image.readAsBytes();
      profileBloc.add(ChangeAvatarEvent(avatar: base64Encode(imageAsByte)));
    } on PlatformException {}
  }

  void _loadProfile(bool newUser) async {
    final patientBloc = BlocProvider.of<PatientBloc>(context, listen: false);
    var emergencyNumbers = patientBloc.state.emergencyNumbers ?? '';
    if (emergencyNumbers.isNotEmpty) {
      var emergencyPhones = json.decode(emergencyNumbers);
      emergencyPhoneListNotifier.value.addAll(emergencyPhones);
    }
  }
}
