import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseUser _user;
  DateTime _lastSignedInAt;
  GoogleMapController _mapController;

  @override
  void initState() {
    super.initState();

    FirebaseAuth.instance.currentUser().then((user) {
      _user = user;
    }).then((_) {
      Firestore.instance.collection('users').document(_user.uid).get().then((snapshot) {
        setState(() {
          _lastSignedInAt = snapshot['lastSignedInAt'].toDate();
        });
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
                    Navigator.pushNamedAndRemoveUntil(context, '/sign_in', (_) => false)
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
