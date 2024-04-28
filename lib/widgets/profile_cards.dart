import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_app/resources/auth_methods.dart';
import 'package:instagram_app/utils/colors.dart';

// ignore: must_be_immutable
class ProfileCards extends StatefulWidget {
  String desc;
  bool isFollow;
  final Function()? function;
  final String uid;

  ProfileCards({
    super.key,
    required this.desc,
    required this.isFollow,
    required this.function,
    required this.uid,
  });

  @override
  State<ProfileCards> createState() => _ProfileCardsState();
}

class _ProfileCardsState extends State<ProfileCards> {
  int flag = 0;
  Color bgcolor = const Color.fromARGB(255, 33, 33, 33);
  Color follow = const Color.fromARGB(255, 33, 150, 243);
  final _firestore = FirebaseFirestore.instance.collection('users');
  String _currentUser = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = false;
  
  @override
  void initState() {
    super.initState();
    checkUser();
  }

  checkUser() async {
    DocumentSnapshot snap = await _firestore.doc(_currentUser).get();
    List following = (snap.data()! as dynamic)['following'];

    if(following.contains(widget.uid) && widget.desc != 'Message'){
      setState(() {
        widget.isFollow = false;
        widget.desc = 'Following';
        flag = 1;
        print('ibeue');
      });
    }  
  }

  @override
  Widget build(BuildContext context) {
    _currentUser = FirebaseAuth.instance.currentUser!.uid;

    return Expanded(
      child: ElevatedButton(
        onPressed: (widget.isFollow || flag != 0)
        ? () async {
          setState(() {
            isLoading = true;
          });
          await AuthMethods().followUser(
            currentUid: _currentUser,
            followUid: widget.uid,
          );  
          setState(() {
            isLoading = false;
          });
          if(widget.isFollow){
            setState(() {
              widget.isFollow = false;
              widget.desc = 'Following';
              flag = 1;
            });

          }else{
            setState(() {
              widget.isFollow = true;
              widget.desc = 'Follow';
            });
          } 
        }
        : widget.function,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: widget.isFollow ? follow : bgcolor,
          foregroundColor: primaryColor,
        ),
        child: isLoading 
        ? const Center(
          child: CircularProgressIndicator(),
        ) 
        : Text(
          widget.desc,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16
          )
        ),
      ),
    );
  }
}