part of dart._engine;
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.




/// Instantiates a [ui.Codec] backed by an `SkAnimatedImage` from Skia.
// TODO(yjbanov): Implement targetWidth and targetHeight support.
//                https://github.com/flutter/flutter/issues/34075
FutureOr<ui.Codec> skiaInstantiateImageCodec(Uint8List list,
    [int? targetWidth, int? targetHeight]) {
  if (browserSupportsImageDecoder) {
    return CkBrowserImageDecoder.create(
      data: list,
      debugSource: 'encoded image bytes',
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
  } else {
    return CkAnimatedImage.decodeFromBytes(list, 'encoded image bytes');
  }
}

// TODO(yjbanov): add support for targetWidth/targetHeight (https://github.com/flutter/flutter/issues/34075)
void skiaDecodeImageFromPixels(
  Uint8List pixels,
  int width,
  int height,
  ui.PixelFormat format,
  ui.ImageDecoderCallback callback, {
  int? rowBytes,
  int? targetWidth,
  int? targetHeight,
  bool allowUpscaling = true,
}) {
  // Run in a timer to avoid janking the current frame by moving the decoding
  // work outside the frame event.
  Timer.run(() {
    final SkImage? skImage = canvasKit.MakeImage(
      SkImageInfo(
        width: width,
        height: height,
        colorType: format == ui.PixelFormat.rgba8888 ? canvasKit.ColorType.RGBA_8888 : canvasKit.ColorType.BGRA_8888,
        alphaType: canvasKit.AlphaType.Premul,
        colorSpace: SkColorSpaceSRGB,
      ),
      pixels,
      rowBytes ?? 4 * width,
    );

    if (skImage == null) {
      domWindow.console.warn('Failed to create image from pixels.');
      return;
    }

    return callback(CkImage(skImage));
  });
}

/// Thrown when the web engine fails to decode an image, either due to a
/// network issue, corrupted image contents, or missing codec.
class ImageCodecException implements Exception {
  ImageCodecException(this._message);

  final String _message;

  @override
  String toString() => 'ImageCodecException: $_message';
}

const String _kNetworkImageMessage = 'Failed to load network image.';

typedef HttpRequestFactory = DomXMLHttpRequest Function();
HttpRequestFactory httpRequestFactory = () => createDomXMLHttpRequest();
void debugRestoreHttpRequestFactory() {
  httpRequestFactory = () => createDomXMLHttpRequest();
}

/// Instantiates a [ui.Codec] backed by an `SkAnimatedImage` from Skia after
/// requesting from URI.
Future<ui.Codec> skiaInstantiateWebImageCodec(
    String url, WebOnlyImageCodecChunkCallback? chunkCallback) async {
  final Uint8List list = await fetchImage(url, chunkCallback);
  if (browserSupportsImageDecoder) {
    return CkBrowserImageDecoder.create(data: list, debugSource: url);
  } else {
    return CkAnimatedImage.decodeFromBytes(list, url);
  }
}

/// Sends a request to fetch image data.
Future<Uint8List> fetchImage(
    String url, WebOnlyImageCodecChunkCallback? chunkCallback) {
  final Completer<Uint8List> completer = Completer<Uint8List>();

  final DomXMLHttpRequest request = httpRequestFactory();
  request.open('GET', url, true);
  request.responseType = 'arraybuffer';
  if (chunkCallback != null) {
    request.addEventListener('progress', allowInterop((DomEvent event)  {
      event = event as DomProgressEvent;
      chunkCallback.call(event.loaded!.toInt(), event.total!.toInt());
    }));
  }

  request.addEventListener('error', allowInterop((DomEvent event) {
    completer.completeError(ImageCodecException('$_kNetworkImageMessage\n'
        'Image URL: $url\n'
        'Trying to load an image from another domain? Find answers at:\n'
        'https://flutter.dev/docs/development/platform-integration/web-images'));
  }));

  request.addEventListener('load', allowInterop((DomEvent event) {
    final int status = request.status!.toInt();
    final bool accepted = status >= 200 && status < 300;
    final bool fileUri = status == 0; // file:// URIs have status of 0.
    final bool notModified = status == 304;
    final bool unknownRedirect = status > 307 && status < 400;
    final bool success = accepted || fileUri || notModified || unknownRedirect;

    if (!success) {
      completer.completeError(
        ImageCodecException('$_kNetworkImageMessage\n'
            'Image URL: $url\n'
            'Server response code: $status'),
      );
      return;
    }

    completer.complete(Uint8List.view(request.response as ByteBuffer));
  }));

  request.send();
  return completer.future;
}

/// A [ui.Image] backed by an `SkImage` from Skia.
class CkImage implements ui.Image, StackTraceDebugger {
  CkImage(SkImage skImage, { this.videoFrame }) {
    _init();
    if (browserSupportsFinalizationRegistry) {
      box = SkiaObjectBox<CkImage, SkImage>(this, skImage);
    } else {
      // If finalizers are not supported we need to be able to resurrect the
      // image if it was temporarily deleted. To do that, we keep the original
      // pixels and ask the SkiaObjectBox to make an image from them when
      // resurrecting.
      //
      // IMPORTANT: the alphaType, colorType, and colorSpace passed to
      // _encodeImage and to canvasKit.MakeImage must be the same. Otherwise
      // Skia will misinterpret the pixels and corrupt the image.
      final ByteData? originalBytes = _encodeImage(
        skImage: skImage,
        format: ui.ImageByteFormat.rawRgba,
        alphaType: canvasKit.AlphaType.Premul,
        colorType: canvasKit.ColorType.RGBA_8888,
        colorSpace: SkColorSpaceSRGB,
      );
      if (originalBytes == null) {
        printWarning('Unable to encode image to bytes. We will not '
            'be able to resurrect it once it has been garbage collected.');
        return;
      }
      final int originalWidth = skImage.width().toInt();
      final int originalHeight = skImage.height().toInt();
      box = SkiaObjectBox<CkImage, SkImage>.resurrectable(this, skImage, () {
        final SkImage? skImage = canvasKit.MakeImage(
          SkImageInfo(
            alphaType: canvasKit.AlphaType.Premul,
            colorType: canvasKit.ColorType.RGBA_8888,
            colorSpace: SkColorSpaceSRGB,
            width: originalWidth,
            height: originalHeight,
          ),
          originalBytes.buffer.asUint8List(),
          4 * originalWidth,
        );
        if (skImage == null) {
          throw ImageCodecException(
            'Failed to resurrect image from pixels.'
          );
        }
        return skImage;
      });
    }
  }

  CkImage.cloneOf(this.box, {this.videoFrame}) {
    _init();
    box.ref(this);
  }

  void _init() {
    if (assertionsEnabled) {
      _debugStackTrace = StackTrace.current;
    }
    ui.Image.onCreate?.call(this);
  }

  @override
  StackTrace get debugStackTrace => _debugStackTrace;
  late StackTrace _debugStackTrace;

  // Use a box because `SkImage` may be deleted either due to this object
  // being garbage-collected, or by an explicit call to [delete].
  late final SkiaObjectBox<CkImage, SkImage> box;

  /// For browsers that support `ImageDecoder` this field holds the video frame
  /// from which this image was created.
  ///
  /// Skia owns the video frame and will close it when it's no longer used.
  /// However, Flutter co-owns the [SkImage] and therefore it's safe to access
  /// the video frame until the image is [dispose]d of.
  VideoFrame? videoFrame;

  /// The underlying Skia image object.
  ///
  /// Do not store the returned value. It is memory-managed by [SkiaObjectBox].
  /// Storing it may result in use-after-free bugs.
  SkImage get skImage => box.skiaObject;

  bool _disposed = false;

  bool _debugCheckIsNotDisposed() {
    assert(!_disposed, 'This image has been disposed.');
    return true;
  }

  @override
  void dispose() {
    assert(
      !_disposed,
      'Cannot dispose an image that has already been disposed.',
    );
    ui.Image.onDispose?.call(this);
    _disposed = true;
    box.unref(this);
  }

  @override
  bool get debugDisposed {
    if (assertionsEnabled) {
      return _disposed;
    }
    throw StateError(
        'Image.debugDisposed is only available when asserts are enabled.');
  }

  @override
  CkImage clone() {
    assert(_debugCheckIsNotDisposed());
    return CkImage.cloneOf(box, videoFrame: videoFrame?.clone());
  }

  @override
  bool isCloneOf(ui.Image other) {
    assert(_debugCheckIsNotDisposed());
    return other is CkImage && other.skImage.isAliasOf(skImage);
  }

  @override
  List<StackTrace>? debugGetOpenHandleStackTraces() =>
      box.debugGetStackTraces();

  @override
  int get width {
    assert(_debugCheckIsNotDisposed());
    return skImage.width().toInt();
  }

  @override
  int get height {
    assert(_debugCheckIsNotDisposed());
    return skImage.height().toInt();
  }

  @override
  Future<ByteData> toByteData({
    ui.ImageByteFormat format = ui.ImageByteFormat.rawRgba,
  }) {
    assert(_debugCheckIsNotDisposed());
    if (videoFrame != null) {
      return readPixelsFromVideoFrame(videoFrame!, format);
    } else {
      return _readPixelsFromSkImage(format);
    }
  }

  Future<ByteData> _readPixelsFromSkImage(ui.ImageByteFormat format) {
    final SkAlphaType alphaType = format == ui.ImageByteFormat.rawStraightRgba ? canvasKit.AlphaType.Unpremul : canvasKit.AlphaType.Premul;
    final ByteData? data = _encodeImage(
      skImage: skImage,
      format: format,
      alphaType: alphaType,
      colorType: canvasKit.ColorType.RGBA_8888,
      colorSpace: SkColorSpaceSRGB,
    );
    if (data == null) {
      return Future<ByteData>.error('Failed to encode the image into bytes.');
    } else {
      return Future<ByteData>.value(data);
    }
  }

  static ByteData? _encodeImage({
    required SkImage skImage,
    required ui.ImageByteFormat format,
    required SkAlphaType alphaType,
    required SkColorType colorType,
    required ColorSpace colorSpace,
  }) {
    Uint8List? bytes;

    if (format == ui.ImageByteFormat.rawRgba || format == ui.ImageByteFormat.rawStraightRgba) {
      final SkImageInfo imageInfo = SkImageInfo(
        alphaType: alphaType,
        colorType: colorType,
        colorSpace: colorSpace,
        width: skImage.width().toInt(),
        height: skImage.height().toInt(),
      );
      bytes = skImage.readPixels(0, 0, imageInfo);
    } else {
      bytes = skImage.encodeToBytes(); // defaults to PNG 100%
    }

    return bytes?.buffer.asByteData(0, bytes.length);
  }

  @override
  String toString() {
    assert(_debugCheckIsNotDisposed());
    return '[$width\u00D7$height]';
  }
}

/// Data for a single frame of an animated image.
class AnimatedImageFrameInfo implements ui.FrameInfo {
  AnimatedImageFrameInfo(this._duration, this._image);

  final Duration _duration;
  final CkImage _image;

  @override
  Duration get duration => _duration;

  @override
  ui.Image get image => _image;
}
