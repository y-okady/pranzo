import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  runApp(MaterialApp(
    title: 'Pranzo',
    home: SignInPage(),
  ));
}

class SignInPage extends StatelessWidget {
  SignInPage({Key key}): super(key: key);

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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(user: user)
                      ),
                    );
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

class HomePage extends StatefulWidget {
  final FirebaseUser user;
  HomePage({Key key, @required this.user}): super(key: key);

  @override
  _HomePageState createState() => _HomePageState(user);
}

class _HomePageState extends State<HomePage> {
  FirebaseUser _user;
  _HomePageState(this._user);

  DateTime _lastSignedInAt;
  GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();

    Firestore.instance.collection('users').document(_user.uid).get().then((snapshot) {
      setState(() {
        _lastSignedInAt = snapshot['lastSignedInAt'].toDate();
      });
    });
  }

  Future<void> _handleSignOut() async {
    return await FirebaseAuth.instance.signOut();
  }

  void _handleMapCreate(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              color: Colors.primaries[0],
              onPressed: () {
                _handleSignOut()
                  .then((_) => {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SignInPage()
                      ),
                      (_) => false
                    )
                  })
                  .catchError((e) => print(e));
              },
              child: Text('ログアウト'),
            ),
            Text(
              _lastSignedInAt != null ? '最終ログイン日時: $_lastSignedInAt' : '',
            ),
            Container(
              height: MediaQuery.of(context).size.height / 2,
              width: MediaQuery.of(context).size.width,
              child: GoogleMap(
                onMapCreated: _handleMapCreate,
                initialCameraPosition: CameraPosition(
                  target: LatLng(35.6580339,139.7016358),
                  zoom: 17.0,
                ),
                myLocationEnabled: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}
