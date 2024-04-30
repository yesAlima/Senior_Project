
import 'package:senior/treatment_record.dart';
import 'package:flutter/material.dart';
import 'package:senior/header_widget.dart';
import 'package:senior/side_menu_widget.dart';

class TreatmentRecordScreen extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HeaderWidget(userName: 'Ahmed Mahmood'),
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SideMenuWidget(),
            ),
            Expanded(
              flex: 9,
              child: TreatmentRecordPage(),
            ),
          ],
        ),
      ),
    );
  }
}