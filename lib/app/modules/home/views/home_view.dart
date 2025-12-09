import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fb_chat/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FB Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              controller.signOut();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: controller.getUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final allUserDocs = snapshot.data?.docs ?? [];
            if (allUserDocs.isEmpty) {
              return const Center(child: Text('No users available.'));
            }
            final String currentUserId = controller.currentUserId;
            Map<String, dynamic>? currentUserData;
            List<Map<String, dynamic>> otherUsers = [];
            for (var userDoc in allUserDocs) {
              final userData = userDoc.data();
              if (userData['uid'] == currentUserId) {
                currentUserData = userData;
              } else {
                otherUsers.add(userData);
              }
            }
            List<Map<String, dynamic>> displayUsers = [];
            if (currentUserData != null) {
              displayUsers.add(currentUserData);
            }
            displayUsers.addAll(otherUsers);
            return ListView.builder(
              itemCount: displayUsers.length,
              itemBuilder: (context, index) {
                final userData = displayUsers[index];
                final email = userData['email'] ?? 'No Email';
                final uid = userData['uid'];

                final bool isSelf = uid == currentUserId;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelf ? Colors.blueAccent : Colors.grey,
                    child: Icon(
                      isSelf ? Icons.person_pin : Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    isSelf ? '$email (You)' : email,
                    style: TextStyle(
                      fontWeight: isSelf ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(isSelf ? 'This is you' : 'Tap to chat'),
                  onTap: () {
                    // Pass the user data to the ChatView
                    Get.toNamed(
                      Routes.CHAT,
                      arguments: {'friendId': uid, 'friendEmail': email},
                    );
                  },
                  trailing: isSelf
                      ? null
                      : StreamBuilder<int>(
                          stream: controller.getUnreadMessageCount(uid),
                          builder: (context, snapshot) {
                            final unreadCount = snapshot.data ?? 0;
                            if (unreadCount > 0) {
                              return Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                child: Text(
                                  unreadCount > 99
                                      ? '99+'
                                      : unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
