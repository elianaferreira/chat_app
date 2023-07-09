import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:chat_app/utils/constants.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Constants.firestoreChatsCollectionName)
          .orderBy(UserMapKeys.createdAt, descending: false)
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
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) =>
              Text(loadedMessages[index].data()[UserMapKeys.text]),
        );
      },
    );
  }
}
