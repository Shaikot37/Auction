import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'HomePage.dart';
import 'Posts.dart';
import 'UsersItem.dart';

class ItemDetails extends StatefulWidget {
  @override
  _ItemDetailsState createState() => _ItemDetailsState();
}


class _ItemDetailsState extends State<ItemDetails> {

  List<Posts> postsList = [];
  final bid = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final databaseRef = FirebaseDatabase.instance.reference().child("User");
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

  @override
  void initState() {
    super.initState();
    this.checkAuthentification();
    this.getUser();
    DatabaseReference postsRef = FirebaseDatabase.instance.reference().child("User");

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
        userItems();
      }else if(itemSelected == "2"){
        //code here
      }else{
        //code here
        signOut();
      }

    });
  }

  void userItems(){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return new UsersItem();
    }));
  }



  void addBid(String bid) {
    databaseRef.push().set({'Bid': bid });
    gotoHomePage();

  }
  void gotoHomePage(){
    Navigator.push(context, MaterialPageRoute(builder: (context){
      return new HomePage();
    }));
  }



  @override
  Widget build(BuildContext context) {
    final Posts todo = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        resizeToAvoidBottomInset: false,
      appBar: AppBar(centerTitle: true,
        title: Text('Auction App'),
        leading: IconButton(
          onPressed: (){
            debugPrint("Form button clicked");
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
      body: new Container(
        child:!isloggedin
    ?     CircularProgressIndicator()
        : Column(
          children: <Widget>[
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(todo.Name),
          ),
          SizedBox(height: 10.0),
          Padding(
            padding: EdgeInsets.all(10.0),
            child: Text(todo.Description),
        ),
            SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(todo.Minimum_Bid_Price),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(todo.End_Date),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Image.network(todo.ImageURL,height: 200.0,),
            ),
            SizedBox(height: 10.0),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(controller: bid,
                  decoration: InputDecoration(
                    hintText: 'Bid Ammount',)),
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
                      addBid(bid.text);
                      //CircularProgressIndicator();//call method flutter upload
                    }
                )
            ),
          ]
      )




    ));
  }



}

