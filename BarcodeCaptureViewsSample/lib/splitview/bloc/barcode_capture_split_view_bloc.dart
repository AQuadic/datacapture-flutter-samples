/*
 * This file is part of the Scandit Data Capture SDK
 *
 * Copyright (C) 2020- Scandit AG. All rights reserved.
 */

import 'dart:async';
import 'dart:ui';

import 'package:BarcodeCaptureViewsSample/bloc/bloc_base.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode.dart';
import 'package:scandit_flutter_datacapture_barcode/scandit_flutter_datacapture_barcode_capture.dart';
import 'package:scandit_flutter_datacapture_core/scandit_flutter_datacapture_core.dart';

class BarcodeCaptureSplitBloc extends Bloc implements BarcodeCaptureListener {
  final DataCaptureContext _captureContext;

  late BarcodeCapture _barcodeCapture;

  // Use the world-facing (back) camera.
  Camera? _camera = Camera.defaultCamera;

  late DataCaptureView _captureView;

  Timer? _timer;

  StreamController<List<Barcode>> _capturedBarcodesStreamController =
      StreamController();

  Stream<List<Barcode>> get capturedBarcodes =>
      _capturedBarcodesStreamController.stream;

  StreamController<bool> _isCapturingStreamController = StreamController();

  Stream<bool> get isCapturing => _isCapturingStreamController.stream;

  final List<Barcode> _capturedBarcodes = [];

  BarcodeCaptureSplitBloc(this._captureContext) {
    _init();
  }

  void _init() {
    // Use the recommended camera settings for the BarcodeCapture mode.
    _camera?.applySettings(BarcodeCapture.recommendedCameraSettings);

    // To visualize the on-going barcode capturing process on screen, setup a data capture view that renders the
    // camera preview. The view must be connected to the data capture context.
    _captureView = DataCaptureView.forContext(_captureContext);

    // Create new barcode capture mode with the settings from above.
    _barcodeCapture = BarcodeCapture.forContext(
        _captureContext, barcodeCaptureSettings)
      // Register self as a listener to get informed whenever a new barcode gets recognized.
      ..addListener(this);

    // Add a barcode capture overlay to the data capture view to render the location of captured barcodes on top of
    // the video preview. This is optional, but recommended for better visual feedback.
    var overlay = BarcodeCaptureOverlay.withBarcodeCaptureForViewWithStyle(
        _barcodeCapture, _captureView, BarcodeCaptureOverlayStyle.frame)
      ..viewfinder =
          LaserlineViewfinder.withStyle(LaserlineViewfinderStyle.animated);

    // Adjust the overlay's barcode highlighting to match the new viewfinder styles and improve the visibility of feedback.
    // With 6.10 we will introduce this visual treatment as a new style for the overlay.
    overlay.brush = Brush(
        Color.fromARGB(0, 0, 0, 0), Color.fromARGB(255, 255, 255, 255), 3);

    _captureView.addOverlay(overlay);

    // Set the default camera as the frame source of the context. The camera is off by
    // default and must be turned on to start streaming frames to the data capture context for recognition.
    if (_camera != null) {
      _captureContext.setFrameSource(_camera!);
    }
    switchCameraOn();
    _barcodeCapture.isEnabled = true;
  }

  BarcodeCaptureSettings get barcodeCaptureSettings {
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

    // In order not to pick up barcodes outside of the view finder,
    // restrict the code location selection to match the laser line's center.
    captureSettings.locationSelection =
        RadiusLocationSelection(DoubleWithUnit(0, MeasureUnit.fraction));

    // Setting the code duplicate filter to one thousand milliseconds means that the scanner
    // won't report the same code as recognized for one second once it's recognized.
    captureSettings.codeDuplicateFilter = Duration(milliseconds: 1000);

    return captureSettings;
  }

  DataCaptureView get captureView => _captureView;

  void clearCapturedBarcodes() {
    _capturedBarcodes.clear();
    _capturedBarcodesStreamController.sink.add(_capturedBarcodes);
  }

  void resumeCapturing() {
    _isCapturingStreamController.sink.add(true);
    switchCameraOn();
  }

  void switchCameraOff() {
    _camera?.switchToDesiredState(FrameSourceState.off);
  }

  void switchCameraOn() {
    _resetPauseCameraTimer();
    _camera?.switchToDesiredState(FrameSourceState.on);
  }

  @override
  void didScan(BarcodeCapture barcodeCapture, BarcodeCaptureSession session) {
    // TODO: implement didScan
  }

  @override
  void didUpdateSession(
      BarcodeCapture barcodeCapture, BarcodeCaptureSession session) {
    if (session.newlyRecognizedBarcodes.isEmpty) return;

    _storeAndNotifyNewBarcode(session.newlyRecognizedBarcodes.first);
  }

  @override
  void dispose() {
    switchCameraOff();
    _barcodeCapture.removeListener(this);
    _timer?.cancel();
    _capturedBarcodesStreamController.close();
    _isCapturingStreamController.close();
  }

  void _storeAndNotifyNewBarcode(Barcode barcode) {
    _resetPauseCameraTimer();
    _capturedBarcodes.add(barcode);
    _capturedBarcodesStreamController.sink.add(_capturedBarcodes);
  }

  void _resetPauseCameraTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 10), () {
      _camera?.switchToDesiredState(FrameSourceState.off);
      _isCapturingStreamController.sink.add(false);
    });
  }
}
