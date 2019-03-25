import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInScreen extends StatelessWidget {
  Future<FirebaseUser> _handleSignIn() async {
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken
    );
    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<FirebaseUser> _recordSignIn(FirebaseUser user) async {
    return Firestore.instance.collection('users').document(user.uid).setData({
      'email': user.email,
      'lastSignedInAt': DateTime.now(),
    }).then((_) => user);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text('Sign in'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              color: Colors.primaries[0],
              onPressed: () {
                _handleSignIn()
                  .then((FirebaseUser user) => _recordSignIn(user))
                  .then((FirebaseUser user) {
                    Navigator.pushReplacementNamed(context, '/home');
                  })
                  .catchError((e) => print(e));
              },
              child: Text('Googleアカウントでログイン'),
            )
          ],
        ),
      ),
    );
  }
}