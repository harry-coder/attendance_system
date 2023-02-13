  import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static final Preferences instance = Preferences._internal();
  factory Preferences() {
  return instance;
  }

  Future<SharedPreferences> getSharedPreferenceInstance() async {
    return await SharedPreferences.getInstance();
  }

  CollectionReference<Map<String,dynamic>> getEmployeeSnapshot() {
   return  FirebaseFirestore.instance
        .collection("employees");
  }

  DocumentReference<Map<String,dynamic>> getEmployeeDocumentSnapShot(String id,String docValue){
  return  FirebaseFirestore.instance
        .collection("employees")
        .doc(id)
        .collection("record")
        .doc(docValue);
  }
  Preferences._internal();
  }


