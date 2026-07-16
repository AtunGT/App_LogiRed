import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:google_maps_flutter/google_maps_flutter.dart';

Future<BitmapDescriptor> _loadScaled(String asset, double height) async {
  final data = await rootBundle.load(asset);
  final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
  final image = (await codec.getNextFrame()).image;

  final srcW = image.width.toDouble();
  final srcH = image.height.toDouble();
  final dstH = height;
  final dstW = srcW * (dstH / srcH);

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, dstW, dstH));
  canvas.drawImageRect(
    image,
    Rect.fromLTWH(0, 0, srcW, srcH),
    Rect.fromLTWH(0, 0, dstW, dstH),
    Paint()..filterQuality = FilterQuality.high,
  );

  final picture = recorder.endRecording();
  final out = await picture.toImage(dstW.round(), dstH.round());
  final png = await out.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  picture.dispose();
  out.dispose();
  return BitmapDescriptor.bytes(png!.buffer.asUint8List());
}

Future<BitmapDescriptor> buildCarMarker({double height = 64}) =>
    _loadScaled('assets/images/carro_ del_mapa.png', height);
