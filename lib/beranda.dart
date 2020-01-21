import 'package:atchat/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import './chats.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  UserAccountsDrawerHeader userAccountsDrawerHeader;
  CollectionReference userCollection = Firestore.instance.collection("users");
  final List<Widget> chats = [];
  Map<String, dynamic> user = {};

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((val) {
      userCollection
        ..document(val.phoneNumber).get().then((DocumentSnapshot ds) {
          setState(() {
            userAccountsDrawerHeader = new UserAccountsDrawerHeader(
              accountName: Text(ds.data["name"], softWrap: true),
              accountEmail: Text(ds.data["desc"], softWrap: true),
              currentAccountPicture: CircleAvatar(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(40.0)),
                  child: ds.data["image"] != null
                      ? Image.network(ds.data["image"], fit: BoxFit.contain)
                      : Image.asset('image/user_blank.jpg',
                          fit: BoxFit.contain),
                ),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              margin: EdgeInsets.only(bottom: 10.0),
            );
            user = ds.data;
          });
        });
    });
    super.initState();
    this.loadChats();
  }

  Future loadChats() async {
    final int list = 15;

    for (var i = 1; i < list; i++) {
      setState(() {
        chats.add(
          new GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => Chats(
                person: "Person $i",
              ),
            )),
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  CircleAvatar(
                    radius: 25.0,
                    backgroundImage: AssetImage("image/user_blank.jpg"),
                  ),
                  SizedBox(height: 3.0),
                  Text(
                    "Person $i",
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          "Pena",
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            iconSize: 20.0,
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            userAccountsDrawerHeader,
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(),
            ),
            ListTile(
              title: Text("Keluar",
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                  )),
              trailing: Icon(
                Icons.close,
                color: Theme.of(context).primaryColor,
              ),
              onTap: () => showDialog(
                barrierDismissible: true,
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: Text("Yakin Ingin Keluar"),
                  content: Text(
                    "Akun anda tidak hilang ketika anda memilih keluar. Anda bisa login lain waktu.",
                    softWrap: true,
                  ),
                  actions: <Widget>[
                    FlatButton(
                      child: Text("Ya"),
                      onPressed: () => FirebaseAuth.instance.signOut()
                        ..whenComplete(() {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => Welcome(),
                            ),
                          );
                        }),
                    ),
                    FlatButton(
                      child: Text("Tidak"),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).accentColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: Column(
                children: <Widget>[
                  favoriteContacs(context),
                  chatList(context),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.chat),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {},
      ),
    );
  }

  Widget favoriteContacs(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  "Favorite Contacs",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.more_horiz),
                  iconSize: 20.0,
                  color: Colors.blueGrey,
                  onPressed: () {},
                ),
              ],
            ),
          ),
          Container(
            height: 100.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.only(left: 5.0),
              children: chats,
            ),
          ),
        ],
      ),
    );
  }

  Widget chatList(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: ListView.builder(
          itemCount: 15,
          itemBuilder: (ctx, idx) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              child: ListTile(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Chats(person: "Person $idx"),
                  ),
                ),
                leading: CircleAvatar(
                  radius: 25.0,
                  backgroundImage: AssetImage("image/user_blank.jpg"),
                ),
                title: Text("Person $idx"),
                subtitle: Text(
                  "This is Text from Person $idx",
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("4:30 PM"),
                    Text(
                      "NEW",
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
