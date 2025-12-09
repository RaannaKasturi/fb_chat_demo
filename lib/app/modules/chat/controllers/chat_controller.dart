import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fb_chat/app/ui_utils/toast.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController messageController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  late final String friendId;
  late final String friendEmail;
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      friendId = Get.arguments['friendId'];
      friendEmail = Get.arguments['friendEmail'];
    }
    _markChatAsRead();
  }

  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  void _markChatAsRead() async {
    try {
      // Writes the current time to the 'lastRead' field for this chat
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('chats')
          .doc(friendId)
          .set({'lastRead': Timestamp.now()}, SetOptions(merge: true));
    } catch (e) {
      // Handle error if necessary
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages() {
    final chatId = getChatRoomId(currentUserId, friendId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // --- New File/Media Sharing Logic ---

  Future<void> pickAndSendMedia(
    ImageSource source, {
    bool isVideo = false,
  }) async {
    try {
      final XFile? pickedFile;
      if (isVideo) {
        pickedFile = await _picker.pickVideo(source: source);
      } else {
        pickedFile = await _picker.pickImage(source: source);
      }

      if (pickedFile != null) {
        final filePath = pickedFile.path;
        final fileType = isVideo ? 'video' : 'image';
        await _uploadAndSendMessage(File(filePath), fileType);
      }
    } catch (e) {
      ShowToast.error('Failed to pick media: $e');
    }
  }

  Future<void> pickAndSendFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Allows picking any file type
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        await _uploadAndSendMessage(File(filePath), 'file', fileName: fileName);
      }
    } catch (e) {
      ShowToast.error('Failed to pick file: $e');
    }
  }

  Future<void> _uploadAndSendMessage(
    File file,
    String type, {
    String? fileName,
  }) async {
    ShowToast.info(
      "Required FireBase Blaze Plan for File Uploading. Hence not implemented.",
    );
  }

  void sendMessage({
    String? message,
    String type = 'text',
    String? fileUrl,
    String? fileName,
  }) async {
    final text = message ?? messageController.text.trim();

    if (text.isNotEmpty || fileUrl != null) {
      final chatId = getChatRoomId(currentUserId, friendId);
      final timestamp = Timestamp.now();

      final newMessage = {
        'senderId': currentUserId,
        'senderEmail': _auth.currentUser!.email,
        'receiverId': friendId,
        'message': text,
        'type': type, // Store the message type
        'fileUrl': fileUrl, // Store the file/media URL
        'fileName': fileName, // Store the original file name for documents
        'timestamp': timestamp,
      };

      try {
        await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add(newMessage);

        // Only clear the text controller if it was a text message
        if (type == 'text') {
          messageController.clear();
        }
      } catch (e) {
        ShowToast.error('Failed to send message: $e');
      }
    }
  }

  // Helper for showing media source options
  void showMediaPickerOptions() {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              title: const Text(
                'Required Firebase Blaze Plan for File Uploading. Hence not implemented.',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              onTap: () {
                Get.back();
              },
            ),
            Container(height: 1, color: Colors.grey[300]),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Image from Gallery'),
              onTap: () {
                Get.back();
                pickAndSendMedia(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Image from Camera'),
              onTap: () {
                Get.back();
                pickAndSendMedia(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: const Text('Video from Gallery'),
              onTap: () {
                Get.back();
                pickAndSendMedia(ImageSource.gallery, isVideo: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Any File (Document)'),
              onTap: () {
                Get.back();
                pickAndSendFile();
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
