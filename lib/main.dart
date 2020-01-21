import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mobile_number/mobile_number.dart';
import './setup/login.dart';
import './beranda.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pena',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.yellow[800],
        accentColor: Colors.yellow[50],
      ),
      home: Loading(),
    );
  }
}

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  void initState() {
    MobileNumber.mobileNumber.then((String number) {
      String phoneNum = number.substring(2);
      FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+' + phoneNum,
        timeout: const Duration(seconds: 5),
        codeAutoRetrievalTimeout: (String verificationId) {},
        codeSent: (String verificationId, [int forceResendingToken]) {
          FirebaseAuth.instance.currentUser().then((value) {
            if (value == null) {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => Welcome(),
              ));
            }
          });
        },
        verificationCompleted: (AuthCredential phoneAuthCredential) {
          FirebaseAuth.instance
            ..signInWithCredential(phoneAuthCredential).then((data) {
              Firestore.instance
                  .collection("users")
                  .document(data.user.phoneNumber)
                  .get()
                  .then((DocumentSnapshot ds) {
                var data = ds.data;
                if (data["name"] != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) => Home(),
                  ));
                }
              });
            });
        },
        verificationFailed: (AuthException error) {},
      );
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Image.asset(
                  "image/ic_launcher.png",
                  fit: BoxFit.fitWidth,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
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
              // Slogan
              Text("Mari Silaturahmi"),
              // CostumButton
              SizedBox(height: 30.0),
              CustomButton(
                text: "MASUK",
                callback: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Login(),
                  ),
                ),
              ),
              // Footer
              SizedBox(height: 50.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
                child: Text(
                  "Jarak tidak menjadi alasan untuk silaturahmi.",
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
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
