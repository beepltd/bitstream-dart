library bitstream;

import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';


class BitStream {
  List<int> _stream = <int>[];
  int _bitLength = 0;
  int _cursor = 0;

  BitStream({Uint8List stream}) {
    if (stream != null) {
      _stream = stream;
      _bitLength = _stream.length * 8;
    }
  }

  int getCursor() {
    return _cursor;
  }

  int getLength() {
    return _bitLength;
  }

  Uint8List getStream() {
    return Uint8List.fromList(_stream);
  }

  void write(int input, {int bytes = 0, int bits = 0}) {
    var len = (bytes * 8) + bits;
    var all = pow(2, len) - 1;
    input = input & all;
    var thisByte = _bitLength ~/ 8;
    var thisBit = _bitLength % 8;
    while (len > 0) {
      var thisLen = min(len, 8 - thisBit);
      _stream.length = thisByte + 1;
      if (_stream[thisByte] == null) {
        _stream[thisByte] = 0;
      }
      var shiftAmt = (8 - (thisBit + len));
      _stream[thisByte] =
      _stream[thisByte] | (shiftAmt > 0 ? (input << shiftAmt) : (input >>
          (0 - shiftAmt)));
      _stream[thisByte] = 255 & _stream[thisByte];
      len -= thisLen;
      _bitLength += thisLen;
      thisBit = 0;
      thisByte++;
    }
  }

  void writeBool(bool input) {
    write((input ? 1 : 0), bits: 1);
  }

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

  void output() {
    print(toString());
  }


  String toString() {
    var str = "";
    for (var b in _stream) {
      str += b.toRadixString(2).padLeft(8, "0");
    }
    return str;
  }

  int read({int bytes = 0, int bits = 0}) {
    var len = (bytes * 8) + bits;
    var thisByte = _cursor ~/ 8;
    var thisBit = _cursor % 8;
    int output = 0;
    while (len > 0) {
      var thisLen = min(len, 8 - thisBit);
      var all = pow(2, thisLen) - 1;
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

  bool readBool() {
    return read(bits: 1) == 1;
  }

  String readAsciiString({int bytes = 0, int bits = 0}) {
    try {
      return new String.fromCharCodes(readBytes(bytes: bytes, bits: bits));
    } on Exception {
    }
    return "";
  }

  void writeAsciiString(String input,{int bytes = 0, int bits = 0}) {
    writeBytes(Uint8List.fromList(input.codeUnits),bytes: bytes, bits: bits);
  }

  String readHexString({int bytes = 0, int bits = 0}) {
    try {
      return hex.encode(readBytes(bytes: bytes, bits: bits));
    } on Exception {
    }
    return "";
  }

  void writeHexString(String input,{int bytes = 0, int bits = 0}) {
    writeBytes(hex.decode(input),bytes: bytes, bits: bits);
  }

  bool checkBit(int bit) {
    bit=(_bitLength-bit)-1;
    var thisByte = bit ~/ 8;
    var thisBit = bit % 8;
    return (_stream[thisByte] & (1 << (7-thisBit))) != 0;
  }

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

  BitStream readBitStream({int bytes = 0, int bits = 0}) {
    return BitStream(stream: readBytes(bytes:bytes, bits:bits));
}

}
