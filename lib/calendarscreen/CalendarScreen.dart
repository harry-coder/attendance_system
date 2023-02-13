import 'package:attendance_system/utils/UserData.dart';
import 'package:attendance_system/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:month_year_picker/month_year_picker.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  double height = 0;
  double width = 0;
  String checkoutTime = "--/--";
  String checkInTime = "--/--";

  String? id = "";
  var timeFormat = DateFormat('hh:mm:ss a');

  var monthFormat = DateFormat('MMM,yyyy');

  var dateFormat = DateFormat("dd:MMMM:yyyy");

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDocId(UserData.userId);
  }
  void getDocId(String userId) async {
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("employees")
        .where('id', isEqualTo: userId)
        .get();
    setState(() {
      UserData.id = snap.docs[0].id;
    });
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                "My Attendance",
                style: TextStyle(
                    fontSize: 25,
                    color: Colors.black38,
                    fontWeight: FontWeight.bold),
              ),
              Container(
                margin: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat.MMM().format(DateTime.now()),
                      style: const TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    InkWell (
                      onTap: () async{
                        final selected = await showMonthYearPicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2019),
                          lastDate: DateTime(2023),
                        );
                      },
                      child: const Text(
                        "Select Month",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: Preferences.instance
                      .getEmployeeSnapshot()
                      .doc(UserData.id)

                      .collection("record")
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      final snap = snapshot.data?.docs;
                      return ListView.builder(
                        itemCount: snap?.length,
                        itemBuilder: (context, index) {
                          return Container(
                            height: 170,
                            width: width,
                            margin: const EdgeInsets.only(top: 20),
                            decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black38,
                                      blurRadius: 10,
                                      offset: Offset(2, 2))
                                ]),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  width: 100,
                                  child: const Center(
                                    child: Text(
                                      "11-jan 2023",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ),
                                checkInOut(
                                    "Check-In",
                                    snap![index]["checkIn"]
                                        .toString()
                                        .substring(0, 5)),
                                checkInOut(
                                    "Check-Out",
                                    snap![index]["checkOut"]
                                        .toString()
                                        .substring(0, 5))
                              ],
                            ),
                          );
                        },
                      );
                    } else {
                      return const SizedBox();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget checkInOut(String heading, String time) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            heading,
            style: const TextStyle(
                fontSize: 20,
                color: Colors.black38,
                fontWeight: FontWeight.w400),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            time,
            style: const TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
