import 'package:attendance_system/home/home.dart';
import 'package:attendance_system/login/Login.dart';
import 'package:attendance_system/utils/UserData.dart';
import 'package:attendance_system/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:month_year_picker/month_year_picker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context)  {
    return const MaterialApp (
      title: 'Flutter Demo',
      localizationsDelegates: [
        MonthYearPickerLocalizations.delegate,
      ],

      home:  AuthCheck()
    );
  }


}
class AuthCheck extends StatefulWidget {
 const AuthCheck({Key? key}) : super(key: key);



  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkIfUserIsLoggedIn();
  }

  bool isCurrentUser=false;


  void checkIfUserIsLoggedIn() async {
    var preference = await Preferences.instance.getSharedPreferenceInstance();
    if (preference.getString("employeeId") != null) {
      setState(() {
        isCurrentUser = true;
        String userId=preference.getString("employeeId")??"";
        UserData.userId=userId;

      });

    }
    else {
      setState(() {
        isCurrentUser = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return isCurrentUser?const Home():const Login();
  }
}


