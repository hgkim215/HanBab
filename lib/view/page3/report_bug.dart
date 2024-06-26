import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:han_bab/color_schemes.dart';
import 'package:han_bab/service/setting_service.dart';
import 'package:han_bab/widget/appBar.dart';

class ReportBug extends StatelessWidget {
  const ReportBug({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final settingService = SettingService();

    return Scaffold(
      body: Column(
        children: [
          appbar(context, "고객센터"),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 50, 30, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 34.0),
                    child: Text(
                      "불편하신 점이 있으신가요?",
                      style: TextStyle(
                        color: Color(0xff3E3E3E),
                        fontSize: 24,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      '이용 중 불편한 점이나 문의 사항을 알려주세요!',
                      style: TextStyle(
                        color: Color(0xff717171),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      '확인 후 신속 정확하게 답변 드리도록 하겠습니다 :)',
                      style: TextStyle(
                        color: Color(0xff717171),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5),
                    child: Text(
                      '평일 (월-금) 10:00 ~ 18:00, 주말 및 공휴일 휴무',
                      style: TextStyle(
                        color: Color(0xff717171),
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 59,
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                            backgroundColor: lightColorScheme.primary,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.all(14),
                          ),
                          onPressed: () {
                            settingService.sendEmail(context);
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "이메일 보내기",
                                style: TextStyle(color: Colors.white, fontSize: 16),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(
                                CupertinoIcons.chevron_forward,
                                color: Colors.white,
                                size: 13,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
