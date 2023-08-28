import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:smartpay/ir/data/themes.dart';

/// Usage example
///   void _takePicture(BuildContext context) async {
///     final XFile file = await Navigator.push(
///       context,
///       MaterialPageRoute(
///         builder: (context) => const TakePictureScreen(
///           onPictureTaken: ...
///         ),
///       ),
///     );
///     //var resId =
///     await _postDocument(file);
///   }
///
class TakePictureWidget extends StatefulWidget {
  // Function that returns the picture taken
  final Function(XFile)? onPictureTaken;
  final double? cWidth;
  final double? cHeight;
  final CameraLensDirection? cameraLensDirection;

  const TakePictureWidget({
    super.key,
    this.onPictureTaken,
    this.cWidth,
    this.cHeight,
    this.cameraLensDirection,
  });

  @override
  State<TakePictureWidget> createState() => _TakePictureWidgetState();
}

class _TakePictureWidgetState extends State<TakePictureWidget> {
  late CameraController _controller;
  CameraLensDirection _cameraLensDirection = CameraLensDirection.back;
  Future<void>? _initializeControllerFuture;
  late XFile _imageFile;

  @override
  void initState() {
    super.initState();
    if (widget.cameraLensDirection != null) {
      _cameraLensDirection = widget.cameraLensDirection!;
    }
    availableCameras().then((cameras) {
      var cameraDescription = cameras.firstWhere(
        (element) {
          return element.lensDirection == _cameraLensDirection;
        },
        orElse: () => cameras.first,
      );

      _controller = CameraController(
        cameraDescription,
        // Define the resolution to use.
        // Available resolutions: Low, medium, high, veryHigh, ultraHigh.
        ResolutionPreset.veryHigh,
      );
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    });
  }

  // On click on anything other than this widget, dispose the controller and pop the screen.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<XFile> _takePicture() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      return image;
    } catch (e) {
      throw Exception('Error taking picture!');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_initializeControllerFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            color: kLightGrey,
            width: widget.cWidth ?? double.infinity,
            height: widget.cHeight ?? double.infinity,
            padding: const EdgeInsets.all(0),
            child: buildCamera(context),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  /// Camera widget
  /// Retourne la camera dans un container avec un cadre.
  /// Le cadre n'est visible que sur les angles du container
  /// Ensuite, marge est ajoutée entre la camera et le cadre
  /// La marge bu bas est plus grande pour laisser de la place aux boutons
  /// Le bouton est circulaire et centré en bas avec une image d'appareil photo
  ///
  Widget buildCamera(BuildContext context) {
    return Stack(children: [
      ..._buildBorder(context),
      Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: kGrey.withOpacity(0.3),
          //border: Border.all(
          //color: kGrey,
          //width: 3,
          //),
          //border: Border(
          //top: BorderSide(color: kGrey, width: 3, height: 10),
          //left: BorderSide(color: kGrey, width: 3),
          //right: BorderSide(color: kGrey, width: 3),
          //bottom: BorderSide(color: kGrey, width: 10),
          //),
          //borderRadius: BorderRadius.circular(0),
        ),
        child: ClipRect(
          child: OverflowBox(
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: CameraPreview(_controller),
              ),
            ),
          ),
        ),
      ),
      // Bouton caméra flottan centré en bas dans un cercle dont le diamètre est traversé par le cadre
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 30),
          width: 70,
          height: 70,
          child: FloatingActionButton(
            backgroundColor: kGreen,
            foregroundColor: Colors.white,
            shape: const CircleBorder(),
            onPressed: () async {
              final image = await _takePicture();
              if (widget.onPictureTaken != null) {
                widget.onPictureTaken!(image);
                return;
              }
              setState(() {
                _imageFile = image;
              });
              if (context.mounted) {
                Navigator.pop(context, _imageFile);
              }
            },
            child: const Icon(Icons.camera_alt),
          ),
        ),
      ),
    ]);
  }

  /// Build the border of the camera
  /// The border is a container with a border on each side
  ///
  List<Widget> _buildBorder(BuildContext context) {
    var borderHeight = 30.0;
    var borderWidth = 3.0;
    return [
      // Bordure de gauche sur le coin supérieur gauche
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: borderWidth,
          height: borderHeight,
          color: kGrey,
        ),
      ),
      // Bordure de gauche sur le coin inférieur gauche
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: borderWidth,
          height: borderHeight,
          color: kGrey,
        ),
      ),
      // Bordure de haut sur le coin supérieur gauche
      Positioned(
        top: 0,
        left: 0,
        child: Container(
          width: borderHeight,
          height: borderWidth,
          color: kGrey,
        ),
      ),
      // Bordure de haut sur le coin supérieur droit
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: borderHeight,
          height: borderWidth,
          color: kGrey,
        ),
      ),
      // Bordure de droite sur le coin supérieur droit
      Positioned(
        top: 0,
        right: 0,
        child: Container(
          width: borderWidth,
          height: borderHeight,
          color: kGrey,
        ),
      ),
      // Bordure de droite sur le coin inférieur droit
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: borderWidth,
          height: borderHeight,
          color: kGrey,
        ),
      ),
      // Bordure de bas sur le coin inférieur gauche
      Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: borderHeight,
          height: borderWidth,
          color: kGrey,
        ),
      ),
      // Bordure de bas sur le coin inférieur droit
      Positioned(
        bottom: 0,
        right: 0,
        child: Container(
          width: borderHeight,
          height: borderWidth,
          color: kGrey,
        ),
      ),
    ];
  }
}
