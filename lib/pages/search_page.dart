import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:instagram_app/pages/profile_page.dart';
import 'package:instagram_app/utils/colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  
  final _border = OutlineInputBorder(
    borderSide: const BorderSide(
      color: Color.fromRGBO(38, 38, 38, 1),
      width: 0.0
    ),
    borderRadius: BorderRadius.circular(15)
  );

  final TextEditingController _searchController = TextEditingController();
  bool isShowUsers = false;

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String _currentUser = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        actions: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onSubmitted: (value){
                  setState(() {
                    if(value == ''){
                      isShowUsers = false;
                    }else{
                      isShowUsers = true;
                    }
                  });
                },
                controller: _searchController,
                style: const TextStyle(
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(top: 7.0),
                  filled: true,
                  fillColor: const Color.fromRGBO(38, 38, 38, 1),
                  prefixIcon: const Icon(
                    Icons.search_rounded, 
                    color: primaryColor,
                  ),
                  hintText: 'Search',
                  focusedBorder: _border,
                  enabledBorder: _border
                ),
              ),
            ),
          )
        ],
      ),
      body: isShowUsers 
      ? FutureBuilder(
        future: FirebaseFirestore.instance.collection('users')
        .where(
          'username',
          isGreaterThanOrEqualTo: _searchController.text,
        )
        .get(), 
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshots){
          if(snapshots.hasData){
            if(snapshots.connectionState == ConnectionState.waiting){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }else{
              return ListView.builder(
                itemCount: (snapshots.data! as dynamic).docs.length,
                itemBuilder: (context, index){
                  return GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context){
                          return _currentUser == snapshots.data!.docs[index]['uid']
                          ? ProfilePage(
                            isCurrentUserProfile: true,
                            uid: snapshots.data!.docs[index]['uid'],
                          )
                          : ProfilePage(
                            isCurrentUserProfile: false,
                            uid: snapshots.data!.docs[index]['uid'],
                          );
                        },
                      )
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: snapshots.data!.docs[index]['imageUrl'] != null 
                        ? NetworkImage(
                          snapshots.data!.docs[index]['imageUrl'],
                        )
                        : const NetworkImage(
                          'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg',
                        ),
                      ),
                      title: Text(snapshots.data!.docs[index]['username']),
                    ),
                  );
                }
              );
            }
          }else{
            return const Center(
              child: Text(
                'No users found',
                style: TextStyle(
                  fontSize: 16
                ),
              )
            );
          }
        }
      )
      : FutureBuilder(
        future: FirebaseFirestore.instance.collection('posts').get(), 
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshots){
          if(snapshots.hasData){
            if(snapshots.connectionState != ConnectionState.waiting){
              return StaggeredGridView.countBuilder(
                crossAxisCount: 3,
                itemCount: snapshots.data!.docs.length, 
                itemBuilder: (context, index){
                  return Image.network(
                    snapshots.data!.docs[index]['postUrl']
                  );
                }, 
                staggeredTileBuilder: (index){
                  return StaggeredTile.count(
                    (index%7 == 0) ? 2 : 1, 
                    (index%7 == 0) ? 2 : 1
                  );
                },
                //mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              );

            }else{
              return const Center(
                child: CircularProgressIndicator()
              );
            }

          }else{
            return const Center(
              child: Text(
                'No posts found',
                style: TextStyle(
                  fontSize: 16
                ),
              )
            );
          }
        }
      )
    );
  }
}