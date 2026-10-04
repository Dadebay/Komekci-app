import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:komekci/shared/utils/image_compress.dart';

/// A photo-like image that compresses badly: noise over a gradient.
Uint8List noisyJpeg(int width, int height) {
  final random = Random(7);
  final image = img.Image(width: width, height: height);
  for (final p in image) {
    final n = random.nextInt(90);
    p
      ..r = (p.x * 255 ~/ width + n) % 256
      ..g = (p.y * 255 ~/ height + n) % 256
      ..b = ((p.x + p.y) * 255 ~/ (width + height) + n) % 256;
  }
  return Uint8List.fromList(img.encodeJpg(image, quality: 98));
}

void main() {
  test('a large photo is brought under the limit and stays a valid JPEG', () {
    final big = noisyJpeg(3000, 2000);
    expect(big.length, greaterThan(maxUploadBytes));
    final small = shrinkJpeg(big, maxUploadBytes)!;
    expect(small.length, lessThanOrEqualTo(maxUploadBytes));
    final decoded = img.decodeJpg(small)!;
    expect(decoded.width, lessThanOrEqualTo(1600));
    // Aspect ratio survives.
    expect(decoded.width / decoded.height, closeTo(1.5, .02));
  });

  test('compressImageUnder leaves small files alone and rewrites big ones', () async {
    final dir = await Directory.systemTemp.createTemp('komekci_img');
    final smallFile = File('${dir.path}/small.jpg')..writeAsBytesSync(noisyJpeg(200, 200));
    expect((await compressImageUnder(smallFile)).path, smallFile.path);

    final bigFile = File('${dir.path}/big.jpg')..writeAsBytesSync(noisyJpeg(3000, 2000));
    final result = await compressImageUnder(bigFile);
    expect(result.path, isNot(bigFile.path));
    expect(await result.length(), lessThanOrEqualTo(maxUploadBytes));
    await dir.delete(recursive: true);
  });

  test('unreadable data falls back to the original', () async {
    final dir = await Directory.systemTemp.createTemp('komekci_img');
    final junk = File('${dir.path}/junk.jpg')..writeAsBytesSync(Uint8List(maxUploadBytes + 10));
    expect((await compressImageUnder(junk)).path, junk.path);
    await dir.delete(recursive: true);
  });
}
