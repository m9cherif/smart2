import 'dart:ui';
void main() {
  print(Color(0xFF000000).runtimeType);
  // check if toARGB32 exists
  try {
    print('Checking toARGB32');
  } catch (e) {
    print(e);
  }
}
