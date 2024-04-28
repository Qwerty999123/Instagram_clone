import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_app/providers/user_provider.dart';
import 'package:instagram_app/resources/auth_methods.dart';
import 'package:instagram_app/utils/colors.dart';
import 'package:instagram_app/widgets/comment_card.dart';
import 'package:instagram_app/models/user.dart' as models;
import 'package:provider/provider.dart';

class CommentsPage extends StatefulWidget {
  final snap;
  const CommentsPage({
    super.key,
    required this.snap,
  });

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  final TextEditingController _controller = TextEditingController();
  final AuthMethods _auth = AuthMethods();

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    models.User _user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Comments'),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: kToolbarHeight,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.only(left: 16, right: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(
                  _user.imageUrl!
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Comment as ${widget.snap['username']}',
                      border:InputBorder.none
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _auth.uploadComment(
                    comment: _controller.text, 
                    postId: widget.snap['postId'], 
                    uid: _user.uid, 
                    username: _user.username, 
                    profImage: _user.imageUrl!,
                    likes: []
                  );
                  _controller.text = '';
                }, 
                child: const Text(
                  'Post', style: TextStyle(
                    color: Colors.blue
                  ),
                )
              )
            ],
          )
        )
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
        .collection('posts').doc(widget.snap['postId'])
        .collection('comments').orderBy('date', descending: true).snapshots(),
        // orderby ensures comments are not in random order and are in descending order
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return const Center(
              child: CircularProgressIndicator(),
            );
            
          }else{
            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                return CommentCard(
                  snap: snapshot.data!.docs[index].data()
                );
              },
            );
          }
        },
      ),

    );
  }
}