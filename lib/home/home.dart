import 'package:attendance_system/calendarscreen/CalendarScreen.dart';
import 'package:attendance_system/profilescreen/ProfileScreen.dart';
import 'package:attendance_system/todayscreen/TodayScreen.dart';
import 'package:attendance_system/utils/UserData.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int selectedIndex = 0;

  List<IconData> icons = [
    Icons.calendar_month,
    Icons.check,
    Icons.account_circle,
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          margin: const EdgeInsets.all(20),
          height: 70,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black38, blurRadius: 20, offset: Offset(2, 2))
              ]),
          child: Row(
            children: [
              for (int i = 0; i < icons.length; i++) ...<Expanded>{
                Expanded(
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            selectedIndex = i;
                          });
                        },
                        child: Icon(
                          icons[i],
                          color:
                              i == selectedIndex ? Colors.red : Colors.black38,
                          size: i == selectedIndex ? 30 : 25,
                        ))),
              }
            ],
          ),
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: const [
            CalendarScreen(),
            TodayScreen(),
            ProfileScreen(),
          ],
        ));
  }
}
