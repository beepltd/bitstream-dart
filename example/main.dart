import 'dart:typed_data';

import 'package:bitstream/bitstream.dart';

void main() {
  var bitstream = BitStream();
  bitstream.write(5, bits: 3); //writes 101 (binary) to the stream
  bitstream.writeBool(true); //writes 1 (binary) to the stream
  bitstream.writeBytes(Uint8List.fromList(<int>[0, 255, 127]),
      bytes: 3); //writes 0x00FF7F to the stream
  bitstream.output(); //will output 1011000000001111111101111111 to the console

  bitstream.read(bits: 5); //reads 22 (decimal) from the stream
  bitstream.read(bits: 11); //reads 15 (decimal) from the stream
  bitstream.readBool(); //reads true from the stream
}
