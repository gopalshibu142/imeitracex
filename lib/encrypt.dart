import 'dart:io';
import 'dart:convert';


List<int> encodeMessage({required videoPath,required message}) {
 
  // Read video frames
  List<int> videoBytes = File(videoPath).readAsBytesSync();

  // Encode the message in video frames
  List<int> encodedBytes = [];

  // Save the encoded video frames to a new file
  File encodedVideo = File('path_to_encoded_video.mp4');
  encodedVideo.writeAsBytesSync(encodedBytes);

  // Convert the message to bytes
  List<int> messageBytes = utf8.encode(message);

  int messageLength = messageBytes.length;

  // XOR encryption key
  int key = 42;

  // Encode the message length in the first 4 bytes of the video frames
  encodedBytes.addAll(encodeIntInBytes(messageLength));

  // XOR encrypt and encode the message bytes in the video frames
  for (int i = 0; i < videoBytes.length; i++) {
    int videoByte = videoBytes[i];

    if (i < messageBytes.length) {
      // XOR encrypt the message byte with the key
      int encryptedByte = messageBytes[i] ^ key;
      encodedBytes.add(encryptedByte);
    } else {
      // Copy the remaining video bytes as is
      encodedBytes.add(videoByte);
    }
  }

  return encodedBytes;
}

List<int> encodeIntInBytes(int value) {
  List<int> bytes = [];

  // Encode the integer value in 4 bytes
  bytes.add((value >> 24) & 0xFF);
  bytes.add((value >> 16) & 0xFF);
  bytes.add((value >> 8) & 0xFF);
  bytes.add(value & 0xFF);

  return bytes;
}
