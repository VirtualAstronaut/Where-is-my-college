import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as Path;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:percent_indicator/percent_indicator.dart';
import 'design.dart';

bool isDarkThemeOn = false;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // runApp(MaterialApp(
  //   home: HomePage(),
  // ));
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  Widget defaultScreen = HomePage();

  prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('admin')) {
    defaultScreen = AddInfo();
  }
  if (prefs.getString('user') != null && !prefs.containsKey('admin')) {
    defaultScreen = Dashboard();
  }
  // print(prefs.getBool('admin'));
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: defaultScreen,
    theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(color: Colors.black, elevation: 1),
        iconTheme: IconThemeData(color: Colors.white)),
  ));
}

final firestoreInstance = Firestore.instance;
TextEditingController username = TextEditingController();
TextEditingController password = TextEditingController();
SharedPreferences prefs;

class AddInfo extends StatefulWidget {
  @override
  _AddInfoState createState() => _AddInfoState();
}

class _AddInfoState extends State<AddInfo> {
  File image;
  String _location;
  String _fileName;
  final picker = ImagePicker();
  StorageReference storageReference;
  StorageUploadTask storageUploadTask;

  Function(String) _seatValidator = (val) {
    bool isValid = RegExp(r"^[0-9]").hasMatch(val);
    if (!isValid) {
      return 'Please Enter Number Correctly';
    }
    if (val.isEmpty) {
      return 'Please Enter Something';
    }
    return null;
  };
  proccessImage() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      image = File(pickedImage.path);
    });
    _fileName = Path.basename(image.path);
    storageReference = _firebaseStorage.ref().child('images/$_fileName');
  }

  uploadPicture(BuildContext context) async {
    setState(() {
      storageUploadTask = storageReference.putFile(image);
    });
    _location = await (await storageUploadTask.onComplete).ref.getDownloadURL();
    int randomID = getRandomNumber();
    QuerySnapshot querySnap = await firestoreInstance
        .collection('Colleges')
        .where('collegeID', isEqualTo: randomID)
        .getDocuments();

    if (querySnap.documents.isNotEmpty) {
      randomID = getRandomNumber();
    }
    firestoreInstance.collection('Colleges').add({
      "Address": addressCTL.text,
      "Name": nameCTL.text,
      "Number": numberCTL.text,
      "city": cityCTL.text,
      "fees": feesCTL.text,
      "cecutoff": int.parse(cecutoffCTL.text),
      "mecutoff": int.parse(mecutoffCTL.text),
      "cicutoff": int.parse(cicutoffCTL.text),
      "elcutoff": int.parse(elcutoffCTL.text),
      "img": _location,
      "collegeID": randomID.toString()
    }).then((value) {
      // return showDialog(
      //     context: context,
      //     builder: (BuildContext _context) {
      //       return AlertDialog(
      //         title: Text('Added data'),
      //         actions: <Widget>[
      //           TextButton(
      //               onPressed: () {
      //                 clearScreenOneFields();
      //                 Navigator.of(context).pop();
      //               },
      //               child: Text('OK'))
      //         ],
      //       );
      //     });
    });
  }

  getRandomNumber() {
    return Random().nextInt(999999);
  }

  Function(String) basicValidator = (value) {
    if (value.isEmpty) {
      return 'Please Enter Something';
    }
  };
  final TextEditingController nameCTL = TextEditingController();
  final TextEditingController addressCTL = TextEditingController();
  final TextEditingController cityCTL = TextEditingController();
  final TextEditingController numberCTL = TextEditingController();
  final TextEditingController cecutoffCTL = TextEditingController();
  final TextEditingController elcutoffCTL = TextEditingController();
  final TextEditingController mecutoffCTL = TextEditingController();
  final TextEditingController cicutoffCTL = TextEditingController();
  final TextEditingController tfwsCTL = TextEditingController();
  final TextEditingController collegeNameCTl = TextEditingController();
  final TextEditingController cityNameCTL = TextEditingController();
  final TextEditingController feesCTL = TextEditingController();
  final TextEditingController generalCTL = TextEditingController();
  final TextEditingController obcCTL = TextEditingController();
  final TextEditingController scstCTL = TextEditingController();
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  int _currentIndex = 0;
  final _formkey = GlobalKey<FormState>();
  final _formkey2 = GlobalKey<FormState>();

  void onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _screenOne(BuildContext context) {
    if (storageUploadTask != null) {
      return StreamBuilder(
          stream: storageUploadTask.events,
          builder: (context, snapshot) {
            if (storageUploadTask.isInProgress) {
              return Scaffold(
                backgroundColor: Colors.transparent,
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 5,
                      ),
                      whiteText('Uploading')
                    ],
                  ),
                ),
              );
            } else if (storageUploadTask.isSuccessful) {
              Future.delayed(Duration(milliseconds: 100), () {
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text("Data Added")));
                storageUploadTask = null;
              });
              return _screenOneContainer(context);
            }

            return Container();
          });
    } else {
      return _screenOneContainer(context);
    }
  }

  Widget _screenOneContainer(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formkey2,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Column(
                children: [
                  whiteTransparentField(Icons.house_sharp, "Address", addressCTL,
                      validator: basicValidator),
                  SizedBox(
                    height: 10,
                  ),
                  whiteTransparentField(Icons.account_circle, "Name", nameCTL,
                      validator: basicValidator),
                  SizedBox(
                    height: 10,
                  ),
                  whiteTransparentField(Icons.phone, "Mobile Number", numberCTL,
                      validator: _seatValidator),
                  SizedBox(
                    height: 10,
                  ),
                  whiteTransparentField(Icons.location_city, "City", cityCTL,
                      validator: basicValidator),
                  SizedBox(
                    height: 10,
                  ),
                  whiteTransparentField(
                      Icons.subject, "Computer Eng Cutoff", cecutoffCTL,
                      validator: _seatValidator),
                  SizedBox(
                    height: 10,
                  ),
                  whiteTransparentField(
                      Icons.subject, "Mech Eng Cutoff", mecutoffCTL,
                      validator: _seatValidator),
                  SizedBox(
                    height: 10,
                  ),
                  whiteTransparentField(
                      Icons.subject, "Elec Eng Cutoff", elcutoffCTL,
                      validator: _seatValidator),
                  SizedBox(
                    height: 10,
                  ),
                  whiteTransparentField(
                      Icons.subject, "Civil Eng Cutoff", cicutoffCTL,
                      validator: _seatValidator),
                  SizedBox(
                    height: 10,
                  ),
                  whiteTransparentField(Icons.money, "Fees", feesCTL,
                      validator: _seatValidator),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: 150,
                      height: 150,
                      child: image == null
                          ? Container(
                              child:
                                  whiteButton('Pick Image', 10, 10, 10, 10, () {
                                proccessImage();
                              }),
                            )
                          : Image.file(image)),
                  SizedBox(
                    height: 10,
                  ),
                  whiteButton('Save', 10, 10, 10, 10, () {
                    if (_formkey2.currentState.validate()) {
                      uploadPicture(context);
                    }
                  }),
                  SizedBox(
                    height: 10,
                  ),
                  TextButton(
                      onPressed: () {
                        clearScreenOneFields();
                      },
                      child: whiteText('Clear All'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _screenTwo(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formkey,
            child: Column(
              children: [
                whiteTransparentField(
                    Icons.school, "College Name", collegeNameCTl,
                    validator: basicValidator),
                SizedBox(
                  height: 10,
                ),
                whiteTransparentField(Icons.location_city, "City", cityNameCTL,
                    validator: basicValidator),
                SizedBox(
                  height: 10,
                ),
                whiteTransparentField(Icons.book, "General", generalCTL,
                    validator: _seatValidator),
                SizedBox(
                  height: 10,
                ),
                whiteTransparentField(Icons.book, "OBC", obcCTL,
                    validator: _seatValidator),
                SizedBox(
                  height: 10,
                ),
                whiteTransparentField(Icons.book, "SC/ST", scstCTL,
                    validator: _seatValidator),
                SizedBox(
                  height: 10,
                ),
                whiteTransparentField(Icons.book, "TFWS", tfwsCTL,
                    validator: _seatValidator),
                SizedBox(
                  height: 10,
                ),
                whiteButton('Save', 10, 10, 10, 10, () {
                  if (_formkey.currentState.validate()) {
                    firestoreInstance.collection('seats').add({
                      'city': cityNameCTL.text,
                      'general': int.parse(generalCTL.text),
                      'name': collegeNameCTl.text,
                      'obc': int.parse(obcCTL.text),
                      'scst': int.parse(scstCTL.text),
                      'tfws': int.parse(scstCTL.text),
                    }).then((value) {
                      clearFields();
                      return showDialog<void>(
                          context: context,
                          builder: (BuildContext _context) {
                            return AlertDialog(
                              title: Text('Added data'),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'))
                              ],
                            );
                          });
                    });
                    Focus.of(context).unfocus();
                  }
                }),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _screenThree(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              child: Icon(
                Icons.account_circle,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: 10,
            ),
            whiteText(_username, size: 22),
          ],
        ),
        Center(
          child: TextButton(
              onPressed: () {
                setState(() {
                  prefs.remove('user');
                  prefs.remove('admin');
                  print(prefs.containsKey('admin'));
                });
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Text(
                'Log out',
                style: TextStyle(fontSize: 18),
              )),
        )
      ],
    );
  }

  // Widget _screenFour(BuildContext context) {
  //   return Container(
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       child: FutureBuilder(
  //         future: getData(),
  //         builder: (
  //           _,
  //           snapshot,
  //         ) {
  //           if (snapshot.connectionState == ConnectionState.waiting) {
  //             return whiteText('loading..', size: 20);
  //           }
  //           List<DocumentSnapshot> data = snapshot.data.documents;
  //           return DataTable(
  //               showCheckboxColumn: false,
  //               showBottomBorder: true,
  //               sortAscending: true,
  //               sortColumnIndex: 0,
  //               columns: [
  //                 DataColumn(
  //                   label: whiteText('Name'),
  //                 ),
  //                 DataColumn(numeric: true, label: whiteText('General')),
  //                 DataColumn(numeric: true, label: whiteText('Obc')),
  //                 DataColumn(numeric: true, label: whiteText('Sc/St')),
  //               ],
  //               rows: data.map((value) {
  //                 print(value.data['name']);
  //                 // int _selected = -1;
  //                 return DataRow(cells: [
  //                   DataCell(
  //                     whiteText(
  //                       value.data['name'],
  //                     ),
  //                   ),
  //                   DataCell(whiteText(
  //                     value.data['general'].toString(),
  //                   )),
  //                   DataCell(whiteText(
  //                     value.data['obc'].toString(),
  //                   )),
  //                   DataCell(whiteText(
  //                     value.data['scst'].toString(),
  //                   ))
  //                 ]);
  //               }).toList());
  //         },
  //       ),
  //     ),
  //   );
  // }

//   }
//   List<DataRow> _createRows(QuerySnapshot snapshot){
//     List<DataRow> newList = snapshot.documents.map((snap) {
// return DataRow(cells: [cre
// ]);
//     }).toList();
//     return newList;
//   }
  Future getData() async {
    QuerySnapshot querySnapshot =
        await firestoreInstance.collection('seats').getDocuments();
    return querySnapshot;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screenInfo = [
      _screenOne(context),
      _screenTwo(context),
      _screenThree(context),
    ];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: onTap,
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(
                icon: Icon(Icons.computer), label: 'Add College Info'),
            BottomNavigationBarItem(
                icon: Icon(Icons.book), label: 'Add Empty Seat'),
            // BottomNavigationBarItem(
            //     icon: Icon(Icons.account_circle), label: 'View Empty Seat'), for the future
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'Log Out'),
          ]),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Admin Panel',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _screenInfo[_currentIndex],
    );
  }

  String _username;

  _read() async {
    setState(() {
      _username = prefs.getString('user');
    });
  }

  @override
  void initState() {
    super.initState();
    _read();
  }

  void clearFields() {
    setState(() {
      cityNameCTL.text = "";
      generalCTL.text = "";
      collegeNameCTl.text = "";
      obcCTL.text = "";
      tfwsCTL.text = "";
      scstCTL.text = "";
    });
  }

  void clearScreenOneFields() {
    setState(() {
      image = null;
      nameCTL.text = "";
      addressCTL.text = "";
      cecutoffCTL.text = "";
      mecutoffCTL.text = "";
      cicutoffCTL.text = "";
      feesCTL.text = "";
      elcutoffCTL.text = "";
      cityCTL.text = "";
      numberCTL.text = "";
    });
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();

  const HomePage();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  Function(String) phoneNumberValidator = (string) {
    bool emailValid = RegExp(r"^[0-9]").hasMatch(username.text);
    if (emailValid) {
      return null;
    }
    return 'Please Enter Number Correctly';
  };

  Function(String) emailNameValidator = (String user) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(user);
    if (emailValid) {
      return null;
    }
    if (user.isEmpty) {
      return 'Please Enter Something';
    }
    return 'Please Enter Email Correctly';
  };
  Function(String) passwordValidator = (value) {
    if (value.length < 6) {
      return 'Please Enter Password More Than 6 char';
    }
    if (value.isEmpty) {
      return 'Please Enter Something';
    }
    return null;
  };
  QuerySnapshot _emailSnap;
  Future loginService() async {
    QuerySnapshot _emailSnapLocal = await firestoreInstance
        .collection('Users')
        .where('email', isEqualTo: username.text)
        .where('password', isEqualTo: password.text)
        .getDocuments();
    print(_emailSnapLocal.documents);
    return _emailSnapLocal.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                const Color(0xFF3366FF),
                const Color(0xFF00CCFF),
          ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.0))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      "Where is my college?",
                      style: TextStyle(
                          fontSize: 30, color: Colors.white, letterSpacing: 10),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Container(
                      child: whiteTransparentField(
                          Icons.account_circle, "Email", username,
                          validator: emailNameValidator),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      child: whiteTransparentField(
                          Icons.remove_red_eye, "Password", password,
                          validator: passwordValidator, isPassword: true),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    whiteButton("Login", 10, 10, 10, 10, () async {
                      if (_formKey.currentState.validate()) {
                        // bool hasEmail = true;
                        QuerySnapshot _emailSnap = await firestoreInstance
                            .collection('Users')
                            .where('email', isEqualTo: username.text)
                            .getDocuments();

                        if (_emailSnap.documents.isEmpty) {
                          showMyDialog(context);
                        } else if (_emailSnap.documents.isNotEmpty) {
                          QuerySnapshot _passSnap = await firestoreInstance
                              .collection('Users')
                              .where('password', isEqualTo: password.text)
                              .getDocuments();
                          if (_passSnap.documents.isNotEmpty) {
                            _write(username.text);
                            password.text = '';
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Dashboard()));
                          } else {
                            return showDialog<void>(
                                context: context,
                                builder: (BuildContext _context) {
                                  return AlertDialog(
                                    title: Text('Wrong Password'),
                                    actions: <Widget>[
                                      TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'))
                                    ],
                                  );
                                });
                          }
                        }
                      }
                    }),
                    SizedBox(
                      height: 20,
                    ),
                    whiteButton("Register", 10, 10, 10, 10, () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()));
                    }),
                    SizedBox(
                      height: 20,
                    ),
                    TextButton(
                        child: Text(
                          "Login as Admin",
                          style: TextStyle(fontSize: 15, color: Colors.white),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState.validate()) {
                            QuerySnapshot _snap = await firestoreInstance
                                .collection('Admins')
                                .where('name', isEqualTo: username.text)
                                .where('password', isEqualTo: password.text)
                                .getDocuments();
                            if (_snap.documents.isEmpty) {
                              return showDialog(
                                  context: context,
                                  builder: (BuildContext _context) {
                                    return AlertDialog(
                                      title: Text('Wrong Username or Password'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('OK'))
                                      ],
                                    );
                                  });
                            } else {
                              _writeAdmin(username.text);
                              setState(() {
                                password.text = '';
                              });
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddInfo()));
                            }
                          }
                        }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _write(String username) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('user', username);
  }

  void _writeAdmin(String username) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('user', username);
    pref.setBool('admin', true);
  }
}

Future showMyDialog(BuildContext context) async {
  return showDialog<void>(
      context: context,
      builder: (BuildContext _context) {
        return AlertDialog(
          title: Text('Please Register'),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'))
          ],
        );
      });
}

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  Function(String) phoneNumberValidator = (value) {
    bool phoneValid = RegExp(r"^[0-9]").hasMatch(value);
    if (!phoneValid) {
      return 'Please Enter Number Correctly';
    }
    if (value.isEmpty) {
      return 'Please Enter Something';
    }
    if (value.length < 10 || value.length > 10) {
      return 'Please Enter Mobile Number in 10 Digits';
    }
    return null;
  };

  Function(String) emailNameValidator = (value) {
    bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
    if (emailValid) {
      return null;
    }
    if (value.isEmpty) {
      return 'Please Enter Something';
    }
    return 'Please Enter Email Correctly';
  };

  Function(String) passwordValidator = (value) {
    if (value.length < 6) {
      return 'Please Enter Password More Than 6 char';
    }
    if (value.isEmpty) {
      return 'Please Enter Something';
    }
    return null;
  };

  final TextEditingController _email = TextEditingController();
  final TextEditingController _number = TextEditingController();
  final TextEditingController _password = TextEditingController();

  void _write(String username) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('user', _email.text);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
            const Color(0xFF3366FF),
            const Color(0xFF00CCFF),
          ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 1.0))),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 50),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Register",
                  style: TextStyle(
                      fontSize: 30, color: Colors.white, letterSpacing: 10),
                ),
                SizedBox(
                  height: 40,
                ),
                Container(
                  child: whiteTransparentField(
                      Icons.account_circle, "Email", _email,
                      validator: emailNameValidator),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: whiteTransparentField(
                    Icons.quick_contacts_dialer,
                    "Number",
                    _number,
                    validator: phoneNumberValidator,
                  ),
                ),
                SizedBox(
                  height: 30,
                ),
                Container(
                  child: whiteTransparentField(
                      Icons.remove_red_eye, "Password", _password,
                      validator: passwordValidator, isPassword: true),
                ),
                SizedBox(
                  height: 30,
                ),
                SizedBox(
                  height: 20,
                ),
                whiteButton("Save & Login", 10, 10, 10, 10, () async {
                  if (_formKey.currentState.validate()) {
                    QuerySnapshot snaplocal = await firestoreInstance
                        .collection("Users")
                        .where('email', isEqualTo: _email.text)
                        .getDocuments();
                    if (snaplocal.documents.isEmpty) {
                      firestoreInstance.collection("Users").add({
                        "email": _email.text,
                        "number": _number.text,
                        "password": _password.text,
                        'cutoff': ""
                      }).then((value) {
                        _write(username.text);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Dashboard()),
                        );
                      });
                    } else {
                      return showDialog(
                          context: context,
                          builder: (BuildContext _context) {
                            return AlertDialog(
                              title: Text('Email Already Exists'),
                              actions: <Widget>[
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'))
                              ],
                            );
                          });
                    }
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String username, tempCutOff;

  _read() async {
    setState(() {
      username = prefs.getString('user');
    });
  }

  @override
  void initState() {
    super.initState();
    _read();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: Container(
            color: Colors.grey.shade800,
            child: ListView(
              children: [
                DrawerHeader(
                  child: Center(
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        child: Icon(Icons.account_circle),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Text(
                          username,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
                    ],
                  )),
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                        const Color(0xFF00CCFF),
                        const Color(0xFF3366FF),
                      ])),
                ),
                ListTile(
                  leading: Icon(
                    Icons.exit_to_app_rounded,
                    color: Colors.white,
                  ),
                  title: whiteText('Logout'),
                  onTap: () {
                    _remove();
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (context) => HomePage()));
                  },
                ),
                // ListTile(
                //   title: whiteText('Your Cutoff'),
                //   subtitle: tempCutOff == null ? Container() : Text(tempCutOff),
                // )
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: Text("College Finder"),
        ),
        body: Container(
          // decoration: BoxDecoration(boxShadow: [
          //   BoxShadow(
          //       color: Colors.white,
          //       blurRadius: 35,
          //       offset: Offset(0.0, 0.0),
          //       spreadRadius: 50),
          // ]),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(boxShadow: [
                        BoxShadow(
                            color: Colors.cyan.shade400,
                            blurRadius: 35,
                            offset: Offset(0.0, 0.0),
                            spreadRadius: 5),
                        BoxShadow(
                            color: Colors.black,
                            blurRadius: 35,
                            offset: Offset(1.0, 1.0),
                            spreadRadius: 50)
                      ]),
                      // decoration: BoxDecoration(
                      //     gradient: LinearGradient(colors: [
                      //   const Color(0xFFF65130),
                      //   const Color(0xFFE9941A),
                      // ])),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Find College',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Find college on based on your cutoff marks',
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Hero(
                            tag: 'btn',
                            child: gradientButton("Search", 10, 10, 10, 10, () {
                              //    _save(widget.user);
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DataView()));
                            }),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // RaisedButton(onPressed: (){
              //   prefs.setString('user',null);
              // }),
              SizedBox(
                height: 2,
                child: Container(
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      //decoration: BoxDecoration(border: Border.all(color: Colors.white,width: 2,style: BorderStyle.solid), borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Text(
                            'Check Seats',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          whiteText('Check empty seats on colleges'),
                          SizedBox(
                            height: 10,
                          ),
                          gradientButton("Check", 10, 10, 10, 10, () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ViewEmptySeats()));
                          })
                        ],
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _remove() async {
    // final pref = await SharedPreferences.getInstance();
    setState(() {
      prefs.remove('user');
      // prefs.remove('admin');
    });
  }
}

class DataView extends StatefulWidget {
  @override
  _DataViewState createState() => _DataViewState();
}

class _DataViewState extends State<DataView> {
  Function(String) basicValidator = (value) {
    if (value.isEmpty) {
      return 'Please Enter Something';
    }
  };
  final _formKey = GlobalKey<FormState>();
  Function(String) cutoffValidator = (value) {
    bool emailValid = RegExp(r"[0-9]+$").hasMatch(value);
    if (!emailValid) {
      return 'Please Enter Cutoff Correctly';
    }
    if (value.isEmpty) {
      return 'Please Enter Something';
    }
    return null;
  };

  double filterOpacity = 0.0;

  Future getPosts(String column, {String city}) async {
    QuerySnapshot querySnapshot = await firestoreInstance
        .collection('Colleges')
        .where(column, isLessThanOrEqualTo: int.parse(_cutoffContoller.text))
        .getDocuments();

    // querySnapshot = await Firestore.instance
    //     .collection('Colleges')
    //     .where('city', isEqualTo: _cityFilter.text.toLowerCase())
    //     .where('cutoff',
    //         isLessThanOrEqualTo: int.parse(_cutoffContoller.text))
    //     .getDocuments();

    return querySnapshot.documents;
  }

  // final TextStyle _dropdownTextStyle = TextStyle(color: );
  TextEditingController _cutoffContoller = TextEditingController();
  TextEditingController _cityContoller = TextEditingController();

  final _cityFilter = TextEditingController();
  final formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    int _currentValueSelected = 0;
    String departmentSel = "cecutoff";
    return Scaffold(
        appBar: AppBar(
          title: Text("College Finder"),
          backgroundColor: Colors.black,
          shadowColor: Colors.grey,
        ),
        body: Container(
          margin: EdgeInsets.only(top: 10),
          padding: const EdgeInsets.all(1.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Center(
                  child: Container(
                    width: 300,
                    child: whiteTransparentField(
                        Icons.school, "Enter Cutoff", _cutoffContoller,
                        validator: cutoffValidator),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width: 250,
                child: Theme(
                  data: Theme.of(context).copyWith(canvasColor: Colors.black87),
                  child: DropdownButtonFormField(
                      value: _currentValueSelected,
                      style: TextStyle(color: Colors.white),
                      items: [
                        DropdownMenuItem(
                          child: Text('Computer'),
                          value: 0,
                        ),
                        DropdownMenuItem(child: Text('Electrical'), value: 1),
                        DropdownMenuItem(child: Text('Civil'), value: 2),
                        DropdownMenuItem(child: Text('Mechanical'), value: 3),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _currentValueSelected = value;
                        });
                        switch (value) {
                          case 0:
                            departmentSel = "cecutoff";
                            break;
                          case 1:
                            departmentSel = "elcutoff";
                            break;
                          case 2:
                            departmentSel = "cicutoff";
                            break;
                          case 3:
                            departmentSel = "mecutoff";
                            break;
                        }
                      }),
                ),
              ),
              Center(
                child: Container(
                  width: 200,
                  child: Hero(
                    tag: 'btn',
                    child: gradientButton("Search", 10, 10, 10, 10, () {
                      if (_formKey.currentState.validate()) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          getPosts(departmentSel);
                        });
                      }
                    }),
                  ),
                  padding: EdgeInsets.all(20),
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                      child: FutureBuilder(
                          future: getPosts(departmentSel),
                          builder: (_, snapshot) {

                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              if (snapshot.hasData && snapshot.data.isEmpty) {
                                return Center(
                                  child: whiteText(
                                    'No Data',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20),
                                  ),
                                );
                              }
                              if (snapshot.hasData) {

                                return ListView.builder(
                                  itemCount: snapshot?.data?.length ?? 0,
                                    itemBuilder: (
                                      _,
                                      index,
                                    ) {
                                      return ListTile(
                                        leading: Container(
                                          width: 100,
                                          height: 100,
                                          child: Image.network(
                                            snapshot.data[index].data['img'],
                                            loadingBuilder:
                                                (con, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes
                                                      : null,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        title: whiteText(
                                            snapshot.data[index].data['Name']),
                                        subtitle: whiteText(
                                          "Cutoff: " +
                                              snapshot.data[index]
                                                  .data[departmentSel]
                                                  .toString(),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      CollegeInfo(
                                                          snapshot.data[index]
                                                              .data['Name'],
                                                          snapshot.data[index]
                                                              .data['Address'],
                                                          snapshot.data[index]
                                                              .data['fees'],
                                                          snapshot.data[index]
                                                              .data['city'],
                                                          snapshot.data[index]
                                                              .data['Number'],
                                                          snapshot.data[index]
                                                              .data['img'],
                                                          snapshot.data[index]
                                                                  .data[
                                                              'collegeID'])));
                                        },
                                      );
                                    });
                              }
                              return Container();
                            }
                          })
                      // FutureBuilder(
                      //   future: getPosts(),
                      //   builder: (BuildContext context,
                      //       snapshot) {
                      //     if (snapshot.hasError)
                      //       return Text('Error: ${snapshot.error}');
                      //     switch (snapshot.connectionState) {
                      //       case ConnectionState.waiting:
                      //         return  Text('Loading...');
                      //       default:
                      //         return ListView(
                      //             children: snapshot.data.documents
                      //                 .map((DocumentSnapshot document) {
                      //               return new CustomCard(
                      //                 college: document['Name'],
                      //                 cutoff:  document['cutoff'].toString(),
                      //               );
                      //             }).toList());
                      //     }
                      //   },
                      // ),
                      ),
                ),
              )
            ],
          ),
        ));
  }
}

class ImgView extends StatefulWidget {
  final String url;
  ImgView(this.url);

  @override
  _ImgViewState createState() => _ImgViewState();
}

class _ImgViewState extends State<ImgView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Scaffold(
          body: Hero(
              tag: 'img',
              child: Center(
                child: Image.network(widget.url),
              ))),
    );
  }
}

class CollegeInfo extends StatefulWidget {
  final String name, address, fees, city, number, img, collegeID;

  CollegeInfo(this.name, this.address, this.fees, this.city, this.number,
      this.img, this.collegeID);

  @override
  _CollegeInfoState createState() => _CollegeInfoState();
}

class _CollegeInfoState extends State<CollegeInfo> {
  final double title = 20, subtitle = 16;

  var _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // print(address + city + number + img);

    return Scaffold(
        floatingActionButton: StatefulBuilder(
          builder:
              (BuildContext context, void Function(void Function()) setState) =>
                  FloatingActionButton(
            child: Icon(Icons.rate_review_rounded),
            onPressed: () {
              showReviewDialog(context);
            },
          ),
        ),
        appBar: AppBar(title: Text("Info")),
        body: Column(
          children: [
            Container(
                width: 250,
                height: 250,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (a) => ImgView(widget.img)));
                  },
                  child: Hero(
                    tag: 'img',
                    child: Image.network(
                      widget.img,
                    ),
                  ),
                )),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(1),
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: [
                  ListTile(

                    leading: Icon(Icons.school, color: Colors.white),
                    title: whiteText('College Name',
                        // style: TextStyle(fontSize: title),
                        size: title),
                    subtitle: whiteText(widget.name, size: subtitle),
                  ),
                  ListTile(
                    leading: Icon(Icons.house, color: Colors.white),
                    title: whiteText('Address', size: title),
                    subtitle: whiteText(widget.address, size: subtitle),
                  ),
                  ListTile(
                    leading: Icon(Icons.money, color: Colors.white),
                    title: whiteText('Fees', size: title),
                    subtitle:
                        whiteText(widget.fees + " per year", size: subtitle),
                  ),
                  ListTile(
                    leading: Icon(Icons.location_city, color: Colors.white),
                    title: whiteText('City', size: title),
                    subtitle: whiteText(widget.city, size: subtitle),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.white),
                    title: whiteText('Number', size: title),
                    subtitle: whiteText(widget.number, size: title),
                    onTap: () {
                      _dialNumber(widget.number);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.star, color: Colors.white),
                    title: whiteText('Check Reviews', size: title),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (con) => ReviewView(widget.collegeID)));
                    },
                  ),
                ],
              ),
            )
          ],
        ));
  }

  void _dialNumber(String number) async {
    String url = "tel:$number";
    if (await canLaunch(url)) {
      launch(url);
    } else {
      throw 'cud not launch $url';
    }
  }

  Future showReviewDialog(BuildContext context) {
    double _laboratory = 5.0;
    double _education = 5.0;
    double _infrastructure = 5.0;
    return showDialog(
        context: context,
        builder: (BuildContext _context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text('Your Review'),
              content: SingleChildScrollView(
                child: Container(
                  height: MediaQuery.of(context).size.height / 1.8,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          hintText: 'Your Thoughts',
                        ),
                        maxLines: 3,
                        controller: _reviewController,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text('Give Rating out of 10'),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Laboratory'),
                      Slider(
                        divisions: 10,
                        value: _laboratory,
                        max: 10,
                        min: 0,
                        label: _laboratory.round().toString(),
                        onChanged: (val) {
                          setState(() {
                            _laboratory = val;
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Education'),
                      Slider(
                        divisions: 10,
                        value: _education,
                        max: 10,
                        min: 0,
                        label: _education.round().toString(),
                        onChanged: (val) {
                          setState(() {
                            _education = val;
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Infrastructure'),
                      Slider(
                        divisions: 10,
                        value: _infrastructure,
                        max: 10,
                        min: 0,
                        label: _infrastructure.round().toString(),
                        onChanged: (val) {
                          setState(() {
                            _infrastructure = val;
                          });
                        },
                      ),
                      Container(
                        child: TextButton(
                            onPressed: () async {
                              firestoreInstance.collection('reviews').add({
                                'user': await readUser(),
                                'review': _reviewController.text,
                                'rating': _laboratory.round() +
                                    _infrastructure.round() +
                                    _education.round(),
                                'infrapts': _infrastructure.round(),
                                'labpts': _laboratory.round(),
                                'edu': _education.round(),
                                'collegeID': widget.collegeID
                              });
                              Navigator.pop(context);
                            },
                            child: Text('Submit')),
                      )
                    ],
                  ),
                ),
              ),
              
            );
          });
        });
  }
}

Future<String> readUser() async {
  SharedPreferences abc = await SharedPreferences.getInstance();
  return abc.getString('user');
}

class ReviewView extends StatelessWidget {
  final String collegeID;

  ReviewView(this.collegeID);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
      ),
      body: Container(
        child: FutureBuilder(
          future: firestoreInstance
              .collection('reviews')
              .where('collegeID', isEqualTo: collegeID)
              .getDocuments(),
          builder: (con, snap) {
            double score = 0.0,
                infraPoints = 0.0,
                labPoints = 0.0,
                education = 0.0;
            if (snap.connectionState == ConnectionState.done) {
              if (snap.data.documents.length != 0) {
                List<DocumentSnapshot> snapshot = snap.data.documents;
                for (DocumentSnapshot snap0 in snapshot) {
                  score = score + snap0.data['rating'];
                  infraPoints = infraPoints + snap0.data['infrapts'];
                  labPoints = labPoints + snap0.data['labpts'];
                  education = education + snap0.data['edu'];
                  print(education.toStringAsPrecision(3));
                }
                score = score / snapshot.length;
                infraPoints = infraPoints / snapshot.length;
                labPoints = labPoints / snapshot.length;
                education = education / snapshot.length;

                return Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircularPercentIndicator(
                            center: whiteText(infraPoints.toStringAsFixed(2)),
                            linearGradient: blueGradient(),
                            animation: true,
                            animationDuration: 1100,
                            radius: 65,
                            percent: infraPoints * 0.10,
                          ),
                          CircularPercentIndicator(
                            linearGradient: blueGradient(),
                            center: whiteText(labPoints.toStringAsFixed(2)),
                            animation: true,
                            animationDuration: 1100,
                            radius: 65,
                            percent: labPoints * 0.10,
                          ),
                          CircularPercentIndicator(
                            linearGradient: blueGradient(),
                            center: whiteText(education.toStringAsFixed(2)),
                            animation: true,
                            animationDuration: 1100,
                            radius: 65,
                            percent: education * 0.10,
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          whiteText('Infrastrcture'),
                          whiteText('Laboratory'),
                          whiteText('Education'),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 8,
                      child: ListView.builder(
                        itemCount: snapshot.length,
                        itemBuilder: (cont, index) {
                          double averagePoints = (snapshot[index].data['edu'] +
                                  snapshot[index].data['infrapts'] +
                                  snapshot[index].data['labpts']) /
                              3;
                          return Container(
                            child: ListTile(
                              title: whiteText(
                                snapshot[index].data['user'],
                              ),
                              leading: Icon(
                                Icons.account_circle,
                                color: Colors.blueAccent,
                              ),
                              subtitle: Container(
                                child: whiteText(snapshot[index].data['review'],
                                    size: 18),
                              ),
                              trailing: whiteText(
                                  "Avg Rating ${averagePoints.toStringAsFixed(2)}"),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              }
              else{
                return Center(child: whiteText('No Reviews Yet',size: 20),);
              }
            } else {
              Center(
                child: CircularProgressIndicator(),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}

class ViewEmptySeats extends StatefulWidget {
  @override
  _ViewEmptySeatsState createState() => _ViewEmptySeatsState();
}

class _ViewEmptySeatsState extends State<ViewEmptySeats> {
  // TextStyle _listdata = TextStyle(fontSize: 15);
  bool isFilter = false;
  final TextEditingController _cityFilter = TextEditingController();
  double filterOpacity = 0.0;
  Future getPosts() async {
    QuerySnapshot querySnapshot;
    if (!isFilter) {
      querySnapshot =
          await Firestore.instance.collection('seats').getDocuments();
    } else {
      querySnapshot = await Firestore.instance
          .collection('seats')
          .where('city', isEqualTo: _cityFilter.text.toLowerCase())
          .getDocuments();
    }
    return querySnapshot.documents;
  }

  final formkey = GlobalKey<FormState>();
  Function(String) basicValidator = (value) {
    if (value.isEmpty) {
      return 'Please Enter Something';
    }
  };
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.filter_alt),
          tooltip: "Filter City",
          onPressed: () {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: Form(
                      key: formkey,
                      child: TextFormField(
                        validator: basicValidator,
                        controller: _cityFilter,
                        decoration: InputDecoration(hintText: 'Filter City'),
                      ),
                    ),
                    actions: [
                      Opacity(
                        opacity: filterOpacity,
                        child: TextButton(
                            onPressed: () {
                              setState(() {
                                if (isFilter) {
                                  isFilter = false;
                                  _cityFilter.text = '';
                                  filterOpacity = 0.0;
                                  getPosts();
                                }
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text('Remove Filter')),
                      ),
                      TextButton(
                          onPressed: () {
                            if (formkey.currentState.validate()) {
                              setState(() {
                                isFilter = true;
                                getPosts();
                                filterOpacity = 1.0;
                                Navigator.of(context).pop();
                              });
                            }
                          },
                          child: Text('Filter'))
                    ],
                  );
                });
          }),
      appBar: AppBar(
        title: Text('Check Seats'),
      ),
      body: SafeArea(
          child: FutureBuilder(
              future: getPosts(),
              builder: (_, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  if (snapshot.hasData && snapshot.data.isEmpty) {
                    return Center(
                      child: whiteText('No Data', size: 30),
                    );
                  }
                  return ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                            color: Colors.grey.shade400,
                          ),
                      itemCount: snapshot?.data?.length ?? 0,
                      itemBuilder: (
                        _,
                        index,
                      ) {
                        return ListTile(
                          contentPadding: EdgeInsets.all(10),
                          isThreeLine: true,
                          title: whiteText(
                              "College Name: " +
                                  snapshot.data[index].data['name'],
                              size: 18),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              whiteText(
                                  "General " +
                                      snapshot.data[index].data['general']
                                          .toString(),
                                  size: 15),
                              whiteText(
                                  "OBC " +
                                      snapshot.data[index].data['obc']
                                          .toString(),
                                  size: 15),
                              whiteText(
                                  "SC/ST " +
                                      snapshot.data[index].data['scst']
                                          .toString(),
                                  size: 15),
                              whiteText(
                                  "TFWS " +
                                      snapshot.data[index].data['tfws']
                                          .toString(),
                                  size: 15),
                            ],
                          ),
                        );
                      });
                }
              })),
    );
  }
}
