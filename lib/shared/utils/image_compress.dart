import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Uploads stay below this many bytes (1 MB with some headroom for the
/// multipart envelope).
const maxUploadBytes = 900 * 1024;

/// Returns [file] unchanged when it is already under [maxBytes]; otherwise a
/// JPEG copy re-encoded at a lower quality and, if that is not enough,
/// smaller dimensions until it fits. Falls back to the original file if the
/// image cannot be decoded.
Future<File> compressImageUnder(File file, {int maxBytes = maxUploadBytes}) async {
  if (await file.length() <= maxBytes) return file;
  final bytes = await file.readAsBytes();
  final shrunk = await Isolate.run(() => shrinkJpeg(bytes, maxBytes));
  if (shrunk == null) return file;
  final out = File(
    '${Directory.systemTemp.path}/komekci_${DateTime.now().microsecondsSinceEpoch}.jpg',
  );
  return out.writeAsBytes(shrunk);
}

/// Pure function behind [compressImageUnder] (exposed for tests).
///
/// Tries qualities from high to low at the current size, then shrinks the
/// longest edge by 20% and tries again, down to a 480 px edge.
Uint8List? shrinkJpeg(Uint8List bytes, int maxBytes) {
  final decoded = img.decodeImage(bytes);
  if (decoded == null) return null;
  final source = img.bakeOrientation(decoded);
  var edge = source.width > source.height ? source.width : source.height;
  edge = edge > 1600 ? 1600 : edge;

  Uint8List? best;
  while (edge >= 480) {
    final image = _fit(source, edge);
    for (final quality in const [85, 75, 65, 55, 45]) {
      final encoded = Uint8List.fromList(img.encodeJpg(image, quality: quality));
      best = encoded;
      if (encoded.length <= maxBytes) return encoded;
    }
    edge = (edge * 0.8).round();
  }
  return best;
}

img.Image _fit(img.Image source, int edge) {
  final longest = source.width > source.height ? source.width : source.height;
  if (longest <= edge) return source;
  return source.width >= source.height
      ? img.copyResize(source, width: edge, interpolation: img.Interpolation.average)
      : img.copyResize(source, height: edge, interpolation: img.Interpolation.average);
}
