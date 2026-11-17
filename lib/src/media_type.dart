import 'package:http_parser/http_parser.dart';

const Map<String, String> _mimeTypesByExtension = {
  // images
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'gif': 'image/gif',
  'webp': 'image/webp',
  // audio
  'mp3': 'audio/mpeg',
  'wav': 'audio/wav',
  'm4a': 'audio/m4a',
  'ogg': 'audio/ogg',
  'flac': 'audio/flac',
  // video
  'mp4': 'video/mp4',
  'webm': 'video/webm',
  'mov': 'video/quicktime',
  'avi': 'video/x-msvideo',
  // documents
  'pdf': 'application/pdf',
};

/// The content type an uploaded file is sent with.
///
/// The API only accepts uploads whose declared type is on its list, so a
/// part sent as `application/octet-stream` is refused. An explicit
/// [contentType] wins; otherwise the type comes from the filename extension,
/// then from the leading bytes of common formats.
MediaType uploadMediaType(
  String filename,
  List<int> bytes, {
  String? contentType,
}) {
  if (contentType != null && contentType.isNotEmpty) {
    return MediaType.parse(contentType);
  }
  final mime = _mimeTypeForFilename(filename) ?? _mimeTypeForBytes(bytes);
  return MediaType.parse(mime ?? 'application/octet-stream');
}

String? _mimeTypeForFilename(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot < 0 || dot == filename.length - 1) return null;
  return _mimeTypesByExtension[filename.substring(dot + 1).toLowerCase()];
}

String? _mimeTypeForBytes(List<int> bytes) {
  bool startsWith(List<int> prefix, [int offset = 0]) {
    if (bytes.length < offset + prefix.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (bytes[offset + i] != prefix[i]) return false;
    }
    return true;
  }

  if (startsWith([0x89, 0x50, 0x4E, 0x47])) return 'image/png';
  if (startsWith([0xFF, 0xD8, 0xFF])) return 'image/jpeg';
  if (startsWith([0x47, 0x49, 0x46, 0x38])) return 'image/gif';
  if (startsWith([0x25, 0x50, 0x44, 0x46])) return 'application/pdf';
  // RIFF....WEBP / RIFF....WAVE
  if (startsWith([0x52, 0x49, 0x46, 0x46])) {
    if (startsWith([0x57, 0x45, 0x42, 0x50], 8)) return 'image/webp';
    if (startsWith([0x57, 0x41, 0x56, 0x45], 8)) return 'audio/wav';
  }
  return null;
}
