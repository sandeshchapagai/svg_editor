import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Message {
  String senderId;
  String text;

  Message(this.senderId, this.text);

  Message.fromJson(Map<dynamic, dynamic> json)
      : senderId = json['senderId'],
        text = json['text'];

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'text': text,
      };
}

class ChatApp extends StatefulWidget {
  @override
  State<ChatApp> createState() => _MyAppState();
}

class _MyAppState extends State<ChatApp> {
  final _db = FirebaseDatabase.instance.reference();
  final _uuid = Uuid();
  late String userId;
  final TextEditingController _controller = TextEditingController();

  List<Message> messages = [];
  bool isTyping = false;
  bool otherTyping = false;

  @override
  void initState() {
    super.initState();
    userId = _uuid.v4();

    _db.child('messages').onChildAdded.listen((event) {
      final msg =
          Message.fromJson(event.snapshot.value as Map<dynamic, dynamic>);
      setState(() {
        messages.add(msg);
      });
    });

    _db.child('typing').onValue.listen((event) {
      Map? typingMap = event.snapshot.value as Map?;
      if (typingMap != null) {
        bool typing = false;
        typingMap.forEach((key, value) {
          if (key != userId && value == true) typing = true;
        });
        setState(() {
          otherTyping = typing;
        });
      }
    });
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    final msg = Message(userId, text.trim());
    _db.child('messages').push().set(msg.toJson());
    _controller.clear();
    setTyping(false);
  }

  void setTyping(bool typing) {
    _db.child('typing').child(userId).set(typing);
    setState(() {
      isTyping = typing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Anonymous Chat',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Anonymous Chat'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[messages.length - 1 - index];
                  final isMe = msg.senderId == userId;
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    alignment:
                        isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blueAccent : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                            color: isMe ? Colors.white : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (otherTyping)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Someone is typing...',
                        style: TextStyle(fontStyle: FontStyle.italic))),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(hintText: 'Type a message'),
                      onChanged: (text) {
                        setTyping(text.isNotEmpty);
                      },
                      onSubmitted: (text) {
                        sendMessage(text);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      sendMessage(_controller.text);
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
