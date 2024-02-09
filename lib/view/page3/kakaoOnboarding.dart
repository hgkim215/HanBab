import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:han_bab/view/page3/profile.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:han_bab/controller/navigation_controller.dart';
import 'package:provider/provider.dart';

class KakaoOnboarding extends StatelessWidget {
  const KakaoOnboarding({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: '카카오톡 접속',
          body: "카카오톡에 접속 후 하단의 5개의 버튼 중"
              "\n5번째 버튼(…)을 눌러 더보기란으로 이동하고"
              "\n우측 상단 버튼을 클릭합니다.",
          image: Image.asset('assets/images/kakao_onboarding1.png'),
          decoration: getPageDecorationCut(screenWidth),
        ),
        PageViewModel(
          title: '송금코드 생성',
          body: "코드를 스캔하는 카메라가 뜨는 화면에서"
              "\n하단의 '송금코드' 버튼을 클릭합니다.",
          image: Image.asset('assets/images/kakao_onboarding2.png'),
          decoration: getPageDecorationCut(screenWidth),
        ),
        PageViewModel(
          title: '링크 복사',
          image: Image.asset('assets/images/kakao_onboarding3.png'),
          body: "위의 화면에서 표시된 버튼을 눌러"
              "\n카카오 송금 링크를 복사하면 끝!",
          decoration: getPageDecorationCut(screenWidth),
        ),
      ],
      done: const Text(
        '완료',
        style: TextStyle(
          fontSize: 17,
          color: Color.fromARGB(255, 255, 215, 0),
        ),
      ),
      onDone: () {
        Navigator.of(context).pop();
      },
      next: const Icon(
        Icons.arrow_forward_ios,
        color: Color.fromARGB(255, 255, 215, 0),
        size: 24.0,
      ),
      showBackButton: true,
      back: const Icon(
        Icons.arrow_back_ios,
        color: Color.fromARGB(255, 255, 215, 0),
        size: 24.0,
      ),
      dotsDecorator: DotsDecorator(
        color: Colors.yellowAccent,
        size: const Size(10, 10),
        activeSize: const Size(20, 10),
        activeColor: Color.fromARGB(255, 255, 204, 000),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      curve: Curves.easeInQuad,
    );
  }

  PageDecoration getPageDecorationCut(double screenWidth) {
    return PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 255, 204, 000),
      ),
      titlePadding: EdgeInsets.only(bottom: 0),
      bodyTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Color.fromARGB(255, 255, 204, 000),
      ),
      bodyPadding: EdgeInsets.only(bottom: screenWidth * 0.3),
      imageAlignment: Alignment.topCenter,
      imagePadding: EdgeInsets.only(top: screenWidth * 0.12),
      imageFlex: 5,
      pageColor: Colors.white60,
    );
  }
}
