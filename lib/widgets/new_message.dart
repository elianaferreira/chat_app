import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/utils/dimens.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    try {
      final enteredMessage = _messageController.text;
      if (enteredMessage.trim().isEmpty) return;

      //this could be used with Riverpod as well, instead of make another request to Firebase
      String userId = FirebaseAuth.instance.currentUser!.uid;
      final userData = await FirebaseFirestore.instance
          .collection(Constants.firestoreUsersCollectionName)
          .doc(userId)
          .get();

      FirebaseFirestore.instance
          .collection(Constants.firestoreChatsCollectionName)
          .add({
        UserMapKeys.text: enteredMessage,
        UserMapKeys.createdAt: Timestamp.now(),
        UserMapKeys.userId: userId,
        UserMapKeys.username: userData.data()![UserMapKeys.username],
        UserMapKeys.imageUrl: userData.data()![UserMapKeys.imageUrl]
      });

      _messageController.clear();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          top: Dimens.paddingMedium,
          left: Dimens.paddingMedium,
          right: Dimens.paddingMedium,
          bottom: Dimens.paddingBig),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
              controller: _messageController,
            ),
          ),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: _submitMessage,
              icon: const Icon(Icons.send))
        ],
      ),
    );
  }
}
