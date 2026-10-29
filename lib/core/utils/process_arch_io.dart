import 'dart:ffi' show Pointer, sizeOf;

/// True when this Dart isolate runs as a 32-bit process (e.g. armeabi-v7a).
///
/// ONNX Runtime + Silero VAD can crash with SIGBUS (unaligned access) on 32-bit ARM.
bool get is32BitProcess => sizeOf<Pointer>() == 4;
