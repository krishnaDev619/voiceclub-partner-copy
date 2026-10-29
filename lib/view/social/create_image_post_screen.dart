import 'package:fast_cached_network_image/fast_cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:voiceclub_partner/core/constants/ui_constants.dart';
import 'package:voiceclub_partner/core/injection_container.dart';
import 'package:voiceclub_partner/core/services/analytics_service.dart';

import 'controllers/create_image_post_controller.dart';
import 'create_image_post_detail_screen.dart';

class CreateImagePostScreen extends StatefulWidget {
  const CreateImagePostScreen({super.key});

  @override
  State<CreateImagePostScreen> createState() => _CreateImagePostScreenState();
}

class _CreateImagePostScreenState extends State<CreateImagePostScreen> {
  final CreateImagePostController controller = Get.put(
    CreateImagePostController(),
  );

  @override
  void initState() {
    super.initState();
    sl<AnalyticsService>().trackEvent("exploreImageTemplatesScreenPartner");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Create Post',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black),
        ),
        elevation: 0,
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            controller.loadMore();
          }
          return true;
        },
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildCategories()),
            _buildImageGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Obx(
        () => Wrap(
          alignment: WrapAlignment.start,
          runAlignment: WrapAlignment.start,
          spacing: 8,
          runSpacing: 8,
          children:
              controller.categories.map((category) {
                final isSelected =
                    controller.selectedCategory.value == category.name;
                return GestureDetector(
                  onTap:
                      () => controller.changeCategory(
                        category.name,
                        category.pretext,
                      ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.red.shade400 : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected
                                ? Colors.transparent
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      '${category.name} ${category.icon}',
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontSize: 13,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return Obx(
      () => SliverPadding(
        padding: const EdgeInsets.all(8),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index >= controller.images.length) {
                return const ShimmerContainer(
                  height: 100,
                  width: 100,
                  borderRadius: 12,
                );
              }

              final image = controller.images[index];
              return GestureDetector(
                onTap:
                    () => Get.to(
                      () => CreateImagePostDetailScreen(photo: image),
                      transition: Transition.noTransition,
                      duration: Duration.zero,
                    ),
                child: Hero(
                  tag: image.id ?? "",
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FastCachedImage(
                        url: image.thumbUrl ?? "",
                        loadingBuilder:
                            (_, _) => const ShimmerContainer(
                              height: 100,
                              width: 100,
                              borderRadius: 12,
                            ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
            childCount:
                controller.images.length + (controller.isLoading.value ? 2 : 0),
          ),
        ),
      ),
    );
  }
}
