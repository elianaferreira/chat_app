import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:chat_app/utils/dimens.dart';
import 'package:chat_app/utils/constants.dart';
import 'package:chat_app/widgets/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthState();
  }
}

class _AuthState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  String _enteredEmail = '';
  String _enteredPasword = '';
  String _enteredUsername = '';
  File? _selectedImage;
  bool _isLoginMode = true;
  bool _isAuthenticating = false;

  void _submit() async {
    final isValidForm = _formKey.currentState!.validate();

    if (!isValidForm || (!_isLoginMode && _selectedImage == null)) return;

    _formKey.currentState!.save();
    try {
      setState(() {
        _isAuthenticating = true;
      });
      if (_isLoginMode) {
        await _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPasword);
      } else {
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPasword);
        //upload image
        final storageRef = FirebaseStorage.instance
            .ref()
            .child(Constants.firebaseImageStoragePath)
            .child(
                '${userCredentials.user!.uid}${Constants.firebaseImageExtension}');
        await storageRef.putFile(_selectedImage!);
        String imageUrl = await storageRef.getDownloadURL();
        await FirebaseFirestore.instance
            .collection(Constants.firestoreUsersCollectionName)
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUsername,
          'email': _enteredEmail,
          'image_url': imageUrl
        });
      }
    } on FirebaseAuthException catch (err) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.message ?? 'Authentication failed')));
    } finally {
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      body: Center(
        child: SingleChildScrollView(
          child: Stack(children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(Dimens.padding),
                  width: Dimens.logoSize,
                  child: Image.asset('assets/images/chat.png'),
                ),
                Card(
                  margin: const EdgeInsets.all(Dimens.padding),
                  child: Padding(
                    padding: const EdgeInsets.all(Dimens.padding),
                    child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!_isLoginMode)
                              UserImagePickerScreen(
                                onPickImage: (pickedImage) {
                                  _selectedImage = pickedImage;
                                },
                              ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  label: Text('Email address')),
                              keyboardType: TextInputType.emailAddress,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty ||
                                    !EmailValidator.validate(value)) {
                                  return 'Please enter a valid email address.';
                                }
                                return null;
                              },
                              onSaved: (newValue) => _enteredEmail = newValue!,
                            ),
                            TextFormField(
                              decoration: const InputDecoration(
                                  label: Text('Password')),
                              obscureText: true,
                              autocorrect: false,
                              textCapitalization: TextCapitalization.none,
                              validator: (value) {
                                if (value == null || value.trim().length < 6) {
                                  return 'Password must be at least 6 characters long.';
                                }
                                return null;
                              },
                              onSaved: (newValue) =>
                                  _enteredPasword = newValue!,
                            ),
                            if (!_isLoginMode)
                              TextFormField(
                                decoration: const InputDecoration(
                                    label: Text('Username')),
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                enableSuggestions: false,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 4) {
                                    return 'Please enter a valid username (at least 4 characters).';
                                  }
                                  return null;
                                },
                                onSaved: (newValue) =>
                                    _enteredUsername = newValue!,
                              ),
                            const SizedBox(height: Dimens.padding),
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer),
                              child: Text(_isLoginMode ? 'Login' : 'Signup'),
                            ),
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLoginMode = !_isLoginMode;
                                  });
                                },
                                child: Text(_isLoginMode
                                    ? 'Create an account'
                                    : 'I already have an account'))
                          ],
                        )),
                  ),
                )
              ],
            ),
            if (_isAuthenticating)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  color: Colors.white38,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              )
          ]),
        ),
      ),
    );
  }
}
