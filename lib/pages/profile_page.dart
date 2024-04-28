import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_app/pages/login_page.dart';
import 'package:instagram_app/resources/auth_methods.dart';
import 'package:instagram_app/utils/colors.dart';
import 'package:instagram_app/utils/utils.dart';
import 'package:instagram_app/widgets/profile_cards.dart';

class ProfilePage extends StatefulWidget {
  final bool isCurrentUserProfile;
  final String uid;

  const ProfilePage({
    super.key,
    required this.isCurrentUserProfile,
    required this.uid
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isBack = false;
  bool isFollow = false;
  bool isMessage = false;
  var userData = {};
  var postData = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      if(!widget.isCurrentUserProfile){
        isBack = true;
        isFollow = true;
        isMessage = true;
      }
    });
    getData();
  }

  getData() async {
    try{
      setState(() {
        isLoading = true;
      });

      var userSnap = await FirebaseFirestore.instance.collection('users').doc(widget.uid).get();
      userData = userSnap.data()!;
      var postSnap = await FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: widget.uid).get();
      postData = postSnap.docs;

      setState(() {
        isLoading = false;
      });

    }catch(e){
      showSnackBar(
        context, 
        e.toString()
      );
    }
  }

  Expanded userInfo({
    required int num, 
    required String desc
  }){
    return Expanded(
      child: Column(
        children: [
          Text(
            num.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22
            ),
          ),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 16
            ),
          ),
          
        ]
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isLoading 
    ? const Center(
      child: CircularProgressIndicator(),
    ) 
    : Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: isBack 
        ? IconButton(onPressed: () {
          Navigator.of(context).pop();
        }, icon: const Icon(Icons.arrow_back)) 
        : IconButton(onPressed: () {}, icon: const Icon(Icons.lock)),
        title: Text(
          userData['username'], 
          style: const TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(right: 16.0, left: 8.0, top: 8.0, bottom: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 45,
                      backgroundImage: userData['imageUrl'] == null 
                      ? const NetworkImage(
                        'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg',  
                      )
                      : NetworkImage(
                        userData['imageUrl'],
                      ),
                    ),
                    Text(
                      userData['username'], 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15
                      ),
                    ),
                  ],
                ),
              ),
              userInfo(num: postData.length, desc: 'posts'),
              userInfo(num: userData['followers'].length, desc: 'followers'),
              userInfo(num: userData['following'].length, desc: 'following'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              userData['bio'],
              style: const TextStyle(
                fontSize: 15
              )
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                isFollow 
                ? ProfileCards(desc: 'Follow', isFollow: true, function: (){}, uid: widget.uid) 
                : ProfileCards(desc: 'Edit Profile', isFollow: false, function: (){
                  showDialog(
                      context: context, 
                      builder: (context){
                        return Dialog(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            shrinkWrap: true,
                            children: [
                              'Sign Out'
                            ].map((e) => InkWell(
                              onTap: () {
                                if(e=='Sign Out'){
                                  AuthMethods().signOut();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                      builder: (context){
                                        return const LoginPage();
                                      }
                                    )
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Text(e),
                              ),
                            )).toList()
                          ),
                          
                        );
                      }
                    );
                }, uid: widget.uid),
                const SizedBox(
                  width: 8,
                ),
                isFollow 
                ? ProfileCards(desc: 'Message', isFollow: false, function: (){}, uid: widget.uid) 
                : ProfileCards(desc: 'Share Profile', isFollow: false, function: (){}, uid: widget.uid),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 10.0, top: 5),
            child: Divider(),
          ),
          FutureBuilder(
            future: FirebaseFirestore.instance.collection('posts').where('uid', isEqualTo: widget.uid).get(), 
            builder: (context, snapshot){
              if(snapshot.connectionState == ConnectionState.waiting){
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }else{
                return GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 5,
                    childAspectRatio: 1
                  ), 
                  itemCount: (snapshot.data! as dynamic).docs.length,
                  itemBuilder: (context, index){
                    DocumentSnapshot snap = (snapshot.data! as dynamic).docs[index];

                    return Container(
                      child: Image(
                        image: NetworkImage(
                          snap['postUrl'],
                        ),
                        fit: BoxFit.cover,
                      ),
                      
                    );
                  }
                );
              }
            }
          ),

        ],
      ),
    );
  }
}