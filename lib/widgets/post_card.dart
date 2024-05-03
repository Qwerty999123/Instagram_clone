import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_app/models/user.dart';
import 'package:instagram_app/pages/comments_page.dart';
import 'package:instagram_app/providers/user_provider.dart';
import 'package:instagram_app/resources/auth_methods.dart';
import 'package:instagram_app/utils/colors.dart';
import 'package:instagram_app/utils/utils.dart';
import 'package:instagram_app/widgets/like_animation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostCard extends StatefulWidget {
  final snap;
  const PostCard({
    super.key, 
    required this.snap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  Icon saveIcon = const Icon(Icons.bookmark_border);
  int saveFlag = 0;
  int likeFlag = 0;
  bool isLikeAnimating = false;
  int numComments = 0;

  @override
  void initState() {
    super.initState();
    getComments();
  }

  void getComments() async {
    try{
      QuerySnapshot snap = await FirebaseFirestore.instance.collection('posts').doc(widget.snap['postId']).collection('comments').get();
      numComments = snap.docs.length;
    }catch(e){
      showSnackBar(context, e.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final User _user = Provider.of<UserProvider>(context).getUser;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10.0
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ),
            child: Row(
              children: [
                widget.snap['profImage'] != null 
                ? CircleAvatar(
                  backgroundImage: NetworkImage(
                    widget.snap['profImage']
                  ),
                )
                : const CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg',
                
                  ),
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  '${widget.snap['username']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(flex: 1, child: Container()),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context, 
                      builder: (context){
                        return Dialog(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            shrinkWrap: true,
                            children: [
                              'Delete',
                              'Report',
                            ].map((e) => InkWell(
                              onTap: () {
                                if(e=='Delete'){
                                  AuthMethods().deletePost(postId: widget.snap['postId']);
                                  Navigator.of(context).pop();
                                  print('Delete');
                                }else{
                                  Navigator.of(context).pop();
                                  print('Report');
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
                  }, 
                  icon: const Icon(Icons.more_vert)
                )
              ],
            ),
          ),
          GestureDetector(
            onDoubleTap: () async {
              await AuthMethods().likePost(
                postId: widget.snap['postId'],
                uid: _user.uid,
                likes: widget.snap['likes'],
                smallLike: false,
              );
              setState(() { 
                isLikeAnimating = true;
              });
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
            
                Container(
                  width: double.infinity,
                  //height: MediaQuery.of(context).size.height*0.35,
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2.0),
                  child: Image.network(
                    '${widget.snap['postUrl']}',
                    fit: BoxFit.cover
                  ),
                ),
            
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLikeAnimating ? 1 : 0,
                  child: LikeAnimation( 
                    isAnimating: isLikeAnimating,
                    duration: const Duration(milliseconds: 400),
                    onEnd: () {
                      setState(() {
                        isLikeAnimating = false;
                      });
                    },
                    child: const Icon(
                      Icons.favorite, 
                      size: 150,
                      color: primaryColor
                    ),
                  ),
                )
              ]
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                LikeAnimation(
                  isAnimating: widget.snap['likes'].contains(_user.uid),
                  isSmallLike: true,
                  child: IconButton(
                    onPressed: () async {
                      await AuthMethods().likePost(
                        postId: widget.snap['postId'],
                        uid: _user.uid,
                        likes: widget.snap['likes'],
                        smallLike: true,
                      );
                    },
                    icon: widget.snap['likes'].contains(_user.uid) ? const Icon(Icons.favorite, color: Colors.red) : const Icon(Icons.favorite_border) ,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentsPage(
                          snap: widget.snap,
                        )
                      )
                    );
                  }, 
                  icon: const Icon(Icons.comment_outlined)
                ),
                IconButton(
                  onPressed: () {}, 
                  icon: const Icon(Icons.send_rounded)
                ),
                Flexible(flex: 2, child: Container()),
                IconButton(
                  onPressed: () {
                    setState(() {
                      if(saveFlag==0){
                        saveIcon = const Icon(Icons.bookmark, color: primaryColor);
                        saveFlag = 1;
                      }else{
                        saveIcon = const Icon(Icons.bookmark_border);
                        saveFlag = 0;
                      }
                    });
                  }, 
                  icon: saveIcon
                )
              ]
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${widget.snap['likes'].length} likes',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${widget.snap['username']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        )
                      ),
                      TextSpan(
                        text: '  ${widget.snap['caption']}'
                      ),
                    ]
                  )
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CommentsPage(
                          snap: widget.snap,
                        )
                      )
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'View all $numComments comments',
                      style: const TextStyle(
                        color: secondaryColor,
                      )
                    ),
                  ),
                ),
                Text(
                  DateFormat.yMMMd().format(
                    widget.snap['datePublished'].toDate()
                  ),
                  style: const TextStyle(
                    color: secondaryColor,
                  )
                ),
                
                
              ]
            )
          )
        ],
      ),
    );
  }
}