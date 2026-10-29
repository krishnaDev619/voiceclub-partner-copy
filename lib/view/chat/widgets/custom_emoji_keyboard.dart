import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class CustomEmojiKeyboard extends CategoryView {
  const CustomEmojiKeyboard(
    super.config,
    super.state,
    super.tabController,
    super.pageController, {
    super.key,
  });

  @override
  CustomEmojiKeyboardState createState() => CustomEmojiKeyboardState();
}

class CustomEmojiKeyboardState extends State<CustomEmojiKeyboard>
    with SkinToneOverlayStateMixin {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.config.categoryViewConfig.backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: EmojiTabBar(
              widget.config,
              widget.tabController,
              widget.pageController,
              widget.state.categoryEmoji,
              closeSkinToneOverlay,
            ),
          ),
        ],
      ),
    );
  }
}

class EmojiTabBar extends StatelessWidget {
  const EmojiTabBar(
    this.config,
    this.tabController,
    this.pageController,
    this.categoryEmojis,
    this.closeSkinToneOverlay, {
    super.key,
  });

  final Config config;

  final TabController tabController;

  final PageController pageController;

  final List<CategoryEmoji> categoryEmojis;

  final VoidCallback closeSkinToneOverlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: config.categoryViewConfig.tabBarHeight,
      child: TabBar(
        labelColor: config.categoryViewConfig.iconColorSelected,
        indicatorColor: config.categoryViewConfig.indicatorColor,
        unselectedLabelColor: config.categoryViewConfig.iconColor,
        dividerColor: config.categoryViewConfig.dividerColor,
        controller: tabController,
        labelPadding: const EdgeInsets.only(top: 1.0),
        indicatorSize: TabBarIndicatorSize.label,
        indicator: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black12,
        ),
        onTap: (index) {
          closeSkinToneOverlay();
          pageController.jumpToPage(index);
        },
        tabs:
            categoryEmojis
                .asMap()
                .entries
                .map<Widget>(
                  (item) => _buildCategory(item.key, item.value.category),
                )
                .toList(),
      ),
    );
  }

  Widget _buildCategory(int index, Category category) {
    return Tab(
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(
          getIconForCategory(config.categoryViewConfig.categoryIcons, category),
          size: 20,
        ),
      ),
    );
  }
}

class EmojiSearchView extends SearchView {
  const EmojiSearchView(
    super.config,
    super.state,
    super.showEmojiView, {
    super.key,
  });

  @override
  WhatsAppSearchViewState createState() => WhatsAppSearchViewState();
}

class WhatsAppSearchViewState extends SearchViewState {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final emojiSize = widget.config.emojiViewConfig.getEmojiSize(
          constraints.maxWidth,
        );
        final emojiBoxSize = widget.config.emojiViewConfig.getEmojiBoxSize(
          constraints.maxWidth,
        );
        return Container(
          color: widget.config.searchViewConfig.backgroundColor,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: emojiBoxSize + 8.0,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    return buildEmoji(results[index], emojiSize, emojiBoxSize);
                  },
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: widget.showEmojiView,
                    color: widget.config.searchViewConfig.backgroundColor,
                    icon: Icon(
                      Icons.arrow_back,
                      color: widget.config.searchViewConfig.buttonIconColor,
                      size: 20.0,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      onChanged: onTextInputChanged,
                      focusNode: focusNode,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: widget.config.searchViewConfig.hintText,
                        hintStyle: const TextStyle(
                          color: Color(0xFF8B98A0),
                          fontWeight: FontWeight.normal,
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
