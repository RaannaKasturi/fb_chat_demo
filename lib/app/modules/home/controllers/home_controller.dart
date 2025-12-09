// home_controller.dart

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fb_chat/app/routes/app_pages.dart';
import 'package:fb_chat/app/ui_utils/toast.dart';
import 'package:rxdart/rxdart.dart' show CombineLatestStream;

class HomeController extends GetxController {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseAuth auth = FirebaseAuth.instance;

  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Helper function to get the chat room ID
  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort();
    return ids.join('_');
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getUsers() {
    return firestore.collection('users').orderBy('email').snapshots();
  }

  // New: Stream to get the unread message count
  Stream<int> getUnreadMessageCount(String friendId) {
    final chatId = getChatRoomId(currentUserId, friendId);

    // 1. Stream for the lastRead timestamp
    final userLastReadStream = firestore
        .collection('users')
        .doc(currentUserId)
        .collection('chats')
        .doc(friendId)
        .snapshots()
        // Ensure the data type is explicit for the combiner
        .map((doc) => doc.data());

    // 2. Stream for latest messages (for efficiency)
    final messagesStream = firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots();

    // CORRECTED: Use the CombineLatestStream constructor
    return CombineLatestStream([userLastReadStream, messagesStream], (list) {
      // list[0] is the Map<String, dynamic>? from userLastReadStream
      final Map<String, dynamic>? lastReadData =
          list[0] as Map<String, dynamic>?;
      // list[1] is the QuerySnapshot<Map<String, dynamic>> from messagesStream
      final QuerySnapshot<Map<String, dynamic>> messagesSnapshot =
          list[1] as QuerySnapshot<Map<String, dynamic>>;

      if (messagesSnapshot.docs.isEmpty) {
        return 0; // No messages
      }

      // Get the last read timestamp, defaulting to epoch if not set
      final lastReadTimestamp =
          (lastReadData?['lastRead'] as Timestamp?) ??
          Timestamp.fromMillisecondsSinceEpoch(0);

      // Calculate unread count
      final unreadCount = messagesSnapshot.docs.where((messageDoc) {
        final messageData = messageDoc.data();
        final messageTimestamp = messageData['timestamp'] as Timestamp;
        final senderId = messageData['senderId'];

        // Unread if: message timestamp is greater than lastRead, AND sender is not the current user
        return messageTimestamp.compareTo(lastReadTimestamp) > 0 &&
            senderId != currentUserId;
      }).length;

      return unreadCount;
    });
  }

  // Existing sign out function
  void signOut() async {
    // ... (existing code)
    try {
      await auth.signOut();
      ShowToast.success('Signed out successfully.');
      Get.offAllNamed(Routes.LOGIN);
    } on FirebaseAuthException catch (e) {
      ShowToast.error('Sign out failed: ${e.message}');
    } catch (e) {
      ShowToast.error(e.toString());
    }
  }
}
