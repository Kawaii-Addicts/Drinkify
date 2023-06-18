import 'package:flutter/material.dart';

import '../utils/theming.dart';
import '../models/user.dart';
import '../widgets/profilepage/user_info.dart';
import '../widgets/profilepage/parties.dart';

class ProfilePage extends StatelessWidget {
  final User user;
  const ProfilePage(
    this.user, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theming.bgColor,
      appBar: AppBar(
        backgroundColor: Theming.bgColor,
        title: const Text(
          "Test User",
          style: TextStyle(
            color: Theming.whiteTone,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: const SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(
              left: 30,
              right: 30,
              top: 20,
            ),
            child: Column(
              children: [
                UserInfo(),
                SizedBox(height: 30),
                Parties(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
