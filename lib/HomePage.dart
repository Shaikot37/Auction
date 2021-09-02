import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:auctionapp/AuctionForm.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseRef = FirebaseDatabase.instance.reference();
  FirebaseStorage storage = FirebaseStorage.instance;
  User user;
  bool isloggedin = false;
  final Future<FirebaseApp> _future = Firebase.initializeApp();

  checkAuthentification() async {
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        Navigator.of(context).pushReplacementNamed("start");
      }
    });
  }

  void addData(String name, String age) {
    databaseRef.push().set({'name': name, 'age': age });
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true,
          title: Text('Auction App'),
          leading: IconButton(
            onPressed: (){
              debugPrint("Form button clicked");
              //Navigator.of(context).pushReplacementNamed("form");
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return HomePage();
              }));
            },
            icon: Icon(Icons.home),
          ),
          actions: [
            IconButton(
              onPressed: showPopupMenu,
              icon: Icon(Icons.more_vert),
            ),
          ],
        ),
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


              ],
            ),
    );
          }
          }
          ),

        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: Colors.brown,
          onPressed: (){
            debugPrint("Form button clicked");
            //Navigator.of(context).pushReplacementNamed("form");
            Navigator.push(context, MaterialPageRoute(builder: (context){
              return AuctionForm();
            }));
          },
        ),
    );
  }

}

