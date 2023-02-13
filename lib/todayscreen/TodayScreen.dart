import 'dart:async';

import 'package:attendance_system/utils/UserData.dart';
import 'package:attendance_system/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_geofencing/easy_geofencing.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_to_act/slide_to_act.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({Key? key}) : super(key: key);

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  double height = 0;
  double width = 0;
  String checkoutTime="--/--";
  String checkInTime="--/--";

  static const String areaLatitude="4.766986s";
  static const String areaLongitude="7.022507";
  static const String radius="100";
  StreamSubscription<GeofenceStatus>? geofenceStatusStream;
  String geofenceStatus = '';
  bool isUserInOffice = false;
  Geolocator geolocator = Geolocator();
  bool isReady = false;
  Position? position;

  String? id="";
  var timeFormat=DateFormat('hh:mm:ss a') ;
  var monthFormat=DateFormat('MMM,yyyy') ;

  var dateFormat=DateFormat("dd:MMMM:yyyy") ;
  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    checkIfUserIsLoggedIn();

    getCheckInCheckOutTime();
    getCurrentPosition();
    checkIfUserInArea();


  }

  getCurrentPosition() async {
    position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    print("LOCATION => ${position!.toJson()}");
    isReady = (position != null) ? true : false;
  }

  void getCheckInCheckOutTime() async{
    QuerySnapshot snap=await Preferences.instance.getEmployeeSnapshot()
        .where('id',isEqualTo:UserData.userId )
        .get();

    print("Id $id");
    print(snap.docs[0].id);
    DocumentSnapshot<Map<String, dynamic>> snapShot=await Preferences.instance
        .getEmployeeDocumentSnapShot(snap.docs[0].id, dateFormat.format(DateTime.now()))
        .get();


   // print(snapShot['checkIn']);
        setState(() {
      if(snapShot.data()!=null) {
        if(snapShot.data()!.containsKey("checkIn")) {
          checkInTime=snapShot['checkIn'];
          checkoutTime=snapShot['checkOut'];
        }
      }
      else{
         checkoutTime="--/--";
         checkInTime="--/--";
      }
      });

  }

  void checkIfUserIsLoggedIn() async {
    var preference = await Preferences.instance.getSharedPreferenceInstance();
    if (preference.getString("employeeId") != null) {
      setState(() {
        id = preference.getString("employeeId");
      });
    }
    else {
      setState(() {
       id="";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome",
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.black38,
                      fontWeight: FontWeight.bold),
                ),
                 Text(
                  "Employee $id ",
                  style: const TextStyle(
                      fontSize: 30,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 30),
                  child: const Text(
                    "Today's Status",
                    style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                        fontWeight: FontWeight.w300),
                  ),
                ),
                Container(
                  height: 170,
                  width: width,
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black38,
                            blurRadius: 10,
                            offset: Offset(2, 2))
                      ]),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      checkInOut("Check-In", checkInTime),
                      checkInOut("Check-Out", checkoutTime)
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: RichText(text:  TextSpan(
                    text: DateFormat.d().format(DateTime.now()),
                   style: const TextStyle(
                    color: Colors.red,
                    fontSize: 22,
                     letterSpacing: 2
                  ),
                    children: [
                      TextSpan(text: monthFormat.format(DateTime.now()),
                        style: const TextStyle(color: Colors.black,fontSize: 20)
                      )
                    ]
                  ) ),
                ),
                 StreamBuilder(
                   stream: Stream.periodic(const Duration(seconds: 1)),
                   builder: (context,snapshot){
                     return Text(
                       timeFormat.format( DateTime.now()),
                       style: const TextStyle(
                           fontSize: 20,
                           color: Colors.black38,
                           fontWeight: FontWeight.w300),
                     );
                 }

                 ),

                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Builder(builder: (context){
                    final GlobalKey<SlideActionState> key=GlobalKey();
                    return isUserInOffice?SlideAction(
                      text: checkInTime=="--/--"?"Slide to Check In":"Slide to Check Out",
                      innerColor: Colors.red,
                      outerColor: Colors.white,
                      key: key,
                      onSubmit: () async {


                   /*QuerySnapshot snap=await Preferences.instance.getEmployeeSnapshot()
                        .where('id',isEqualTo:id ).get();

              DocumentSnapshot<Map<String, dynamic>> snapShot=await Preferences.instance
                  .getEmployeeDocumentSnapShot(snap.docs[0].id, dateFormat.format(DateTime.now()))
                  .get();

                   if(snapShot.data()!=null){
                     if(snapShot.data()!.containsKey("checkIn")) {
                       await Preferences.instance
                           .getEmployeeDocumentSnapShot(snap.docs[0].id, dateFormat.format(DateTime.now()))
                           .update({
                         'checkIn': timeFormat.format(DateTime.now()),
                         'checkOut': timeFormat.format(DateTime.now())
                       });
                     }
                   }
                   else{
                     await Preferences.instance
                         .getEmployeeDocumentSnapShot(snap.docs[0].id, dateFormat.format(DateTime.now()))
                         .set({
                       'checkIn': timeFormat.format(DateTime.now()),
                       'checkOut': timeFormat.format(DateTime.now())
                     });
                   }


                   print(snap.docs[0].id);
*/


                        key.currentState!.reset();
                      },

                    ):const Text(
                      "Please be at office to mark your attendance",
                        style: TextStyle(
                        fontSize: 20,
                        color: Colors.black38,
                        fontWeight: FontWeight.w300),
                    );
                  }),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

   void checkIfUserInArea(){
     EasyGeofencing.startGeofenceService(
         pointedLatitude: areaLatitude,
         pointedLongitude: areaLongitude,
         radiusMeter: radius,
         eventPeriodInSeconds: 5);
     geofenceStatusStream ??= EasyGeofencing.getGeofenceStream()!
           .listen((GeofenceStatus status) {
         print("Status of user "+status.toString());
         setState(() {
           geofenceStatus = status.toString();

           if(status.toString()=="GeofenceStatus.enter"){
             isUserInOffice=true;
           }
           else {
             isUserInOffice=false;
           }
         });
       });
   }
  Widget checkInOut(String heading, String time) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          heading,
          style: const TextStyle(
              fontSize: 20, color: Colors.black38, fontWeight: FontWeight.w400),
        ),
        Text(
          time,
          style: const TextStyle(
              fontSize: 25, color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
