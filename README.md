# BitStream

BitStream allows for easy manipulation of long strings of bits, for both reading and writing.

It's easy to get started:

```dart
var bitstream = BitStream();
```

You can also start it with a `Uint8List`:

```dart
var bitstream = BitStream(stream: myBytes);
```

To write to the stream:

```dart
bitstream.write(5,bits: 3); //writes 101 (binary) to the stream
bitstream.writeBool(true); //writes 1 (binary) to the stream
bitstream.writeBytes(Uint8List.fromList(<int>[0,255,127]),bytes:3); //writes 0x00FF7F to the stream
bitstream.output(); //will output 1011000000001111111101111111 to the console
```

Reading is also easy:

```dart
bitstream.read(bits:5); //reads 22 (decimal) from the stream
bitstream.read(bits:11); //reads 15 (decimal) from the stream
bitstream.readBool(); //reads true from the stream
```

## Supported Data Types

| Data Type        | Read Method                      | Write Method                             |
| ---------------- | -------------------------------- | ---------------------------------------- |
| `int`            | `read({bytes, bits})`            | `write(input, {bytes, bits})`            |
| `bool`           | `readBool()`                     | `writeBool(input)`                       |
| `string` (ASCII) | `readAsciiString({bytes, bits})` | `writeAsciiString(input, {bytes, bits})` |
| `string` (HEX)   | `readHexString({bytes, bits})`   | `writeHexString(input, {bytes, bits})`   |
| `Uint8List`      | `readBytes({bytes, bits})`       | `writeBytes(input, {bytes, bits})`       |
| `BitStream`      | `readBitStream({bytes, bits})`   | `writeBitStream(input, {bytes, bits})`   |

## Additional Methods

| Method Name         | Description                                                  |
| ------------------- | ------------------------------------------------------------ |
| `checkBit(int bit)` | Returns a `bool` if a bit is set or not (does not progress the cursor) |
| `output()`          | Prints a binary representation of the current stream to the console |
| `toString()`        | Returns a binary representation of the current stream        |
| `getStream()`       | Gets the current stream data as a `Uint8List`                |
| `getLength()`       | Gets the current length of the stream                        |
| `getCursor()`       | Gets the current cursor position                             |

