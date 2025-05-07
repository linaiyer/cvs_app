import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class add_manage_admin extends StatefulWidget {
  @override
  _add_manage_admin createState() => _add_manage_admin();
}

class _add_manage_admin extends State<add_manage_admin> {
  bool showLoader = false;

  TextEditingController userNameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final formKeyAdmin = GlobalKey<FormState>();

  addPatient() async {
    setState(() {
      showLoader = true;
    });
    FirebaseFirestore.instance.collection('user').add({
      'user_type': '2',
      'userName': userNameController.text,
      'password': passwordController.text,
      'name': nameController.text,
    }).then((value) => {
          print('print value id value ${value.id}'),
          FirebaseFirestore.instance.collection('user').doc(value.id).update({
            'id': value.id,
          }).whenComplete(() => {
                showSnackBar('Admin add successfully'),
                Navigator.of(context).pop(),
              }),
        });
  }

  void showSnackBar(text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding:
            const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 40),
        child: Column(
          children: <Widget>[
            SizedBox(
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Image.asset(
                          'assets/icons/back_arrow.png',
                          height: 30,
                          width: 30,
                        ),
                      ),
                      const Text(
                        'Add Admin',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            // decoration: TextDecoration.underline,
                            color: Color(0xff744EC3),
                            fontSize: 30,
                            fontFamily: 'Avenir',
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(
                        width: 30,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Divider(
                    color: Color(0xff485370),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Form(
                key: formKeyAdmin,
                child: ListView(
                  padding: const EdgeInsets.only(top: 5),
                  children: <Widget>[
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      child: TextFormField(
                        controller: userNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Color(0xffFDFCFC),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Color(0xffFDFCFC),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Color(0xffFDFCFC),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          hintText: 'User Name',
                          errorStyle: const TextStyle(color: Colors.red),
                          hintStyle: const TextStyle(
                            color: Color(0xff999999),
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                        validator: (String? s) {
                          if (s!.isEmpty) {
                            return 'Enter valid user name';
                          }
                        },
                        onSaved: (String? s) {
                          userNameController.text = s!.trim();
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      child: TextFormField(
                        controller: passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Color(0xffFDFCFC),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Color(0xffFDFCFC),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Color(0xffFDFCFC),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          hintText: 'Password',
                          errorStyle: const TextStyle(color: Colors.red),
                          hintStyle: const TextStyle(
                            color: Color(0xff999999),
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                        validator: (String? s) {
                          if (s!.isEmpty) {
                            return 'Enter valid password';
                          }
                        },
                        onSaved: (String? s) {
                          passwordController.text = s!.trim();
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0)),
                      child: TextFormField(
                        controller: nameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Color(0xffFDFCFC),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Color(0xffFDFCFC),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Color(0xffFDFCFC),
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          hintText: 'Name',
                          errorStyle: const TextStyle(color: Colors.red),
                          hintStyle: const TextStyle(
                            color: Color(0xff999999),
                            fontWeight: FontWeight.w300,
                            fontSize: 16,
                          ),
                        ),
                        validator: (String? s) {
                          if (s!.isEmpty) {
                            return 'Enter valid name';
                          }
                        },
                        onSaved: (String? s) {
                          nameController.text = s!.trim();
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    showLoader
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : ElevatedButton(
                          onPressed: () {
                            if (formKeyAdmin.currentState!.validate()) {
                              formKeyAdmin.currentState!.save();
                              addPatient();
                            }
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w400,
                                fontSize: 20),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(
                                left: 30, right: 30, top: 8, bottom: 8), backgroundColor: const Color(0xffC299F6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
