import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Chats extends StatefulWidget {
  final String person;

  Chats({this.person});

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  CollectionReference ref = Firestore.instance.collection("chats");
  CollectionReference userRef = Firestore.instance.collection("users");

  TextEditingController text = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: new Text(
          widget.person,
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 15.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert),
            iconSize: 20.0,
            color: Colors.white,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              color: Colors.white,
              child: StreamBuilder<QuerySnapshot>(
                stream: ref
                    .where("idChat", isEqualTo: "+62895623272311")
                    .orderBy("date", descending: true)
                    .snapshots(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
                  if (snapshot.hasError)
                    return new Text('Error: ${snapshot.error}');
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return new Text('Loading...');
                    default:
                      return new ListView(
                        dragStartBehavior: DragStartBehavior.down,
                        reverse: true,
                        children: snapshot.data.documents
                            .map((DocumentSnapshot document) {
                          return new Container(
                            margin: document['from'] != '+6285218584440'
                                ? EdgeInsets.only(
                                    top: 10.0,
                                    bottom: 10.0,
                                    right: 30.0,
                                  )
                                : EdgeInsets.only(
                                    top: 10.0,
                                    bottom: 10.0,
                                    left: 30.0,
                                  ),
                            decoration: BoxDecoration(
                              boxShadow: <BoxShadow>[
                                BoxShadow(
                                  blurRadius: 20.0,
                                  color: Colors.black54,
                                  offset: document["from"] != '+6285218584440'
                                      ? Offset(10, 10)
                                      : Offset(-10, 10),
                                ),
                              ],
                              color: document['from'] != '+6285218584440'
                                  ? Theme.of(context).accentColor
                                  : Colors.yellow[400],
                              borderRadius: document['from'] != '+6285218584440'
                                  ? BorderRadius.only(
                                      bottomRight: Radius.circular(10.0),
                                      topRight: Radius.circular(10.0),
                                    )
                                  : BorderRadius.only(
                                      bottomLeft: Radius.circular(10.0),
                                      topLeft: Radius.circular(10.0),
                                    ),
                            ),
                            child: new ListTile(
                              title: new Text(document['from']),
                              subtitle: new Text(
                                document['text'],
                                softWrap: true,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                  }
                },
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              color: Theme.of(context).primaryColor,
            ),
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  color: Colors.white,
                  iconSize: 22.0,
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.0,
                      vertical: 6.0,
                    ),
                    child: TextField(
                      controller: text,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration.collapsed(
                        filled: true,
                        hintText: 'Kirim Pesan...',
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Colors.white,
                  iconSize: 22.0,
                  onPressed: sendText,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  sendText() async {
    await ref.document().setData({
      'idChat': '+62895623272311',
      'date': Timestamp.now(),
      'from': '+6285218584440',
      'to': '+62895623272311',
      'text': text.text,
    }).whenComplete(() {
      setState(() {
        text.text = '';
      });
    });
  }
}
