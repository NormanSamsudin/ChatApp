import 'package:chat_app/widget/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

// firebase object yang managed by firebase SDK
final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteresUsername = '';

  File? _selectedimage;

  var _isAuthenticating = false;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || !_isLogin && _selectedimage == null) {
      // kat sini boleh show error message
      return;
    }

    _form.currentState!.save();
    print('email : ${_enteredEmail}');
    print('password : ${_enteredPassword}');

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        // log users in
        final UserCredential = _firebase.signInWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);

        // nak check die dapat login ke tak
        print(UserCredential);
      } else {
        // sign up users
        // email-already-in-use:
        // Thrown if there already exists an account with the given email address.
        // invalid-email:
        // Thrown if the email address is not valid.
        // operation-not-allowed:
        // Thrown if email/password accounts are not enabled. Enable email/password accounts in the Firebase Console, under the Auth tab.
        // weak-password:
        // Thrown if the password is not strong enough.
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
            email: _enteredEmail, password: _enteredPassword);
        print(userCredentials);

        // untuk upload gambar dalam storage
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(
                '${userCredentials.user!.uid}.jpg'); // create path in the database
        // upload dalam storage
        await storageRef.putFile(_selectedimage!);

        //nak dapatkan balik url bila nak pakai gambar tu balik
        final imageUrl = await storageRef.getDownloadURL();
        print(imageUrl);

        //nak simpan url gambar yang kita dah upload tu dalam cloud firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteresUsername,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    
    
    } on FirebaseAuthException catch (error) {
      if (error.code == 'email-already-in-use') {
        //....
      }

      // kalau ada error nnti die akan show snackbar dekat bahagian bawah dgn error apa yang ada
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );

      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(
                  top: 30, bottom: 20, right: 20, left: 20),
              width: 200,
              // gambar untuk die punya icon chat
              child: Image.asset('assets/images/chat2.png'),
            ),
            Card(
              margin: EdgeInsets.all(20),
              child: SingleChildScrollView(
                  child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                            onPickImage: (pickedImage) {
                              _selectedimage = pickedImage;
                            },
                          ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          // tak nak kasi die uppercase
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredEmail = value!;
                          },
                        ),
                        
                        if (!_isLogin)
                        TextFormField(
                          decoration: InputDecoration(labelText: 'Username'),
                          enableSuggestions:
                              false, // nak keyboard bagi suggestion masa nak tulis
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.trim().length < 4) {
                              return 'Please enter at least 4 characters.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteresUsername = value!;
                          },
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return 'Password must be at least 6 characters long';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredPassword = value!;
                          },
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        if (_isAuthenticating)
                          const CircularProgressIndicator(),
                        if (!_isAuthenticating)
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                              ),
                              onPressed: _submit,
                              child: Text(_isLogin ? 'Log In' : 'Sign Up')),
                        if (!_isAuthenticating)
                          TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(_isLogin
                                  ? 'Create an Account'
                                  : 'I already have an account. Login.'))
                      ],
                    )),
              )),
            )
          ],
        )),
      ),
    );
  }
}
