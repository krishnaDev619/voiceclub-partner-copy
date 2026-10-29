import 'dart:typed_data';

/// Isolate/compute entry for turning a WAV file into Silero PCM16.
Uint8List decodeWavToSileroPcm(Uint8List bytes) {
  return WavPcm.parse(bytes)?.toMonoPcm16k() ?? Uint8List(0);
}

/// PCM helpers for feeding a recorded WAV into Silero VAD (16 kHz mono PCM16).
class WavPcm {
  static const int sileroSampleRate = 16000;

  final int sampleRate;
  final int channels;
  final int bitsPerSample;
  final Uint8List pcm;

  const WavPcm({
    required this.sampleRate,
    required this.channels,
    required this.bitsPerSample,
    required this.pcm,
  });

  static WavPcm? parse(Uint8List bytes) {
    if (bytes.length < 44) return null;
    if (!_hasId(bytes, 0, 'RIFF') || !_hasId(bytes, 8, 'WAVE')) {
      return null;
    }

    final data = ByteData.sublistView(bytes);
    var offset = 12;
    int? sampleRate;
    int? channels;
    int? bitsPerSample;
    Uint8List? pcm;

    while (offset + 8 <= bytes.length) {
      final size = data.getUint32(offset + 4, Endian.little);
      final dataOffset = offset + 8;
      final end = (dataOffset + size).clamp(0, bytes.length);

      if (_hasId(bytes, offset, 'fmt ') &&
          size >= 16 &&
          dataOffset + 16 <= bytes.length) {
        channels = data.getUint16(dataOffset + 2, Endian.little);
        sampleRate = data.getUint32(dataOffset + 4, Endian.little);
        bitsPerSample = data.getUint16(dataOffset + 14, Endian.little);
      } else if (_hasId(bytes, offset, 'data')) {
        pcm = Uint8List.sublistView(bytes, dataOffset, end);
        break;
      }

      offset = end + (size.isOdd ? 1 : 0);
    }

    if (pcm == null ||
        sampleRate == null ||
        sampleRate <= 0 ||
        channels == null ||
        channels <= 0 ||
        bitsPerSample == null) {
      return null;
    }

    return WavPcm(
      sampleRate: sampleRate,
      channels: channels,
      bitsPerSample: bitsPerSample,
      pcm: pcm,
    );
  }

  /// Silero VAD expects little-endian PCM16, mono, 16 kHz.
  Uint8List toMonoPcm16k() {
    return _resamplePcm16(_monoInt16Samples(), sampleRate, sileroSampleRate);
  }

  Int16List _monoInt16Samples() {
    if (bitsPerSample != 16) {
      return Int16List(0);
    }

    final bytesPerFrame = 2 * channels;
    final frameCount = pcm.length ~/ bytesPerFrame;
    if (frameCount <= 0) return Int16List(0);

    final data = ByteData.sublistView(pcm);
    final samples = Int16List(frameCount);
    for (var i = 0; i < frameCount; i++) {
      if (channels == 1) {
        samples[i] = data.getInt16(i * 2, Endian.little);
      } else {
        var sum = 0;
        for (var c = 0; c < channels; c++) {
          sum += data.getInt16(i * bytesPerFrame + c * 2, Endian.little);
        }
        samples[i] = (sum / channels).round().clamp(-32768, 32767);
      }
    }
    return samples;
  }

  static bool _hasId(Uint8List bytes, int offset, String id) {
    return bytes[offset] == id.codeUnitAt(0) &&
        bytes[offset + 1] == id.codeUnitAt(1) &&
        bytes[offset + 2] == id.codeUnitAt(2) &&
        bytes[offset + 3] == id.codeUnitAt(3);
  }

  static Uint8List _resamplePcm16(Int16List samples, int fromRate, int toRate) {
    if (samples.isEmpty || fromRate <= 0 || toRate <= 0) {
      return Uint8List(0);
    }
    if (fromRate == toRate) {
      return Uint8List.sublistView(samples);
    }

    final outCount = (samples.length * toRate / fromRate).floor();
    if (outCount <= 0) return Uint8List(0);

    final out = Uint8List(outCount * 2);
    final data = ByteData.sublistView(out);
    final lastIndex = samples.length - 1;
    for (var i = 0; i < outCount; i++) {
      final src = i * fromRate / toRate;
      final idx = src.floor().clamp(0, lastIndex);
      final next = (idx + 1).clamp(0, lastIndex);
      final frac = src - idx;
      final sample = (samples[idx] + (samples[next] - samples[idx]) * frac)
          .round()
          .clamp(-32768, 32767);
      data.setInt16(i * 2, sample, Endian.little);
    }
    return out;
  }
}
