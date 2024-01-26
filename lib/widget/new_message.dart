import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
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
    final enteredMessage = _messageController.text;

    //check entered message
    if (enteredMessage.trim().isEmpty) {
      return;
    }

    // cara nak tutup keyboard lepas dh habis guna
    FocusScope.of(context).unfocus();

     // nak clear textfield sbb takut nnti user ingat tak ber jaya hantar pulak
     // dan kne letak awal jgk mnde ni takut waiting lama sgt nak connect dgn database 
    _messageController.clear();

    //nak dapatkan siapa penghantar
    final user = FirebaseAuth.instance
        .currentUser!; // sbb kita dah dalam keadaan log in so ni cara nak acces die balik

    // nak dapatkan username dan imageurl dari firestore
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    //sent to firebase
    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
      'username': userData.data()!['username'], // kne retrieve dari firestore
      'userImage': userData.data()!['image_url'], // kne retrieve dari firestore

      //tapi ada cara lain jgk sebenarnya boleh jer pakai riverpod untuk save data username dan userimage dalam memory
      //
    });

    
    
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
              // textfield kalau nak ada dalam row mesti kne ada expanded
              child: TextField(
            controller: _messageController,
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
            decoration: InputDecoration(labelText: 'Send a message ...'),
          )),
          IconButton(
              color: Theme.of(context).colorScheme.primary,
              onPressed: _submitMessage,
              icon: Icon(Icons.send))
        ],
      ),
    );
  }
}
