import 'dart:async';
import 'package:atchat/beranda.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_number/mobile_number.dart';

import './register.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String phoneNmr;
  String smsCode;
  String verifyId;

  CollectionReference userCollection = Firestore.instance.collection("users");

  TextEditingController numCo = new TextEditingController();

  @override
  void initState() {
    MobileNumber.mobileNumber.then((String number) {
      setState(() {
        this.phoneNmr = '+' + number.substring(2);
        this.numCo.text = '+' + number.substring(2);
      });
    });
    super.initState();
  }

  Future<void> verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verifyId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verifyId = verId;
      showSmsDialog(context).then((value) {
        print('Signed In');
      });
    };

    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      FirebaseAuth.instance
        ..signInWithCredential(user).then((data) {
          Firestore.instance
            ..collection("users")
                .document(data.user.phoneNumber)
                .get()
                .then((DocumentSnapshot ds) {
              if (ds.data["name"] != null) {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Home(),
                ));
              } else {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => Register(),
                ));
              }
            });
        });
    };

    final PhoneVerificationFailed verifiedFailed = (AuthException exception) {
      print('${exception.message}');
    };

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: this.phoneNmr,
      codeAutoRetrievalTimeout: autoRetrieve,
      codeSent: smsCodeSent,
      timeout: const Duration(seconds: 5),
      verificationCompleted: verifiedSuccess,
      verificationFailed: verifiedFailed,
    );
  }

  Future<bool> showSmsDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Masukkan kode dari sms"),
          content: TextField(
            onChanged: (value) {
              setState(() {
                this.smsCode = value;
              });
            },
          ),
          contentPadding: EdgeInsets.all(10.0),
          actions: <Widget>[
            FlatButton(
              child: Text("Selesai"),
              onPressed: () {
                FirebaseAuth.instance.currentUser().then((user) {
                  if (user != null) {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => Register(),
                    ));
                  } else {
                    Navigator.of(context).pop();
                    signIn();
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  signIn() {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verifyId,
      smsCode: smsCode,
    );

    FirebaseAuth.instance.signInWithCredential(credential).then((user) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => Register(),
      ));
    }).catchError((e) {
      print(e);
      return e;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                // Logo Pena
                Hero(
                  tag: 'logo',
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    child: Image.asset(
                      "image/ic_launcher.png",
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                // Pembuka
                SizedBox(height: 10.0),
                Text("Login dengan nomor kontak anda."),
                TextField(
                  controller: numCo,
                  keyboardType: TextInputType.phone,
                  inputFormatters: <TextInputFormatter>[],
                  decoration: InputDecoration(hintText: '+628xxxxxxxxxx'),
                  onChanged: (value) {
                    setState(() {
                      this.phoneNmr = value;
                    });
                  },
                ),
                SizedBox(height: 10.0),
                CustomButton(
                  text: "Login",
                  callback: verifyPhone,
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Text(
                    "Untuk nomor kontak baru akan langsung di daftarkan dan otomatis login.",
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// CostumButton
class CustomButton extends StatelessWidget {
  final VoidCallback callback;
  final String text;

  const CustomButton({Key key, this.callback, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 6.0,
        borderRadius: BorderRadius.circular(30.0),
        color: Theme.of(context).primaryColor,
        child: MaterialButton(
          onPressed: callback,
          minWidth: 200.0,
          height: 45,
          child: Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
