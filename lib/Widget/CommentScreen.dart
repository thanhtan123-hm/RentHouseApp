// lib/CommentScreen.dart
import 'package:flutter/material.dart';

class CommentScreen extends StatelessWidget {
  final String postId;

  CommentScreen({required this.postId});

  @override
  Widget build(BuildContext context) {
    TextEditingController commentController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bình luận'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text('Hiển thị bình luận cho bài viết: $postId'),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: commentController,
                    decoration: InputDecoration(
                      hintText: 'Nhập bình luận...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Xử lý lưu bình luận ở đây
                    String comment = commentController.text;
                    if (comment.isNotEmpty) {
                      // Gửi bình luận lên server hoặc lưu vào database
                      print('Bình luận: $comment');
                      // Xóa nội dung trong TextField sau khi gửi bình luận
                      commentController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
