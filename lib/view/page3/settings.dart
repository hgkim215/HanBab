import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:han_bab/widget/appBar.dart';
import 'package:path_provider/path_provider.dart';

import '../../widget/PDFScreen.dart';
import '../../widget/customToolbarShape.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  String termsPDF = "";
  String personalPDF = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fromAsset('assets/pdf/terms.pdf', 'terms.pdf').then((f) {
      setState(() {
        termsPDF = f.path;
      });
    });
    fromAsset('assets/pdf/personal2.pdf', 'personal2.pdf').then((f) {
      // 수정
      setState(() {
        personalPDF = f.path;
      });
    });
  }

  Future<File> fromAsset(String asset, String filename) async {
    // To open from assets, you can copy them to the app storage folder, and the access them "locally"
    Completer<File> completer = Completer();

    try {
      var dir = await getApplicationDocumentsDirectory();
      File file = File("${dir.path}/$filename");
      var data = await rootBundle.load(asset);
      var bytes = data.buffer.asUint8List();
      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: appbar(context, "환경설정"),
      body: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (termsPDF.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFScreen(path: termsPDF),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25.0, 5, 0, 25),
              child: Row(
                children: [
                  Image.asset(
                    "./assets/icons/settings1.png",
                    scale: 2,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Text(
                    "이용약관",
                    style: TextStyle(
                        fontFamily: "PretendardMedium",
                        fontSize: 18,
                        color: Color(0xff313131)),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            height: 0,
            color: Color(0xffEDEDED),
          ),
          GestureDetector(
            onTap: () {
              if (personalPDF.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFScreen(path: personalPDF),
                  ),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 25, bottom: 25),
              child: Row(
                children: [
                  Image.asset(
                    "./assets/icons/settings2.png",
                    scale: 2,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Text(
                    "개인정보처리방침",
                    style: TextStyle(
                        fontFamily: "PretendardMedium",
                        fontSize: 18,
                        color: Color(0xff313131)),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            height: 0,
            color: Color(0xffEDEDED),
          ),
          GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(left: 25.0, top: 25, bottom: 25),
              child: Row(
                children: [
                  Image.asset(
                    "./assets/icons/settings3.png",
                    scale: 2,
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  const Text(
                    "알림설정",
                    style: TextStyle(
                        fontFamily: "PretendardMedium",
                        fontSize: 18,
                        color: Color(0xff313131)),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
            height: 0,
            color: Color(0xffEDEDED),
          ),
        ],
      ),
    );
  }
}
