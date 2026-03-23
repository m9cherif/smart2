import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('logo.png');
  if (!file.existsSync()) {
    print('logo.png not found');
    return;
  }
  
  final bytes = file.readAsBytesSync();
  final image = img.decodeImage(bytes);
  if (image == null) {
    print('Failed to decode image');
    return;
  }
  
  // Resize correctly to 256x256
  final resized = img.copyResize(image, width: 256, height: 256);
  
  // Try to encode as ICO.
  try {
    final icoBytes = img.encodeIco(resized);
    File('windows/runner/resources/app_icon.ico').writeAsBytesSync(icoBytes);
    print('Successfully generated app_icon.ico (size: ${icoBytes.length})');
  } catch(e) {
    print('Failed to encode ICO: $e');
  }
}
