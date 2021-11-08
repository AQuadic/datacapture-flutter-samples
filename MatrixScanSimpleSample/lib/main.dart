/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2021- Scandit AG. All rights reserved.
 */

import 'package:MatrixScanSimpleSample/matrix_scan_screen.dart';
import 'package:MatrixScanSimpleSample/scan_results_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScanditFlutterDataCaptureBarcode.initialize();
  runApp(MyApp());
}

const String licenseKey =
    'AVeAKTsyGhNxQJEEpgVkV0EBEY6rBvsRbUY9M4A3sA1cLy84ei5jXqh1FpVDFctPGEg6ffFeVQG2PrnOsnBPH8VK4+xdQfqVWG/1wSsYqJvcX6Udz0SPyB0Izc4VNiWWnk8ds65/50CjDCkhoFttsDF17ScSCosdYnCjz5RhZ+89W6WuwUITulZx7O2FD+GJJk+ayTFxh5GUFRuge3ECASV9KC3OWPHG1i7hm1UnKmbeCHaV62XThH0sWIjmBLlRPXAxWNhqY5HZPDmlwQdMUmgMuJ6CT8UqnWjThJEijRNtG4w07WoZINFXUhG1colVZ17xaPFAXKf7PBVVrnZtotdR3g/ldlTeLHDxzHdEldemZXl3WEGA6+5K4wOhYdWqGn+wR5Bf5GMaShrfpWIIU6YTx1FvYIXgP1wrQ+B9GIF0eZwRunohEJc6h70yatbdJQat9q8in5V6V6Yg6D2pyA5KiTxdHGQalHui7uNkrnkZT/Ala3wBZT4xMHwla8p/P0zqTBwk8dmUdLG57lI8W3dAV0SoDpi/IcepSnOG1klsFlS5NUVMmiL+UkSkcXBS7POyltbv94ilwmEctTWZL2LU3yjWe8LpC3l8QaEB7ZXNlyAdo41S97C+/g0yHGuziY9OsZrXtZzZbdxfCzvpTaljgi0cdLdSnV+samuFuTasaV4XXWQHbLG1Vnza/UO99qEb0oLTh+pI5hbSVIURGKnwBR5LSZJ6Vm6t5y8WqwYGcqFHo3YNFNELWT5wCOD1Jintu9ND/tQB5TNo0b7XTA6//KeHaycybx8MvDaPZAWpFJp4HM9ADtyfdi/vhaEj20KRhayQjfWLLvUvCnl8xoyWyXGQCP8mg0iya8pbLtRti37DwzE+p1h05ULccIFHsgNt5BG/qLauNmBat+qH3U0Wq9d6ocNYqzg68Img+MjMW7PpMf1irKk75ZXdgOQgynAdxAufHloozKZUbDBTHzCWVAkAm4IU2hwCb+ojwMwMvll8IaqyzR4Qcatbt3wTs3iI8kMMjCT4N9sYvmjaOnxpuft3m56Gfc0gsfupw2eESSnGvYOUtGyWdyoYC33KBvD41Eq+uj0QjwkY0OH7hzPRrO0rc6RYKUrKYYYN7CXkZDRJe33m/u69+IZoHyD35mOmzGNOySTSAgUWwRQAa5sFIulqpeGaVdo9bRpDrQ6HxwUCdMXjj8Pw9lsgS22k1Zm4N5gRyA==';

const int scanditBlue = 0xFF58B5C2;
const Map<int, Color> scanditBlueShades = {
  50: Color.fromRGBO(88, 181, 194, .1),
  100: Color.fromRGBO(88, 181, 194, .2),
  200: Color.fromRGBO(88, 181, 194, .3),
  300: Color.fromRGBO(88, 181, 194, .4),
  400: Color.fromRGBO(88, 181, 194, .5),
  500: Color.fromRGBO(88, 181, 194, .6),
  600: Color.fromRGBO(88, 181, 194, .7),
  700: Color.fromRGBO(88, 181, 194, .8),
  800: Color.fromRGBO(88, 181, 194, .9),
  900: Color.fromRGBO(88, 181, 194, 1),
};

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      material: (_, __) => MaterialAppData(
          theme: ThemeData(
        buttonTheme: ButtonThemeData(
            buttonColor: const Color(scanditBlue),
            textTheme: ButtonTextTheme.primary),
        primarySwatch: MaterialColor(scanditBlue, scanditBlueShades),
        primaryIconTheme:
            Theme.of(context).primaryIconTheme.copyWith(color: Colors.white),
        primaryTextTheme: TextTheme(headline6: TextStyle(color: Colors.white)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      )),
      cupertino: (_, __) => CupertinoAppData(
          theme: CupertinoThemeData(brightness: Brightness.light)),
      initialRoute: '/',
      routes: {
        '/': (context) => MatrixScanScreen("MatrixScan Simple", licenseKey),
        '/scanResults': (context) => ScanResultsScreen("Scan Results")
      },
    );
  }
}
