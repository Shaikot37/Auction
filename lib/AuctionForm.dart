import 'package:auctionapp/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AuctionForm extends StatefulWidget {
  @override
  _AuctionFormState createState() => _AuctionFormState();
}


class _AuctionFormState extends State<AuctionForm> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseRef = FirebaseDatabase.instance.reference();
  final Future<FirebaseApp> _future = Firebase.initializeApp();
  User user;
  bool isloggedin = false;
  bool isloading = false;
  final name = TextEditingController();
  final description = TextEditingController();
  final min_bidprice = TextEditingController();
  final _date = TextEditingController();
  DateTime _selectedDate;
  final picker = ImagePicker();
  File sampleImage;


  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      sampleImage = tempImage;
    });
  }


  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      }
    });
  }

  Future<void> addData(File sampleImage, String name, String des, String min_bid, String date) async {
    String fileName = sampleImage.path;
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(sampleImage);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    final String url = (await taskSnapshot.ref.getDownloadURL());
    print('URL Is $url');
    databaseRef.push().set({"UserID":user.uid,'Name': name, 'Description': des, 'Minimum Bid Price':min_bid,
      'ImageURL':url, 'End Date':date});

  }

  getUser() async {
    User firebaseUser = _auth.currentUser;
    await firebaseUser?.reload();
    firebaseUser = _auth.currentUser;

    if (firebaseUser != null) {
      setState(() {
        this.user = firebaseUser;
        this.isloggedin = true;
      });
    }
  }

  signOut() async {
    _auth.signOut();

    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
  }

  void printFirebase(){
    databaseRef.once().then((DataSnapshot snapshot) {
      print('Data : ${snapshot.value}');
    });
  }

  showPopupMenu(){
    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(25.0, 25.0, 0.0, 0.0),      //position where you want to show the menu on screen
      items: [
        PopupMenuItem<String>(
            child: const Text('My posted items'), value: '1'),
        PopupMenuItem<String>(
            child: const Text('Account Settings'), value: '2'),
        PopupMenuItem<String>(
            child: const Text('Logout'), value: '3'),
      ],
      elevation: 8.0,
    )
        .then<void>((String itemSelected) {

      if (itemSelected == null) return;

      if(itemSelected == "1"){
        //code here
      }else if(itemSelected == "2"){
        //code here
      }else{
        //code here
        signOut();
      }

    });
  }


  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage, height: 200.0, width: 300.0),

        ],
      ),
    );
  }


  _selectDate(BuildContext context) async {
    DateTime newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate : DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2040),
        builder: (BuildContext context, Widget child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.deepPurple,
                onPrimary: Colors.white,
                surface: Colors.blueGrey,
                onSurface: Colors.black54,
              ),
              dialogBackgroundColor: Colors.white,
            ),
            child: child,
          );
        });

    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      _date
        ..text = DateFormat.yMMMd().format(_selectedDate)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: _date.text.length,
            affinity: TextAffinity.upstream));
    }
  }



@override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Auction Form"),actions: [
          IconButton(
            onPressed: showPopupMenu,
            icon: Icon(Icons.more_vert),
          ),
        ],),
        body:
        FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return Container(
                  child: !isloggedin
                      ? CircularProgressIndicator()
                      : Column(
                    children: <Widget>[


                      SizedBox(height: 10.0),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:MaterialStateProperty.all(Colors.blueGrey)
                            ),
                            child: sampleImage == null ? Text('Select an image') : enableUpload(),
                            onPressed: getImage,
                        ),

                      ),


                      SizedBox(height: 10.0),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextField(controller: name,
                            decoration: InputDecoration(
                            hintText: 'Name',)),
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextField(controller: description,
                            decoration: InputDecoration(
                              hintText: 'Description',)),
                      ),
                      SizedBox(height: 10.0),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextField(controller: min_bidprice,
                            decoration: InputDecoration(
                              hintText: 'Minimum Bid Price',)),
                      ),

                      SizedBox(height: 10.0),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextField(
                        focusNode: AlwaysDisabledFocusNode(),
                          decoration: InputDecoration(
                            hintText: 'Auction End DateTime'),
                        controller: _date,
                        onTap: () {
                          _selectDate(context);
                        },
                      ),
                      ),

                      SizedBox(height: 20.0),
                      Center(
                          child:
                          ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:MaterialStateProperty.all(Colors.blueGrey)
                              ),
                              child: Text("Save"),
                              onPressed: () {
                                addData(sampleImage, name.text, description.text, min_bidprice.text, _date.text);
                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                  return HomePage();
                                }));
                                //CircularProgressIndicator();//call method flutter upload
                              }
                          )
                      ),

                    ],
                  ),
                );
              }
            }
        )
    );
  }

}

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}
