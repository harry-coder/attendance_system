import 'package:attendance_system/home/home.dart';
import 'package:attendance_system/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  Color alphaColor = Colors.red;
  double height = 0;
  double width = 0;
  TextEditingController employeeController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: height / 3,
              decoration: BoxDecoration(
                  color: alphaColor,
                  borderRadius:
                      const BorderRadius.only(bottomRight: Radius.circular(70))),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: width / 5,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 30),
              child: const Text(
                "Login Details ",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: height/2,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: <Widget>[
                  customTextField(
                      "What is your PHED ID?",
                      "Employee Id *",
                      employeeController,
                      const Icon(
                        Icons.person,
                        color: Colors.red,
                      )),
                  customTextField(
                      "Enter your special character?",
                      "Password *",
                      passwordController,
                      const Icon(
                        Icons.password_outlined,
                        color: Colors.red,
                      )),

                  InkWell(
                    onTap: () async{

                      String id=employeeController.text.trim();
                      String password=passwordController.text.trim();
                    bool? result=  validateFields(id, password);

                    if(result!=null && result==true){
                      try{
                        QuerySnapshot snap= await FirebaseFirestore.instance
                            .collection("employees")
                            .where('id',isEqualTo: id).get();


                        if(snap.docs[0]['password']==password){

                         SharedPreferences preference=await Preferences.instance.getSharedPreferenceInstance();

                         preference.setString('employeeId', id).then((value) => {
                         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>Home()))

                         });
                         
                        }
                        else{
                          showSnackbar("Invalid Password");
                        }
                      }catch(e){
                          if(e.toString()=='RangeError (index): Invalid value: Valid value range is empty: 0') {
                          showSnackbar("Emp not found");
                        }
                        else{
                          showSnackbar("Error Occured");

                        }
                      }



                    }

                    },
                    child: Container(
                      height: height / 15,
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(30)),
                      child: const Center(child: Text("Login",style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                      ),)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget customTextField(
      String hint, String label, TextEditingController controller, Icon icon) {
    return Container(
      margin: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(12)),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 5, offset: Offset(2, 2))
          ]),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            icon: icon,
            labelStyle: const TextStyle(color: Colors.red),
            hintText: hint,
            labelText: label,
            border: InputBorder.none,
          ),
          onSaved: (String? value) {
            // This optional block of code can be used to run
            // code when the user saves the form.
          },
          validator: (String? value) {
            return (value != null && value.contains('@'))
                ? 'Do not use the @ char.'
                : null;
          },
        ),
      ),
    );
  }

   void showSnackbar(String message){
     ScaffoldMessenger.of(context)
         .showSnackBar(SnackBar(content: Text(message)));
  }

  bool? validateFields(String id,String password){

    if(id.isEmpty){
      showSnackbar("Please Provide Id");
      return false;
    }
   else if(password.isEmpty){
      showSnackbar("Please Provide Password");
      return false;
    }
    else {
     return true;
    }
  }

}
