import 'package:camerawesome/pigeon.dart';
import 'package:flutter/material.dart';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'dart:io';
import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:better_open_file/better_open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'dart:typed_data';
import 'package:device_information/device_information.dart';
import 'package:flutter_device_identifier/flutter_device_identifier.dart';
import '';

void main() {
  runApp(const CameraAwesomeApp());
}

class CameraAwesomeApp extends StatelessWidget {
  const CameraAwesomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'camerAwesome',
      home: CameraPage(),
    );
  }
}

class CameraPage extends StatelessWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future<bool> savetoGallary(MediaCapture media) async {
      var str = '';
      var permission = await Permission.phone.status;
      String imei = '';
      PermissionStatus status = await Permission.phone.request();
      try {
        await FlutterDeviceIdentifier.requestPermission();
        imei = await FlutterDeviceIdentifier.imeiCode;
        print(imei);
        str ='imei no :'+ imei;
        var snack = new SnackBar(content: Text(str));
        ScaffoldMessenger.of(context).showSnackBar(snack);
      } catch (e) {
        str = 'couldn\'t fetch imei';
        var snack = new SnackBar(content: Text(str));
        ScaffoldMessenger.of(context).showSnackBar(snack);
      }
      var result;
      if (media.isPicture)
        result = await GallerySaver.saveImage(
            albumName: 'tracex', media.filePath, toDcim: true);
      else
        result = await GallerySaver.saveVideo(
            albumName: 'tracex', media.filePath, toDcim: true);

      if (result!) {
        print('success');
        return true;
      } else {
        print('Error');
        return false;
      }
    }

    //Permission.accessMediaLocation.request();
    return Scaffold(
        body: Container(
            color: Colors.white,
            child: CameraAwesomeBuilder.awesome(
              saveConfig: SaveConfig.photoAndVideo(
                initialCaptureMode: CaptureMode.photo,
                photoPathBuilder: () async {
                  //await Permission.storage;
                  final Directory? extDir = await getExternalStorageDirectory();
                  final testDir = await Directory('${extDir?.path}/test')
                      .create(recursive: true);

                  // File f1 = File(path);

                  return '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
                },
                videoPathBuilder: () async {
                  //await Permission.storage;
                  final Directory? extDir = await getExternalStorageDirectory();
                  final testDir = await Directory('${extDir?.path}/test')
                      .create(recursive: true);

                  // File f1 = File(path);

                  return '${testDir.path}/${DateTime.now().millisecondsSinceEpoch}.mp4';
                },
              ),
              onMediaTap: (mediaCapture) {
                // Hande tap on the preview of the last media captured
                print('Tap on ${mediaCapture.filePath}');
              },
              // Use back camera
              sensor: Sensors.back,
              // Use 1:1 aspect ratio
              aspectRatio: CameraAspectRatios.ratio_1_1,
              // Disable flash
              flashMode: FlashMode.none,
              // No zoom
              zoom: 0.0,
              // Exif settings
              //exifPreferences: ExifPreferences(
              // Save GPS location when taking pictures (no effect with videos)
              // saveGPSLocation: false,
              //),
              // Enable audio when recording a video
              enableAudio: true,
              // Clicking on volume buttons will capture photo/video depending on the current mode
              enablePhysicalButton: true,
              // Don't mirror the front camera
              mirrorFrontCamera: false,
              // Show a progress indicator while loading the camera
              progressIndicator: const Center(
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(),
                ),
              ),
              // Preview fit of the camera
              previewFit: CameraPreviewFit.fitWidth,
              // Image analysis configuration
              imageAnalysisConfig: AnalysisConfig(
                androidOptions: const AndroidAnalysisOptions.nv21(
                  width: 1024,
                ),
                autoStart: true,
              ),
              // Handle image analysis
              // onImageForAnalysis: (analysisImage) {
              // Do some stuff with the image (see example)
              //  return processImage(analysisImage);
              // },
              // Handle gestures on the preview, such as tap to focus or scale to zoom
              onPreviewTapBuilder: (state) => OnPreviewTap(
                onTap: (position, flutterPreviewSize, pixelPreviewSize) {
                  // Handle tap to focus (default) or take a photo for instance
                  // ...
                },
                onTapPainter: (position) {
                  // Tap feedback, here we just show a circle
                  return Positioned(
                    left: position.dx - 25,
                    top: position.dy - 25,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        width: 50,
                        height: 50,
                      ),
                    ),
                  );
                },
                // Duration during which the feedback should be shown
                tapPainterDuration: const Duration(seconds: 2),
              ),
              // Handle scale gestures on the preview
              onPreviewScaleBuilder: (state) => OnPreviewScale(
                onScale: (scale) {
                  // Do something with the scale value, set zoom for instance
                  state.sensorConfig.setZoom(scale);
                },
              ),

              // Add your own decoration on top of the preview
              previewDecoratorBuilder: (state, previewSize, previewRect) {
                // This will be shown above the preview (in a Stack)
                // It could be used in combination with MLKit to draw filters on faces for example
                return Container();
              },
              // CamerAwesome theme used to customize the built-in UI
              theme: AwesomeTheme(
                // Background color of the bottom actions
                bottomActionsBackgroundColor:
                    Colors.deepPurpleAccent.shade400.withOpacity(0.2),
                // Buttons theme
                buttonTheme: AwesomeButtonTheme(
                  // Background color of the buttons
                  backgroundColor: Colors.deepPurple.withOpacity(0.5),
                  // Buttons icon size
                  iconSize: 32,
                  // Padding around icons
                  padding: const EdgeInsets.all(18),
                  // Buttons icon color
                  foregroundColor: Colors.lightBlue,
                  // Tap visual feedback (ripple, bounce...)
                  buttonBuilder: (child, onTap) {
                    return ClipOval(
                      child: Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        child: InkWell(
                          splashColor: Colors.deepPurple,
                          highlightColor: Colors.red,
                          onTap: onTap,
                          child: child,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Filter to apply on the preview
              filter: AwesomeFilter.None,
              // Padding around the preview
              previewPadding: const EdgeInsets.all(20),
              // Alignment of the preview
              previewAlignment: Alignment.center,
              // Bottom actions (take photo, switch camera...)
              bottomActionsBuilder: (state) {
                return AwesomeBottomActions(
                  state: state,
                  onMediaTap: (MediaCapture media) async {
                    var stat = await savetoGallary(media);
                    var msg = '';
                    if (stat)
                      msg = 'saved to gallary';
                    else
                      msg = 'some error has been occured try again';

                    var snack = SnackBar(content: Text(msg));
                    ScaffoldMessenger.of(context).showSnackBar(snack);
                  },
                );
              },
              // Top actions (flash, timer...)
              topActionsBuilder: (state) {
                return AwesomeTopActions(state: state);
              },
              // Middle content (filters, photo/video switcher...)
              middleContentBuilder: (state) {
                // Use this to add widgets on the middle of the preview
                return Column(
                  children: [
                    const Spacer(),
                    AwesomeFilterWidget(state: state),
                    Builder(
                      builder: (context) => Container(
                        color: AwesomeThemeProvider.of(context)
                            .theme
                            .bottomActionsBackgroundColor,
                        height: 8,
                      ),
                    ),
                    AwesomeCameraModeSelector(state: state),
                  ],
                );
              },
            )));
  }
}
