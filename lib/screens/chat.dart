import 'package:chat_app/widget/chat_messages.dart';
import 'package:chat_app/widget/new_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  // so kne buat function dekat luar

  void setupPushNotofications() async {
    final fcm = FirebaseMessaging.instance;
    // request permission untuk push notification
    await fcm.requestPermission();

    // sebagai address of the device
    final token = await fcm.getToken();
    print('tokennnnn ${token}');

    // bila dah dapat token fcm ni bole jer buat manually untuk send notification tapi kita kne pakai http untuk request dekat backend

    // sesiapa yang ada topic chat ni mmg die akan dapat notification ni
    fcm.subscribeToTopic('chat');
  }
  
  //will only run once when widget is loaded
  // initstate ni tak boleh async flutter tak bagi
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //await function
    setupPushNotofications();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).colorScheme.primary,
            ),
          )
        ],
      ),
      body: const Column(
        children: [
          Expanded(child: ChatMessages()),
          NewMessage(),
        ],
      ),
    );
  }
}
