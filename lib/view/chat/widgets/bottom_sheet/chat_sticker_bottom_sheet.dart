import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voiceclub_partner/core/constants/asset_constants.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/data/models/chat/chat_theme.dart';
import 'package:voiceclub_partner/data/models/chat/gift_data.dart';
import 'package:voiceclub_partner/data/models/chat/growthbook_stickers_response.dart';

class ChatStickerBottomSheet extends StatefulWidget {
  const ChatStickerBottomSheet({
    super.key,
    required this.demandName,
    required this.demandUid,
    required this.theme,
    required this.stickers,
    required this.onSendGift,
  });

  final String demandName;
  final int demandUid;
  final ChatTheme theme;
  final GrowthbookStickersResponseModel stickers;
  final Function(GiftData) onSendGift;

  @override
  State<ChatStickerBottomSheet> createState() => _ChatStickerBottomSheetState();
}

class _ChatStickerBottomSheetState extends State<ChatStickerBottomSheet> {
  GiftData? selectedGift;
  late List<GiftData> stickerRewards;

  @override
  void initState() {
    super.initState();
    stickerRewards = widget.stickers.stickers ?? [];
  }

  Future<void> _sendGift() async {
    if (selectedGift != null) {
      widget.onSendGift(selectedGift!);
      Get.back();
    }
  }

  Widget buildStickerItem(GiftData gift) {
    final isSelected = selectedGift != null && selectedGift!.id == gift.id;

    return InkWell(
      onTap: () async {
        setState(() {
          selectedGift = gift;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border:
              isSelected
                  ? Border.all(color: widget.theme.primaryColor, width: 2.0)
                  : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FastCachedImageProvider(gift.stickerUrl ?? ''),
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
                SizedBox(
                  height: 400.0,
                  child: ListView(
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
                            stickerRewards
                                .map((e) => buildStickerItem(e))
                                .toList(),
                      ),
                    ],
                  ),
                ),
                if (selectedGift != null)
                  GestureDetector(
                    onTap: () async {
                      await _sendGift();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12.0),
                      margin: const EdgeInsets.all(10.0),
                      decoration: ShapeDecoration(
                        color: widget.theme.primaryColor,
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
                      child: Center(
                        child: Text(
                          "Send",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: GoogleFonts.mulish().fontFamily,
                            fontWeight: FontWeight.w700,
                            height: 0,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            height: 84.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Color(0x7A000000),
                  blurRadius: 10,
                  offset: Offset(0, -3),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 3,
                    decoration: ShapeDecoration(
                      color: widget.theme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 42.0,
                          height: 42.0,
                          decoration: ShapeDecoration(
                            color: widget.theme.primaryColor.withValues(
                              alpha: 0.3,
                            ),
                            shape: const OvalBorder(),
                          ),
                          child: Image.asset(
                            AssetConstants.sticker,
                            color: widget.theme.primaryColor,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          'Stickers',
                          style: TextStyle(
                            color: widget.theme.primaryColor,
                            fontSize: FontSize.L,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
