import 'dart:io';
import 'package:drinkify/controllers/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import '/utils/theming.dart';
import '/widgets/edit_field.dart';
import '/widgets/custom_floating_button.dart';
import '/widgets/dialogs/edit_profile_confirmation.dart';
import '/widgets/image_picker_sheet.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  XFile? pfp;
  late final TextEditingController firstNameCtrl;
  late final TextEditingController lastNameCtrl;
  late final TextEditingController birthdayCtrl;
  late final TextEditingController passwordCtrl;

  late int? selectedFieldIndex;

  @override
  void initState() {
    super.initState();

    firstNameCtrl = TextEditingController();
    lastNameCtrl = TextEditingController();
    birthdayCtrl = TextEditingController();
    passwordCtrl = TextEditingController();
    selectedFieldIndex = null;
    initializeDateFormatting();
  }

  @override
  void dispose() {
    super.dispose();
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    birthdayCtrl.dispose();
    passwordCtrl.dispose();
  }

  void _onFieldSelect(int index) {
    setState(() => selectedFieldIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theming.bgColor,
      floatingActionButton: CustomFloatingButton(
        caption: AppLocalizations.of(context)!.save,
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => const EditProfileConfirmation(),
          );
          context.pop();
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theming.bgColor,
            pinned: true,
            surfaceTintColor: Theming.bgColor,
            shadowColor: Theming.bgColor,
            title: Text(
              AppLocalizations.of(context)!.editProfilePage,
              style: const TextStyle(
                color: Theming.whiteTone,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(
                  Icons.arrow_back_ios_rounded,
                  color: Theming.whiteTone,
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: IconButton(
                  onPressed: () async {
                    //TODO add confirmation dialog
                    final isDeleted = await UserController.deleteMe();
                    if (mounted && isDeleted) {
                      context.go("/login");
                    }
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Theming.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(
                left: 30,
                right: 30,
                top: 20,
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Theming.bgColor,
                        builder: (ctx) => ImagePickerSheet(
                          onFinish: (img) {
                            setState(() => pfp = img);
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        //I have no idea why I couldn't do image stuff in one line :(
                        pfp == null
                            ? const CircleAvatar(
                                radius: 45,
                                backgroundColor: Theming.bgColorLight,
                                backgroundImage: AssetImage(
                                  "assets/images/default_pfp.png",
                                ),
                              )
                            : CircleAvatar(
                                radius: 45,
                                backgroundColor: Theming.bgColorLight,
                                backgroundImage: FileImage(File(pfp!.path)),
                              ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 20,
                              width: 20,
                              decoration: const BoxDecoration(
                                color: Theming.primaryColor,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Theming.bgColor,
                                    spreadRadius: 4,
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.photo_camera,
                                color: Theming.whiteTone,
                                size: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  EditField(
                    index: 0,
                    caption: AppLocalizations.of(context)!.firstName,
                    icon: Icons.sentiment_satisfied_rounded,
                    placeholder: AppLocalizations.of(context)!.firstName,
                    ctrl: firstNameCtrl,
                    onSelect: (idx) => _onFieldSelect(idx),
                    selectedFieldIndex: selectedFieldIndex,
                  ),
                  EditField(
                    index: 1,
                    caption: AppLocalizations.of(context)!.lastName,
                    icon: Icons.contact_emergency_rounded,
                    placeholder: AppLocalizations.of(context)!.lastNameField,
                    ctrl: lastNameCtrl,
                    onSelect: (idx) => _onFieldSelect(idx),
                    selectedFieldIndex: selectedFieldIndex,
                  ),
                  EditField(
                    index: 2,
                    caption: AppLocalizations.of(context)!.dateOfBirth,
                    icon: Icons.calendar_month_rounded,
                    isDate: true,
                    ctrl: birthdayCtrl,
                    isDateSelected: birthdayCtrl.text.isNotEmpty,
                    placeholder: AppLocalizations.of(context)!.dateOfBirth,
                    keyboardType: TextInputType.none,
                    selectedFieldIndex: selectedFieldIndex,
                    // keyboardType: TextInputType.none,
                    onSelect: (idx) async {
                      setState(() => selectedFieldIndex = null);
                      final datePickerVal = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(DateTime.now().year - 100),
                        lastDate: DateTime.now(),
                        useRootNavigator: true,
                        locale: Locale(
                          AppLocalizations.of(context)!.localeName,
                        ),
                      );
                      if (datePickerVal == null || !mounted) return;
                      final formattedDate = DateFormat.yMd(
                        AppLocalizations.of(context)!.localeName,
                      ).format(datePickerVal);
                      setState(() => birthdayCtrl.text = formattedDate);
                    },
                  ),
                  EditField(
                    index: 3,
                    caption: AppLocalizations.of(context)!.password,
                    icon: Icons.password,
                    placeholder: AppLocalizations.of(context)!.passwordField,
                    ctrl: passwordCtrl,
                    selectedFieldIndex: selectedFieldIndex,
                    onSelect: (idx) => _onFieldSelect(idx),
                    isPassword: true,
                  ),
                  const SizedBox(height: 15),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
