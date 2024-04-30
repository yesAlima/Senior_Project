
import 'package:senior/reports_widget.dart';
import 'package:senior/side_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:senior/header_widget.dart';
class ReportsScreen extends StatelessWidget {
  const ReportsScreen({Key? key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: HeaderWidget(userName: 'Ahmed Mahmood',) ,
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: SideMenuWidget(),
            ),
            Expanded(
              flex: 7,
              child: ReportsPage(),
            ),
            
          ],
        ),
      ),
    );
  }
}
