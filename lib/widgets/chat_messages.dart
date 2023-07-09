import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/dimens.dart';
import 'package:chat_app/widgets/message_bubble.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final autheticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Constants.firestoreChatsCollectionName)
          .orderBy(UserMapKeys.createdAt, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }
        if (snapshot.hasError) {
          return const Center(
              child: Text(
            'Something went wrong.',
            style: TextStyle(color: Colors.red),
          ));
        }

        final loadedMessages = snapshot.data!.docs;
        return ListView.builder(
            padding: const EdgeInsets.all(Dimens.padding),
            reverse: true,
            itemCount: loadedMessages.length,
            itemBuilder: (context, index) {
              final chatMessage = loadedMessages[index].data();
              final nextChatMessage = index + 1 < loadedMessages.length
                  ? loadedMessages[index + 1].data()
                  : null;
              final currentMessageUserId = chatMessage[UserMapKeys.userId];
              final nextMessageUserId = nextChatMessage?[UserMapKeys.userId];
              final nextUserIsSame = currentMessageUserId == nextMessageUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                    message: chatMessage[UserMapKeys.text],
                    isMe: currentMessageUserId == autheticatedUser.uid);
              } else {
                return MessageBubble.first(
                    userImage: chatMessage[UserMapKeys.imageUrl],
                    username: chatMessage[UserMapKeys.username],
                    message: chatMessage[UserMapKeys.text],
                    isMe: currentMessageUserId == autheticatedUser.uid);
              }
            });
      },
    );
  }
}
