import 'dart:io';

import 'package:atchat/setup/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

import '../beranda.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  FirebaseUser user;
  CollectionReference userCollection = Firestore.instance.collection("users");

  bool isLoading = true;
  File image;
  String filename;

  TextEditingController nameCo = new TextEditingController();
  TextEditingController descCo = new TextEditingController();

  @override
  void initState() {
    FirebaseAuth.instance.currentUser().then((val) {
      userCollection
        ..document(val.phoneNumber).get().then((DocumentSnapshot ds) {
          if (ds.data == null) {
            userCollection.document(val.phoneNumber).setData({
              'uid': val.uid,
              'phone': val.phoneNumber,
              'name': ' ',
              'desc': ' ',
              'image': ' ',
            }).whenComplete(() {
              setState(() {
                this.isLoading = false;
                this.user = val;
              });
            });
          } else {
            setState(() {
              this.isLoading = false;
              this.user = val;
            });
          }
        });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: isLoading == true
            ? Center(
                child: CircularProgressIndicator(backgroundColor: Colors.black))
            : Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Center(
                      child: Hero(
                        tag: 'logo',
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Image.asset(
                            "image/ic_launcher.png",
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                    // Pembuka
                    SizedBox(height: 10.0),
                    Row(
                      children: <Widget>[
                        CustomButton(
                          callback: getImage,
                          widget: CircleAvatar(
                            child: ClipRRect(
                              borderRadius: BorderRadius.all(
                                Radius.circular(40.0),
                              ),
                              child: image == null
                                  ? Image.asset(
                                      "image/user_blank.jpg",
                                      fit: BoxFit.fill,
                                    )
                                  : Image.file(image, fit: BoxFit.fill),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              TextField(
                                controller: nameCo,
                                decoration: InputDecoration(
                                  hintText: "Masukkan Nama Anda",
                                ),
                              ),
                              TextField(
                                controller: descCo,
                                maxLines: null,
                                keyboardType: TextInputType.multiline,
                                decoration: InputDecoration(
                                  hintText: "Deskripsikan diri anda",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Material(
                          elevation: 6.0,
                          borderRadius: BorderRadius.circular(20.0),
                          color: Theme.of(context).primaryColor,
                          child: MaterialButton(
                            onPressed: () {
                              if (nameCo.text == null) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text("Nama Tidak Boleh Kosong"),
                                    );
                                  },
                                );
                              } else if (descCo.text == null) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text("Desc Tidak Boleh Kosong"),
                                    );
                                  },
                                );
                              } else if (image == null) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      content: Text("Foto Tidak Boleh Kosong"),
                                    );
                                  },
                                );
                              } else {
                                setDataUser(context);
                              }
                            },
                            minWidth: 150.0,
                            height: 35,
                            child: Text(
                              "Buat Akun",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future getImage() async {
    var selectedImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      image = selectedImage;
      filename = basename(image.path);
    });
  }

  setDataUser(BuildContext context) async {
    StorageReference ref = FirebaseStorage.instance.ref().child(filename);
    StorageUploadTask task = ref.putFile(image);

    var downUrl = await (await task.onComplete).ref.getDownloadURL();

    userCollection
      ..document(user.phoneNumber).updateData({
        'name': nameCo.text,
        'desc': descCo.text,
        'image': downUrl.toString(),
      }).whenComplete(() {
        Navigator.of(context).removeRoute(MaterialPageRoute(
          builder: (context) => Login(),
        ));
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => Home(),
        ));
      });
  }
}

// CostumButton
class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final Widget widget;

  const CustomButton({Key key, this.callback, this.widget}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Material(
        borderRadius: BorderRadius.circular(50.0),
        child: MaterialButton(
          onPressed: callback,
          child: widget,
        ),
      ),
    );
  }
}
