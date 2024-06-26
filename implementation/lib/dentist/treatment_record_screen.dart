import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:senior/dentist/side_menu_widget.dart';
import 'package:senior/dentist/header_widget.dart';
import 'package:senior/dentist/treatment_record.dart';

class TreatmentRecordScreen extends StatelessWidget {
  const TreatmentRecordScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    bool isWeb = MediaQuery.of(context).size.width > 800;

    return isWeb
        ? StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('user').doc(uid).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final fullName = snapshot.data?.get('FullName') ?? '';
                final firstName = fullName.split(' ')[0];

                return Scaffold(
                  appBar: HeaderWidget(userName: firstName),
                  body: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: SideMenuWidget(),
                              ),
                              Expanded(
                                flex: 9,
                                child: Container(
                                  child: TreatmentRecordPage(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return SpinKitFadingCube(
                  size: 30,
                  color: Colors.blue,
                );
              }
            },
          )
        : Scaffold(
            appBar: AppBar(
              title: Text('Mobile View', style: TextStyle(color: Colors.red)),
              actions: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
            body: Center(
              child: Text(
                'You cannot use this page unless you are on the web.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
  }
}
