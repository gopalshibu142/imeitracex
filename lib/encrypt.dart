import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

String darrEncrypt(String text, String key) {
  String encryptedText = '';
  int keyLength = key.length;
  for (int i = 0; i < text.length; i++) {
    int keyIndex = i % keyLength;
    int keyChar = key.codeUnitAt(keyIndex);
    int encryptedChar = (text.codeUnitAt(i) + keyChar) % 256;
    encryptedText += String.fromCharCode(encryptedChar);
  }
  print(encryptedText);
  darrDecrypt(encryptedText, key);
  return encryptedText;
}

String darrDecrypt(String encryptedText, String key) {
  String decryptedText = '';
  int keyLength = key.length;
  for (int i = 0; i < encryptedText.length; i++) {
    int keyIndex = i % keyLength;
    int keyChar = key.codeUnitAt(keyIndex);
    int decryptedChar = (encryptedText.codeUnitAt(i) - keyChar) % 256;
    decryptedText += String.fromCharCode(decryptedChar);
  }
  print(decryptedText);
  return decryptedText;
}

List<int> stringToBinary(String message) {
  List<int> binaryMessage = [];

  for (int i = 0; i < message.length; i++) {
    int charCode = message.codeUnitAt(i);
    String binary = charCode.toRadixString(2).padLeft(8, '0');

    for (int j = 0; j < binary.length; j++) {
      binaryMessage.add(int.parse(binary[j]));
    }
  }

  return binaryMessage;
}

Uint8List embedMessage(Uint8List videoBytes, List<int> binaryMessage) {
  int messageIndex = 0;

  for (int i = 0; i < videoBytes.length; i++) {
    if (messageIndex >= binaryMessage.length) {
      break; // All message bits have been embedded
    }

    int videoByte = videoBytes[i];
    int messageBit = binaryMessage[messageIndex];

    // Embed the message bit in the least significant bit of the video byte
    int stegoByte = (videoByte & 0xFE) | messageBit;
    videoBytes[i] = stegoByte;

    messageIndex++;
  }

  return videoBytes;
}

Uint8List performSteganography(Uint8List imageData, String message) {
  // Perform your steganography algorithm here
  // This is just a placeholder demonstrating simple LSB (Least Significant Bit) steganography

  final messageBytes = Uint8List.fromList(message.codeUnits);
  final imageLength = imageData.length;
  final messageLength = messageBytes.length;

  if (messageLength > imageLength) {
    throw Exception('Message size exceeds image capacity');
  }

  for (var i = 0; i < messageLength; i++) {
    final imageByte = imageData[i];
    final messageByte = messageBytes[i];

    // Perform LSB steganography by replacing the least significant bit of the image byte with the message byte
    final stegoByte = (imageByte & 0xFE) | (messageByte >> 7 & 0x01);
    imageData[i] = stegoByte;
  }

  return imageData;
}

Future<String> encodeMessage(
    {required MediaCapture media, required msg}) async {
  // Define the input and output file paths
  final videoFilePath =
      media.filePath; // Replace with your video file path
  final outputVideoFilePath =
      media.filePath; // Replace with the desired output video file path
  final message =
      msg; // Replace with the message you want to hide

  // Read the video file
  final videoBytes = File(videoFilePath).readAsBytesSync();
   final flutterFFmpeg = FlutterFFmpeg();
  final Directory? extDir = await getExternalStorageDirectory();
                  final testDir = await Directory('${extDir?.path}/img/${DateTime.now().millisecondsSinceEpoch}')
                      .create(recursive: true);
  // Create the output directory if it doesn't exist


  // Split the video into frames using ffmpeg
  await flutterFFmpeg.execute('-i $videoFilePath ${testDir.path}/frame-%04d.jpg');

  // Get the list of frame files in the output directory
  final frameFiles = Directory(testDir.path)
      .listSync()
      .where((entity) => entity is File && entity.path.endsWith('.jpg'))
      .map((entity) => entity.path)
      .toList();

  // Iterate through each frame and perform steganography
  for (final frameFile in frameFiles) {
    final frameBytes = File(frameFile).readAsBytesSync();

    // Perform image steganography on the frame bytes
    final steganographyBytes = performSteganography(frameBytes, message);

    // Save the modified frame back to the file
    File(frameFile).writeAsBytesSync(steganographyBytes);
  }
  

  // Save the modified video to a file

  return outputVideoFilePath;
}