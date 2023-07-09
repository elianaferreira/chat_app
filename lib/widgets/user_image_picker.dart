import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:chat_app/utils/dimens.dart';

class UserImagePickerScreen extends StatefulWidget {
  const UserImagePickerScreen({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<UserImagePickerScreen> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePickerScreen> {
  File? _pickedImage;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
        maxWidth: Dimens.avatarSize);

    if (pickedImage == null) return;
    setState(() {
      _pickedImage = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: Dimens.avatarRadius,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImage != null ? FileImage(_pickedImage!) : null,
        ),
        TextButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.camera),
            label: Text(
              'Add image',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ))
      ],
    );
  }
}
