/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2020- Scandit AG. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode_capture.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScanditFlutterDataCaptureBarcode.initialize();
  runApp(MyApp());
}

const String licenseKey =
    'AVeAKTsyGhNxQJEEpgVkV0EBEY6rBvsRbUY9M4A3sA1cLy84ei5jXqh1FpVDFctPGEg6ffFeVQG2PrnOsnBPH8VK4+xdQfqVWG/1wSsYqJvcX6Udz0SPyB0Izc4VNiWWnk8ds65/50CjDCkhoFttsDF17ScSCosdYnCjz5RhZ+89W6WuwUITulZx7O2FD+GJJk+ayTFxh5GUFRuge3ECASV9KC3OWPHG1i7hm1UnKmbeCHaV62XThH0sWIjmBLlRPXAxWNhqY5HZPDmlwQdMUmgMuJ6CT8UqnWjThJEijRNtG4w07WoZINFXUhG1colVZ17xaPFAXKf7PBVVrnZtotdR3g/ldlTeLHDxzHdEldemZXl3WEGA6+5K4wOhYdWqGn+wR5Bf5GMaShrfpWIIU6YTx1FvYIXgP1wrQ+B9GIF0eZwRunohEJc6h70yatbdJQat9q8in5V6V6Yg6D2pyA5KiTxdHGQalHui7uNkrnkZT/Ala3wBZT4xMHwla8p/P0zqTBwk8dmUdLG57lI8W3dAV0SoDpi/IcepSnOG1klsFlS5NUVMmiL+UkSkcXBS7POyltbv94ilwmEctTWZL2LU3yjWe8LpC3l8QaEB7ZXNlyAdo41S97C+/g0yHGuziY9OsZrXtZzZbdxfCzvpTaljgi0cdLdSnV+samuFuTasaV4XXWQHbLG1Vnza/UO99qEb0oLTh+pI5hbSVIURGKnwBR5LSZJ6Vm6t5y8WqwYGcqFHo3YNFNELWT5wCOD1Jintu9ND/tQB5TNo0b7XTA6//KeHaycybx8MvDaPZAWpFJp4HM9ADtyfdi/vhaEj20KRhayQjfWLLvUvCnl8xoyWyXGQCP8mg0iya8pbLtRti37DwzE+p1h05ULccIFHsgNt5BG/qLauNmBat+qH3U0Wq9d6ocNYqzg68Img+MjMW7PpMf1irKk75ZXdgOQgynAdxAufHloozKZUbDBTHzCWVAkAm4IU2hwCb+ojwMwMvll8IaqyzR4Qcatbt3wTs3iI8kMMjCT4N9sYvmjaOnxpuft3m56Gfc0gsfupw2eESSnGvYOUtGyWdyoYC33KBvD41Eq+uj0QjwkY0OH7hzPRrO0rc6RYKUrKYYYN7CXkZDRJe33m/u69+IZoHyD35mOmzGNOySTSAgUWwRQAa5sFIulqpeGaVdo9bRpDrQ6HxwUCdMXjj8Pw9lsgS22k1Zm4N5gRyA==';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PlatformApp(
      cupertino: (_, __) => CupertinoAppData(
          theme: CupertinoThemeData(brightness: Brightness.light)),
      home: BarcodeScannerScreen(),
    );
  }
}

class BarcodeScannerScreen extends StatefulWidget {
  // Create data capture context using your license key.
  @override
  State<StatefulWidget> createState() =>
      _BarcodeScannerScreenState(DataCaptureContext.forLicenseKey(licenseKey));
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with WidgetsBindingObserver
    implements BarcodeCaptureListener {
  final DataCaptureContext _context;

  // Use the world-facing (back) camera.
  Camera? _camera = Camera.defaultCamera;
  late BarcodeCapture _barcodeCapture;
  late DataCaptureView _captureView;

  bool _isPermissionMessageVisible = false;

  _BarcodeScannerScreenState(this._context);

  void _checkPermission() {
    Permission.camera.request().isGranted.then((value) => setState(() {
          _isPermissionMessageVisible = !value;
          if (value) {
            _camera?.switchToDesiredState(FrameSourceState.on);
          }
        }));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    // Use the recommended camera settings for the BarcodeCapture mode.
    _camera?.applySettings(BarcodeCapture.recommendedCameraSettings);

    // Switch camera on to start streaming frames and enable the barcode tracking mode.
    // The camera is started asynchronously and will take some time to completely turn on.
    _checkPermission();

    // The barcode capture process is configured through barcode capture settings
    // which are then applied to the barcode capture instance that manages barcode capture.
    var captureSettings = BarcodeCaptureSettings();

    // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
    // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
    // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
    captureSettings.enableSymbologies({
      Symbology.ean13Upca,
      Symbology.upce,
      Symbology.ean8,
      Symbology.code39,
      Symbology.code93,
      Symbology.code128,
      Symbology.code11,
      Symbology.code25,
      Symbology.codabar,
      Symbology.interleavedTwoOfFive,
      Symbology.msiPlessey,
      Symbology.qr,
      Symbology.dataMatrix,
      Symbology.aztec,
      Symbology.maxiCode,
      Symbology.dotCode,
      Symbology.kix,
      Symbology.rm4scc,
      Symbology.gs1Databar,
      Symbology.gs1DatabarExpanded,
      Symbology.gs1DatabarLimited,
      Symbology.pdf417,
      Symbology.microPdf417,
      Symbology.microQr,
      Symbology.code32,
      Symbology.lapa4sc,
      Symbology.iataTwoOfFive,
      Symbology.matrixTwoOfFive,
      Symbology.uspsIntelligentMail
    });

    // Some linear/1d barcode symbologies allow you to encode variable-length data. By default, the Scandit
    // Data Capture SDK only scans barcodes in a certain length range. If your application requires scanning of one
    // of these symbologies, and the length is falling outside the default range, you may need to adjust the "active
    // symbol counts" for this symbology. This is shown in the following few lines of code for one of the
    // variable-length symbologies.
    captureSettings.settingsForSymbology(Symbology.code39).activeSymbolCounts =
        [for (var i = 7; i <= 20; i++) i].toSet();

    // Create new barcode capture mode with the settings from above.
    _barcodeCapture = BarcodeCapture.forContext(_context, captureSettings)
      // Register self as a listener to get informed whenever a new barcode got recognized.
      ..addListener(this);

    // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
    // camera preview. The view must be connected to the data capture context.
    _captureView = DataCaptureView.forContext(_context);

    // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
    // the video preview. This is optional, but recommended for better visual feedback.
    var overlay = BarcodeCaptureOverlay.withBarcodeCaptureForViewWithStyle(
        _barcodeCapture, _captureView, BarcodeCaptureOverlayStyle.frame)
      ..viewfinder = RectangularViewfinder.withStyleAndLineStyle(
          RectangularViewfinderStyle.square,
          RectangularViewfinderLineStyle.light);

    // Adjust the overlay's barcode highlighting to match the new viewfinder styles and improve the visibility of feedback.
    // With 6.10 we will introduce this visual treatment as a new style for the overlay.
    overlay.brush = Brush(
        Color.fromARGB(0, 0, 0, 0), Color.fromARGB(255, 255, 255, 255), 3);

    _captureView.addOverlay(overlay);

    // Set the default camera as the frame source of the context. The camera is off by
    // default and must be turned on to start streaming frames to the data capture context for recognition.
    if (_camera != null) {
      _context.setFrameSource(_camera!);
    }
    _camera?.switchToDesiredState(FrameSourceState.on);
    _barcodeCapture.isEnabled = true;
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isPermissionMessageVisible) {
      child = PlatformText('No permission to access the camera!',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black));
    } else {
      child = _captureView;
    }
    return Center(child: child);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
    } else if (state == AppLifecycleState.paused) {
      _camera?.switchToDesiredState(FrameSourceState.off);
    }
  }

  @override
  void didScan(
      BarcodeCapture barcodeCapture, BarcodeCaptureSession session) async {
    _barcodeCapture.isEnabled = false;
    var code = session.newlyRecognizedBarcodes.first;
    var data = (code.data == null || code.data?.isEmpty == true)
        ? code.rawData
        : code.data;
    var humanReadableSymbology =
        SymbologyDescription.forSymbology(code.symbology);
    await showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
              content: PlatformText(
                'Scanned: $data\n (${humanReadableSymbology.readableName})',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              actions: [
                PlatformDialogAction(
                    child: PlatformText('OK'),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop();
                    })
              ],
            ));
    _barcodeCapture.isEnabled = true;
  }

  @override
  void didUpdateSession(
      BarcodeCapture barcodeCapture, BarcodeCaptureSession session) {}

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _barcodeCapture.removeListener(this);
    _barcodeCapture.isEnabled = false;
    _camera?.switchToDesiredState(FrameSourceState.off);
    _context.removeAllModes();
    super.dispose();
  }
}
