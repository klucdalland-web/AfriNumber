import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/inbox_header.dart';
import '../controllers/messages_controller.dart';
import '../widgets/message_search_field.dart';
import '../widgets/message_tile.dart';

/// Écran « Messages » (Figma : Accueil/Messages).
class MessagesPage extends GetView<MessagesController> {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Obx(
              () => InboxHeader(
                title: 'Messages',
                subtitle: MessagesController.maskedNumber,
                unreadCount: controller.unreadCount,
                onBack: Get.back,
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: MessageSearchField(onChanged: controller.onQueryChanged),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final items = controller.filteredMessages;
                return ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    MediaQuery.paddingOf(context).bottom + 16,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) => MessageTile(message: items[index]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
