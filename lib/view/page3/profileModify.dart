import 'package:flutter/material.dart';
import 'package:han_bab/color_schemes.dart';
import 'package:han_bab/database/databaseService.dart';

import '../../widget/encryption.dart';

class ProfileModify extends StatefulWidget {
  const ProfileModify(
      {Key? key,
      required this.name,
      required this.email,
      required this.phone,
      required this.account})
      : super(key: key);

  final String name;
  final String email;
  final String phone;
  final String account;

  @override
  State<ProfileModify> createState() => _ProfileModifyState();
}

class _ProfileModifyState extends State<ProfileModify> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController accountController = TextEditingController();

  @override
  void initState() {
    nameController = TextEditingController(text: widget.name);
    emailController = TextEditingController(text: widget.email);
    phoneController = TextEditingController(text: widget.phone);
    accountController = TextEditingController(
        text: AccountEncryption.decryptWithAESKey(widget.account));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("프로필 관리"),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xffF97E13),
                  Color(0xffFFCD96),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 30, 24, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("내 정보 변경"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 3.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 24,
                          ),
                          TextFormField(
                            enabled: false,
                            controller: nameController,
                            onChanged: (value) {
                              setState(() {
                                nameController.text = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          TextFormField(
                            controller: emailController,
                            onChanged: (value) {
                              setState(() {
                                emailController.text = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          TextFormField(
                            controller: phoneController,
                            onChanged: (value) {
                              setState(() {
                                phoneController.text = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          TextFormField(
                            controller: accountController,
                            onChanged: (value) {
                              setState(() {
                                accountController.text = value;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      DatabaseService().modifyUserInfo(
                          nameController.text,
                          emailController.text,
                          phoneController.text,
                          accountController.text);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('정보가 변경되었습니다.'),
                        duration: Duration(seconds: 5),
                      ));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: lightColorScheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        "저장하기",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
