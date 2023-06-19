import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/theming.dart';
import '../controllers/auth_controller.dart';
import '../models/create_user.dart';
import '../widgets/edit_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  int? selectedFieldIndex;

  late final TextEditingController usernameCtrl;
  late final TextEditingController emailCtrl;
  late final TextEditingController firstNameCtrl;
  late final TextEditingController lastNameCtrl;
  late final TextEditingController passwordCtrl;
  late final TextEditingController passwordConfirmCtrl;
  DateTime? dateOfBirthVal;

  late final AuthController authController;

  @override
  void initState() {
    super.initState();
    authController = AuthController();
    usernameCtrl = TextEditingController();
    emailCtrl = TextEditingController();
    firstNameCtrl = TextEditingController();
    lastNameCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
    passwordConfirmCtrl = TextEditingController();
    initializeDateFormatting();
  }

  @override
  void dispose() {
    super.dispose();
    usernameCtrl.dispose();
    emailCtrl.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    passwordCtrl.dispose();
    passwordConfirmCtrl.dispose();
  }

  bool get _userCanRegister {
    final List<dynamic> fieldCtrls = [
      usernameCtrl.text,
      emailCtrl.text,
      firstNameCtrl.text,
      lastNameCtrl.text,
      passwordCtrl.text,
      passwordConfirmCtrl.text,
      dateOfBirthVal,
    ];
    for (final i in fieldCtrls) {
      if (i == "" || i == null) {
        return false;
      }
    }
    return true;
  }

  void _onFieldSelect(int index) {
    setState(() => selectedFieldIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theming.bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 30,
              right: 30,
              top: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.signUp,
                  style: const TextStyle(
                    color: Theming.whiteTone,
                    fontWeight: FontWeight.bold,
                    fontSize: 38,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.fillFieldsBelow,
                  style: TextStyle(
                    color: Theming.whiteTone.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      //TODO picking an image from gallery
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0x9F000E1F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Theming.bgColorLight,
                            backgroundImage:
                                AssetImage("assets/images/default_pfp.png"),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            AppLocalizations.of(context)!.changePfp,
                            style: const TextStyle(
                              color: Theming.whiteTone,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                EditField(
                  index: 0,
                  selectedFieldIndex: selectedFieldIndex,
                  caption: AppLocalizations.of(context)!.username,
                  icon: Icons.alternate_email_rounded,
                  placeholder: AppLocalizations.of(context)!.usernameField,
                  ctrl: usernameCtrl,
                  onSelect: (idx) => _onFieldSelect(idx),
                ),
                EditField(
                  index: 1,
                  selectedFieldIndex: selectedFieldIndex,
                  caption: AppLocalizations.of(context)!.email,
                  icon: Icons.email_outlined,
                  placeholder: AppLocalizations.of(context)!.emailField,
                  ctrl: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  onSelect: (idx) => _onFieldSelect(idx),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    EditField(
                      index: 2,
                      selectedFieldIndex: selectedFieldIndex,
                      caption: AppLocalizations.of(context)!.firstName,
                      icon: Icons.person_pin_rounded,
                      placeholder: AppLocalizations.of(context)!.firstNameField,
                      ctrl: firstNameCtrl,
                      manyInRow: true,
                      keyboardType: TextInputType.name,
                      onSelect: (idx) => _onFieldSelect(idx),
                    ),
                    EditField(
                      index: 3,
                      selectedFieldIndex: selectedFieldIndex,
                      caption: AppLocalizations.of(context)!.lastName,
                      icon: Icons.contact_emergency_rounded,
                      placeholder: AppLocalizations.of(context)!.lastNameField,
                      ctrl: lastNameCtrl,
                      manyInRow: true,
                      keyboardType: TextInputType.name,
                      onSelect: (idx) => _onFieldSelect(idx),
                    ),
                  ],
                ),
                EditField(
                  index: 4,
                  selectedFieldIndex: selectedFieldIndex,
                  caption: AppLocalizations.of(context)!.password,
                  icon: Icons.lock_outline,
                  placeholder: AppLocalizations.of(context)!.passwordField,
                  ctrl: passwordCtrl,
                  isPassword: true,
                  manyInRow: false,
                  onSelect: (idx) => _onFieldSelect(idx),
                ),
                EditField(
                  index: 5,
                  selectedFieldIndex: selectedFieldIndex,
                  caption: AppLocalizations.of(context)!.confirmPassword,
                  icon: Icons.lock_outline,
                  placeholder: AppLocalizations.of(context)!.passwordField,
                  ctrl: passwordConfirmCtrl,
                  isPassword: true,
                  manyInRow: false,
                  onSelect: (idx) => _onFieldSelect(idx),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: GestureDetector(
                    onTap: () async {
                      setState(() => selectedFieldIndex = null);
                      final dateVal = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 100),
                        lastDate: DateTime.now(),
                        useRootNavigator: true,
                        locale:
                            Locale(AppLocalizations.of(context)!.localeName),
                      );
                      setState(() => dateOfBirthVal = dateVal);
                    },
                    child: Container(
                      height: 70,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 15),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0x9F000E1F),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.date_range_outlined,
                            color: Theming.whiteTone,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            dateOfBirthVal == null
                                ? AppLocalizations.of(context)!.dateOfBirth
                                : DateFormat.yMd(AppLocalizations.of(context)!
                                        .localeName)
                                    .format(dateOfBirthVal!),
                            style: const TextStyle(
                              color: Theming.whiteTone,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      AuthController.registerUser(
                        CreateUser(
                          username: usernameCtrl.text,
                          email: emailCtrl.text,
                          firstName: firstNameCtrl.text,
                          lastName: lastNameCtrl.text,
                          dateOfBirth:
                              dateOfBirthVal!, //TODO fix the NULL value
                          password: passwordCtrl.text,
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      width: double.infinity,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.linearToEaseOut,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        vertical: 15,
                      ),
                      decoration: BoxDecoration(
                        color: _userCanRegister
                            ? Theming.primaryColor
                            : Theming.whiteTone.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.signUp,
                        style: const TextStyle(
                          color: Theming.whiteTone,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go("/login"),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: AppLocalizations.of(context)!.haveAnAccount,
                            style: TextStyle(
                              color: Theming.whiteTone.withOpacity(0.5),
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: " ${AppLocalizations.of(context)!.signIn}",
                            style: const TextStyle(
                              color: Theming.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
