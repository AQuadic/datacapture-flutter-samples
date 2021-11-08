/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2021- Scandit AG. All rights reserved.
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode_selection.dart';
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
    return MaterialApp(
      home: BarcodeSelectionScreen(),
    );
  }
}

class BarcodeSelectionScreen extends StatefulWidget {
  // Create data capture context using your license key.
  @override
  State<StatefulWidget> createState() => _BarcodeSelectionScreenState(
      DataCaptureContext.forLicenseKey(licenseKey));
}

class _BarcodeSelectionScreenState extends State<BarcodeSelectionScreen>
    with WidgetsBindingObserver
    implements BarcodeSelectionListener {
  final DataCaptureContext _context;

  // Use the world-facing (back) camera.
  Camera? _camera = Camera.defaultCamera;
  late BarcodeSelection _barcodeSelection;
  late DataCaptureView _captureView;
  late BarcodeSelectionSettings _selectionSettings;
  int _currentIndex = 0;

  bool _isPermissionMessageVisible = false;

  _BarcodeSelectionScreenState(this._context);

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

    // Use the recommended camera settings for the BarcodeSelection mode.
    _camera?.applySettings(BarcodeSelection.recommendedCameraSettings);

    // Switch camera on to start streaming frames and enable the barcode selection mode.
    // The camera is started asynchronously and will take some time to completely turn on.
    _checkPermission();

    // The barcode selection process is configured through barcode selection settings
    // which are then applied to the barcode selection instance that manages barcode recognition.
    _selectionSettings = BarcodeSelectionSettings();

    // The settings instance initially has all types of barcodes (symbologies) disabled. For the purpose of this
    // sample we enable a very generous set of symbologies. In your own app ensure that you only enable the
    // symbologies that your app requires as every additional enabled symbology has an impact on processing times.
    _selectionSettings.enableSymbologies({
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

    // Create new barcode selection mode with the settings created above.
    _barcodeSelection =
        BarcodeSelection.forContext(_context, _selectionSettings);

    // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
    // camera preview. The view must be connected to the data capture context.
    _captureView = DataCaptureView.forContext(_context);

    // Add a barcode selection overlay to the data capture view to render the location of captured barcodes on top of the video preview.
    // This is optional, but recommended for better visual feedback.
    var overlay = BarcodeSelectionBasicOverlay.withBarcodeSelectionForView(
        _barcodeSelection, _captureView);

    _captureView.addOverlay(overlay);

    // Set the default camera as the frame source of the context. The camera is off by
    // default and must be turned on to start streaming frames to the data capture context for recognition.
    if (_camera != null) {
      _context.setFrameSource(_camera!);
    }
    _camera?.switchToDesiredState(FrameSourceState.on);
    _barcodeSelection.isEnabled = true;
    // Register self as a listener to get informed whenever a new barcode got recognized.
    _barcodeSelection.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    Widget child;
    if (_isPermissionMessageVisible) {
      child = Text('No permission to access the camera!',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black));
    } else {
      child = _captureView;
    }
    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.qr_code),
            label: 'Tap to Select',
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.qr_code),
            label: 'Aim to Select',
          )
        ],
        onTap: (int index) {
          setState(() {
            // Update selection type and apply new settings
            if (index == 0) {
              _selectionSettings.selectionType = BarcodeSelectionTapSelection();
            } else {
              _selectionSettings.selectionType =
                  BarcodeSelectionAimerSelection();
            }
            _barcodeSelection.applySettings(_selectionSettings);
            _currentIndex = index;
          });
        },
        selectedIconTheme: IconThemeData(opacity: 0.0, size: 0),
        unselectedIconTheme: IconThemeData(opacity: 0.0, size: 0),
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white,
      ),
    );
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
  void didUpdateSelection(BarcodeSelection barcodeSelection,
      BarcodeSelectionSession session) async {
    // Check if we have selected a barcode, if that's the case, show a snackbar with its info.
    var newlySelectedBarcodes = session.newlySelectedBarcodes;
    if (newlySelectedBarcodes.isEmpty) return;

    // Get the human readable name of the symbology and assemble the result to be shown.
    var barcode = newlySelectedBarcodes.first;
    var symbologyReadableName =
        SymbologyDescription.forSymbology(barcode.symbology).readableName;

    var selectionCount = await session.getCount(barcode);

    final result =
        '${symbologyReadableName}: ${barcode.data} \nTimes: ${selectionCount}';

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(result),
      duration: Duration(milliseconds: 500),
    ));
  }

  @override
  void didUpdateSession(
      BarcodeSelection barcodeCapture, BarcodeSelectionSession session) {}

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _barcodeSelection.removeListener(this);
    _barcodeSelection.isEnabled = false;
    _camera?.switchToDesiredState(FrameSourceState.off);
    _context.removeAllModes();
    super.dispose();
  }
}
