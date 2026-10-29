import 'package:flutter/material.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/signed_url_service.dart';

/// Resolves a signed chat attachment URL before building the child widget.
class ResolvedChatAttachmentUrl extends StatefulWidget {
  final String signedUrl;
  final Widget Function(String url) builder;
  final Widget? placeholder;

  const ResolvedChatAttachmentUrl({
    super.key,
    required this.signedUrl,
    required this.builder,
    this.placeholder,
  });

  @override
  State<ResolvedChatAttachmentUrl> createState() =>
      _ResolvedChatAttachmentUrlState();
}

class _ResolvedChatAttachmentUrlState extends State<ResolvedChatAttachmentUrl> {
  late Future<String> _future;

  @override
  void initState() {
    super.initState();
    _future = sl<SignedUrlService>().getChatAttachmentUrl(widget.signedUrl);
  }

  @override
  void didUpdateWidget(covariant ResolvedChatAttachmentUrl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.signedUrl != widget.signedUrl) {
      _future = sl<SignedUrlService>().getChatAttachmentUrl(widget.signedUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _future,
      builder: (context, snapshot) {
        final url = snapshot.data;
        if (url == null || url.isEmpty) {
          return widget.placeholder ?? const SizedBox.shrink();
        }
        return widget.builder(url);
      },
    );
  }
}
