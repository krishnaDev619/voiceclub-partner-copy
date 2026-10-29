import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/data/models/chat/gift_data.dart';

class CommentStickerBottomSheet extends StatefulWidget {
  const CommentStickerBottomSheet({
    super.key,
    required this.onStickerSelected,
    required this.stickers,
  });

  final Function(GiftData) onStickerSelected;
  final List<GiftData> stickers;

  @override
  State<CommentStickerBottomSheet> createState() =>
      _CommentStickerBottomSheetState();
}

class _CommentStickerBottomSheetState extends State<CommentStickerBottomSheet> {
  GiftData? selectedSticker;

  Future<void> _sendSticker() async {
    if (selectedSticker != null) {
      widget.onStickerSelected(selectedSticker!);
      Get.back();
    }
  }

  Widget _buildStickerItem(GiftData sticker) {
    final isSelected =
        selectedSticker != null && selectedSticker!.id == sticker.id;

    return InkWell(
      onTap: () {
        setState(() {
          selectedSticker = sticker;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border:
              isSelected
                  ? Border.all(color: Get.theme.primaryColor, width: 1.0)
                  : null,
        ),
        child: AspectRatio(
          aspectRatio: 1.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: FastCachedImage(
              url: sticker.stickerUrl ?? '',
              fit: BoxFit.cover,
              errorBuilder:
                  (context, url, error) => Container(
                    color: Colors.grey[100],
                    child: const Icon(Icons.error_outline, color: Colors.grey),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              shadows: [
                BoxShadow(
                  color: Color(0x19000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 3,
                  margin: const EdgeInsets.only(top: 10),
                  decoration: ShapeDecoration(
                    color: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select a Sticker',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 400.0,
                  child:
                      widget.stickers.isEmpty
                          ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sentiment_dissatisfied,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No stickers available',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                          : ListView(
                            children: [
                              GridView.count(
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                primary: false,
                                padding: const EdgeInsets.all(20),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                crossAxisCount: 3,
                                children:
                                    widget.stickers
                                        .map(
                                          (sticker) =>
                                              _buildStickerItem(sticker),
                                        )
                                        .toList(),
                              ),
                            ],
                          ),
                ),
                if (selectedSticker != null)
                  GestureDetector(
                    onTap: _sendSticker,
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.all(16.0),
                      decoration: ShapeDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        shadows: const [
                          BoxShadow(
                            color: Color(0x26000000),
                            blurRadius: 20,
                            offset: Offset(0, 0),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Send Sticker",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
