import 'package:flutter/material.dart';
import 'package:voiceclub_partner/data/models/social/post_model.dart';
import 'package:voiceclub_partner/view/social/widgets/post_card.dart';

class Post extends StatefulWidget {
  final PostModel post;
  const Post({super.key, required this.post});

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        PostCard(key: UniqueKey(), post: widget.post),
        const Divider(color: Color(0xFFDDDDDD), thickness: 5),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
