import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodie/models/user_model.dart';
import 'package:foodie/models/review_model.dart';
import 'package:foodie/repositories/review_repo.dart';
import 'package:foodie/view_models/account_vm.dart';
import 'package:foodie/view_models/restaurant_detail_vm.dart';
import 'package:foodie/widgets/firebase_image.dart';
import 'package:foodie/widgets/restaurant/image_preview_screen.dart';

class ReviewListItem extends StatelessWidget {
  final ReviewModel review;
  final Future<UserModel?> userDataFuture;
  final String? Function(String dishId)? dishNameLookup;
  final VoidCallback? onAgree;
  final VoidCallback? onDisagree;
  final Function(String newContent)? onEdit;
  final VoidCallback? onDelete;
  final Function(String imageUrl)? onDeleteImage;
  final VoidCallback? onTap;

  const ReviewListItem({
    super.key,
    required this.review,
    required this.userDataFuture,
    this.dishNameLookup,
    this.onAgree,
    this.onDisagree,
    this.onEdit,
    this.onDelete,
    this.onDeleteImage,
    this.onTap,
  });

  void _showEditDialog(BuildContext context) {
    final textController = TextEditingController(text: review.content);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Review'),
            content: TextField(
              controller: textController,
              maxLines: 6,
              autofocus: true,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              FilledButton(
                onPressed: () {
                  // 調用 onEdit callback，並關閉對話框
                  onEdit?.call(textController.text);
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  // ✅ 顯示刪除確認對話框的輔助方法
  void _showDeleteConfirmDialog(
    BuildContext context, {
    required String title,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: const Text('This action cannot be undone.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  onConfirm();
                  Navigator.of(context).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('yyyy-MM-dd hh:mm a');
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = context.watch<AccountViewModel>().firebaseUser?.uid;
    final bool isAuthor = currentUserId == review.reviewerID;

    final bool hasAgreed = currentUserId != null && review.agreedBy.contains(currentUserId);
    final bool hasDisagreed = currentUserId != null && review.disagreedBy.contains(currentUserId);

    final String? dishName =
        (review.dishID != null && review.dishID!.isNotEmpty && dishNameLookup != null)
            ? dishNameLookup!(review.dishID!)
            : null;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<UserModel?>(
              future: userDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done || !snapshot.hasData) {
                  return const CircleAvatar(child: Icon(Icons.person_outline));
                }
                final user = snapshot.data;
                return CircleAvatar(
                  backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
                  child: (user?.photoURL == null) ? const Icon(Icons.person_outline) : null,
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 40,
                            child: Row(
                              children: [
                                FutureBuilder<UserModel?>(
                                  future: userDataFuture,
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState != ConnectionState.done ||
                                        !snapshot.hasData) {
                                      return Text('Loading...', style: textTheme.titleSmall);
                                    }
                                    return Text(
                                      snapshot.data?.userName ?? 'Unknown User',
                                      style: textTheme.titleSmall,
                                    );
                                  },
                                ),
                                const Spacer(),
                                if (onAgree != null) ...[
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      hasAgreed ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
                                      size: 18,
                                      color: hasAgreed ? colorScheme.primary : null,
                                    ),
                                    onPressed: onAgree,
                                  ),
                                  Text(review.agreedBy.length.toString()),
                                  const SizedBox(width: 8),
                                ],
                                if (onDisagree != null) ...[
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: Icon(
                                      hasDisagreed
                                          ? Icons.thumb_down_alt
                                          : Icons.thumb_down_alt_outlined,
                                      size: 18,
                                      color: hasDisagreed ? Colors.grey : null,
                                    ),
                                    onPressed: onDisagree,
                                  ),
                                  Text(review.disagreedBy.length.toString()),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                (i) => Icon(
                                  i < review.rating ? Icons.star : Icons.star_border,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                formatter.format(DateTime.parse(review.reviewDate)),
                                style: textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (isAuthor)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Transform.translate(
                            offset: const Offset(8, 16),
                            child: Row(
                              children: [
                                if (onEdit != null)
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    onPressed: () => _showEditDialog(context),
                                  ),
                                if (onDelete != null)
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    onPressed:
                                        () => _showDeleteConfirmDialog(
                                          context,
                                          title: 'Delete Review?',
                                          onConfirm: onDelete!,
                                        ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (dishName != null)
                    Chip(
                      avatar: Icon(Icons.restaurant_menu, size: 16, color: colorScheme.secondary),
                      label: Text(dishName, style: textTheme.labelLarge),
                      backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      side: BorderSide.none,
                    ),
                  Text(review.content, style: textTheme.bodyMedium),
                  SizedBox(
                    height: review.reviewImgURLs.isNotEmpty ? 120 : 0,
                    child:
                        review.reviewImgURLs.isNotEmpty
                            ? ListView.separated(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.only(top: 8),
                              itemCount: review.reviewImgURLs.length,
                              separatorBuilder: (context, index) => const SizedBox(width: 8),
                              itemBuilder: (context, index) {
                                final gsUri = review.reviewImgURLs[index];
                                return GestureDetector(
                                  onTap: () => showImagePreview(context, gsUri),
                                  child: Hero(
                                    tag: gsUri,
                                    child: Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: FirebaseImage(
                                            gsUri: gsUri,
                                            width: 120,
                                            height: 80,
                                          ),
                                        ),
                                        if (isAuthor && onDeleteImage != null)
                                          InkWell(
                                            onTap:
                                                () => _showDeleteConfirmDialog(
                                                  context,
                                                  title: 'Delete Image?',
                                                  onConfirm: () => onDeleteImage!(gsUri),
                                                ),
                                            child: const CircleAvatar(
                                              radius: 12,
                                              backgroundColor: Colors.black54,
                                              child: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            // Expanded(
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       SizedBox(
            //         height: 40,
            //         child: Row(
            //           children: [
            //             FutureBuilder<UserModel?>(
            //               future: userDataFuture,
            //               builder: (context, snapshot) {
            //                 if (snapshot.connectionState != ConnectionState.done ||
            //                     !snapshot.hasData) {
            //                   return Text('Loading...', style: textTheme.titleSmall);
            //                 }
            //                 return Text(
            //                   snapshot.data?.userName ?? 'Unknown User',
            //                   style: textTheme.titleSmall,
            //                 );
            //               },
            //             ),
            //             const Spacer(),
            //             if (onAgree != null) ...[
            //               IconButton(
            //                 visualDensity: VisualDensity.compact,
            //                 icon: Icon(
            //                   hasAgreed ? Icons.thumb_up_alt : Icons.thumb_up_alt_outlined,
            //                   size: 18,
            //                   color: hasAgreed ? colorScheme.primary : null,
            //                 ),
            //                 onPressed: onAgree,
            //               ),
            //               Text(review.agreedBy.length.toString()),
            //               const SizedBox(width: 8),
            //             ],
            //             if (onDisagree != null) ...[
            //               IconButton(
            //                 visualDensity: VisualDensity.compact,
            //                 icon: Icon(
            //                   hasDisagreed ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
            //                   size: 18,
            //                   color: hasDisagreed ? Colors.grey : null,
            //                 ),
            //                 onPressed: onDisagree,
            //               ),
            //               Text(review.disagreedBy.length.toString()),
            //             ],
            //             if (isAuthor && onEdit != null)
            //               IconButton(
            //                 visualDensity: VisualDensity.compact,
            //                 icon: const Icon(Icons.edit_outlined, size: 18),
            //                 onPressed: () => _showEditDialog(context),
            //               ),
            //             if (isAuthor && onDelete != null)
            //               IconButton(
            //                 visualDensity: VisualDensity.compact,
            //                 icon: const Icon(Icons.delete_outline, size: 18),
            //                 onPressed:
            //                     () => _showDeleteConfirmDialog(
            //                       context,
            //                       title: 'Delete Review?',
            //                       onConfirm: onDelete!,
            //                     ),
            //               ),
            //           ],
            //         ),
            //       ),
            //       Row(
            //         children: [
            //           ...List.generate(
            //             5,
            //             (i) => Icon(
            //               i < review.rating ? Icons.star : Icons.star_border,
            //               size: 16,
            //               color: Colors.amber,
            //             ),
            //           ),
            //           const SizedBox(width: 8),
            //           Text(
            //             formatter.format(DateTime.parse(review.reviewDate)),
            //             style: textTheme.bodySmall,
            //           ), // 格式化日期
            //         ],
            //       ),
            //       const SizedBox(height: 8),
            //       if (dishName != null)
            //         Chip(
            //           avatar: Icon(Icons.restaurant_menu, size: 16, color: colorScheme.secondary),
            //           label: Text(dishName, style: textTheme.labelLarge),
            //           backgroundColor: colorScheme.secondaryContainer.withOpacity(0.5),
            //           padding: const EdgeInsets.symmetric(horizontal: 8),
            //           side: BorderSide.none,
            //         ),
            //       Text(review.content, style: textTheme.bodyMedium),
            //       SizedBox(
            //         height: review.reviewImgURLs.isNotEmpty ? 120 : 0,
            //         child:
            //             review.reviewImgURLs.isNotEmpty
            //                 ? ListView.separated(
            //                   scrollDirection: Axis.horizontal,
            //                   padding: const EdgeInsets.only(top: 8),
            //                   itemCount: review.reviewImgURLs.length,
            //                   separatorBuilder: (context, index) => const SizedBox(width: 8),
            //                   itemBuilder: (context, index) {
            //                     final gsUri = review.reviewImgURLs[index];
            //                     return GestureDetector(
            //                       onTap: () => showImagePreview(context, gsUri),
            //                       child: Hero(
            //                         tag: gsUri,
            //                         child: Stack(
            //                           alignment: Alignment.topRight,
            //                           children: [
            //                             ClipRRect(
            //                               borderRadius: BorderRadius.circular(8),
            //                               child: FirebaseImage(
            //                                 gsUri: gsUri,
            //                                 width: 120,
            //                                 height: 80,
            //                               ),
            //                             ),
            //                             if (isAuthor && onDeleteImage != null)
            //                               InkWell(
            //                                 onTap:
            //                                     () => _showDeleteConfirmDialog(
            //                                       context,
            //                                       title: 'Delete Image?',
            //                                       onConfirm: () => onDeleteImage!(gsUri),
            //                                     ),
            //                                 child: const CircleAvatar(
            //                                   radius: 12,
            //                                   backgroundColor: Colors.black54,
            //                                   child: Icon(
            //                                     Icons.close,
            //                                     size: 16,
            //                                     color: Colors.white,
            //                                   ),
            //                                 ),
            //                               ),
            //                           ],
            //                         ),
            //                       ),
            //                     );
            //                   },
            //                 )
            //                 : const SizedBox.shrink(),
            //       ),
            //     ],
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
