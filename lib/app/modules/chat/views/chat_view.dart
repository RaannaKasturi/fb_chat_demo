// chat_view.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening files/videos/images
import '../controllers/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final isChattingWithSelf = controller.currentUserId == controller.friendId;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isChattingWithSelf
              ? '${controller.friendEmail} (Self)'
              : controller.friendEmail,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('Call Feature'),
                  content: const Text(
                    'Calling or Video Calling feature without a WebRTC Server is Uterly impossible.',
                  ),
                  actions: [
                    OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('OK'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        launchUrl(
                          Uri.parse(
                            'https://github.com/RaannaKasturi/Chat-App-WEBRTC-Demo',
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: const Text('Proposed Method'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.grey[300],
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Notification for sending or receiving messages requires a server code to be executed separately. Not possible from client side alone.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: controller.getMessages(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Start a new conversation!'));
                }
                // Use reversed to show the latest messages at the bottom
                final messages = snapshot.data!.docs.reversed.toList();
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final messageData = messages[index].data();
                    final isCurrentUser =
                        messageData['senderId'] == controller.currentUserId;
                    return _buildMessageBubble(
                      messageData, // Pass the entire data map
                      isCurrentUser,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // New: Button to open media picker options
                IconButton(
                  icon: const Icon(Icons.attach_file, color: Colors.blue),
                  onPressed: controller.showMediaPickerOptions,
                ),
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                      ),
                    ),
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: controller.sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(Map<String, dynamic> messageData) {
    final String message = messageData['message'] ?? '';
    final String type = messageData['type'] ?? 'text';
    final String? fileUrl = messageData['fileUrl'];
    final String? fileName = messageData['fileName'];

    switch (type) {
      case 'image':
        // Display Image
        return InkWell(
          onTap: () async {
            await launchUrl(
              Uri.parse(fileUrl),
              mode: LaunchMode.externalApplication,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  fileUrl!,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: 200,
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
              if (message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(message),
                ),
            ],
          ),
        );

      case 'video':
        return InkWell(
          onTap: () async {
            if (fileUrl != null) {
              await launchUrl(
                Uri.parse(fileUrl),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle_fill, color: Colors.white, size: 50),
                Text(
                  'Tap to view video',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        );

      case 'file':
        // Display File Link (e.g., Document, PDF)
        return InkWell(
          onTap: () async {
            if (fileUrl != null) {
              await launchUrl(
                Uri.parse(fileUrl),
                mode: LaunchMode.externalApplication,
              );
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.insert_drive_file, color: Colors.white),
              const SizedBox(width: 8.0),
              Flexible(
                child: Text(
                  fileName ?? 'Shared File', // Use fileName if available
                  style: const TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );

      case 'text':
      default:
        // Display Text Message
        return Text(message);
    }
  }

  Widget _buildMessageBubble(
    Map<String, dynamic> messageData,
    bool isCurrentUser,
  ) {
    // Determine color based on type and sender
    final String type = messageData['type'] ?? 'text';
    Color bubbleColor = isCurrentUser
        ? (type == 'text' ? Colors.blueAccent : Colors.lightBlue)
        : (type == 'text' ? Colors.grey[300]! : Colors.grey);
    Color textColor = isCurrentUser ? Colors.white : Colors.black;

    // Special handling for file/media bubble to ensure proper text color
    if (type != 'text') {
      textColor = Colors.white;
    }

    // Override text color for non-current user text messages
    if (!isCurrentUser && type == 'text') {
      textColor = Colors.black;
    }

    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        constraints: const BoxConstraints(maxWidth: 300), // Limit bubble size
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isCurrentUser
                ? const Radius.circular(15)
                : const Radius.circular(0),
            bottomRight: isCurrentUser
                ? const Radius.circular(0)
                : const Radius.circular(15),
          ),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: textColor),
          child: _buildMessageContent(
            messageData,
          ), // Use the new content builder
        ),
      ),
    );
  }
}
