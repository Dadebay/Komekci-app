/// The server stores a profile photo or banner under one fixed path
/// (`.../accounts/2/avatar_256.jpg`) and overwrites it on every upload, so
/// the URL in the response is the same as before. Flutter caches images by
/// URL, which means the old picture would keep showing after a successful
/// upload.
///
/// Adding a revision to the query string gives the new picture its own cache
/// entry; the server ignores the parameter. A [revision] of 0 means "never
/// replaced in this session" and leaves the URL untouched.
String? withImageRevision(String? url, int revision) {
  if (url == null || url.isEmpty || revision == 0) return url;
  final uri = Uri.tryParse(url);
  if (uri == null) return url;
  return uri.replace(queryParameters: {...uri.queryParameters, 'v': '$revision'}).toString();
}

/// A revision for a picture that was just uploaded.
int newImageRevision() => DateTime.now().millisecondsSinceEpoch;
