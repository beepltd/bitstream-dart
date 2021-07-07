library bitstream;

import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';

/// Allows bit reading and writing
class BitStream {
  List<int> _stream = <int>[];
  int _bitLength = 0;
  int _cursor = 0;

  /// Initialises with an empty stream or with [stream]
  BitStream({Uint8List? stream}) {
    if (stream != null) {
      _stream = stream;
      _bitLength = _stream.length * 8;
    }
  }

  /// Gets the current cursor position in bits
  int getCursor() {
    return _cursor;
  }

  /// Resets the cursor position
  void resetCursor() {
    _cursor=0;
  }

  /// Gets the current length of the stream in bits
  int getLength() {
    return _bitLength;
  }

  /// Gets the current stream
  Uint8List getStream() {
    return Uint8List.fromList(_stream);
  }

  /// Writes an int to the stream of length [bytes] and [bits]
  void write(int input, {int bytes = 0, int bits = 0}) {
    var len = (bytes * 8) + bits;
    var all = pow(2, len).toInt() - 1;
    input = input & all;
    var thisByte = _bitLength ~/ 8;
    var thisBit = _bitLength % 8;
    while (len > 0) {
      var thisLen = min(len, 8 - thisBit);
      _stream.length = thisByte + 1;
      _stream[thisByte] = 0;
      var shiftAmt = (8 - (thisBit + len));
      _stream[thisByte] = _stream[thisByte] |
          (shiftAmt > 0 ? (input << shiftAmt) : (input >> (0 - shiftAmt)));
      _stream[thisByte] = 255 & _stream[thisByte];
      len -= thisLen;
      _bitLength += thisLen;
      thisBit = 0;
      thisByte++;
    }
  }

  /// Writes a bool to the stream
  void writeBool(bool input) {
    write((input ? 1 : 0), bits: 1);
  }

  /// Writes a byte array to the stream of length [bytes] and [bits]
  void writeBytes(Uint8List input, {int bytes = 0, int bits = 0}) {
    var len = (bytes * 8) + bits;
    var totBytes = len ~/ 8;
    var remBits = len % 8;

    var numBytes = input.lengthInBytes;
    if (remBits > 0) {
      var firstByte = (numBytes - totBytes) - 1;
      write(input[firstByte], bits: remBits);
    }
    for (var x = numBytes - totBytes; x < numBytes; x++) {
      write(input[x], bytes: 1);
    }
  }

  /// Outputs the current stream to the console
  void output() {
    print(toString());
  }

  /// Returns the current stream
  String toString() {
    var str = "";
    for (var b in _stream) {
      str += b.toRadixString(2).padLeft(8, "0");
    }
    return str;
  }

  /// Reads an int from the stream of length [bytes] and [bits]
  int read({int bytes = 0, int bits = 0}) {
    var len = (bytes * 8) + bits;
    var thisByte = _cursor ~/ 8;
    var thisBit = _cursor % 8;
    int output = 0;
    while (len > 0) {
      var thisLen = min(len, 8 - thisBit);
      var all = pow(2, thisLen).toInt() - 1;
      var bit = _stream[thisByte];
      if (thisBit + thisLen < 8) {
        bit = bit >> (8 - (thisBit + thisLen));
      }
      output = output << thisLen | (bit & all);
      len -= thisLen;
      _cursor += thisLen;
      thisBit = 0;
      thisByte++;
    }
    return output;
  }

  /// Reads a bool from the stream
  bool readBool() {
    return read(bits: 1) == 1;
  }

  /// Reads an ASCII string from the stream of length [bytes] and [bits]
  String readAsciiString({int bytes = 0, int bits = 0}) {
    try {
      return new String.fromCharCodes(readBytes(bytes: bytes, bits: bits));
    } on Exception {}
    return "";
  }

  /// Writes an ASCII string to the stream of length [bytes] and [bits]
  void writeAsciiString(String input, {int bytes = 0, int bits = 0}) {
    writeBytes(Uint8List.fromList(input.codeUnits), bytes: bytes, bits: bits);
  }

  /// Reads a HEX string from the stream of length [bytes] and [bits]
  String readHexString({int bytes = 0, int bits = 0}) {
    try {
      return hex.encode(readBytes(bytes: bytes, bits: bits));
    } on Exception {}
    return "";
  }

  /// Writes a HEX string to the stream of length [bytes] and [bits]
  void writeHexString(String input, {int bytes = 0, int bits = 0}) {
    writeBytes(Uint8List.fromList(hex.decode(input)), bytes: bytes, bits: bits);
  }

  /// Checks if [bit] is set or not
  bool checkBit(int bit) {
    bit = (_bitLength - bit) - 1;
    var thisByte = bit ~/ 8;
    var thisBit = bit % 8;
    return (_stream[thisByte] & (1 << (7 - thisBit))) != 0;
  }

  /// Reads a byte array from the stream of length [bytes] and [bits]
  Uint8List readBytes({int bytes = 0, int bits = 0}) {
    var len = (bytes * 8) + bits;
    var totBytes = len ~/ 8;
    var remBits = len % 8;
    List<int> op = <int>[];
    if (remBits > 0) {
      op.add(read(bits: remBits));
    }
    for (int i = 0; i < totBytes; i++) {
      op.add(read(bytes: 1));
    }
    return Uint8List.fromList(op);
  }

  /// Reads a BitStream object from the stream of length [bytes] and [bits]
  BitStream readBitStream({int bytes = 0, int bits = 0}) {
    var op=BitStream();
    op.writeBytes(readBytes(bytes: bytes, bits: bits),bytes: bytes, bits: bits);
    return op;

  }

  /// Reads a BitStream object from the stream of length [bytes] and [bits]
  void writeBitStream(BitStream input, {int bytes = 0, int bits = 0}) {
    writeBytes(input.readBytes(bytes: bytes, bits: bits),bytes: bytes, bits: bits);
  }
}
