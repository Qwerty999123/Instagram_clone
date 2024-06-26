import 'package:cloud_firestore/cloud_firestore.dart';

class Post{
  final String uid;
  final String caption;
  final String username;
  final String postId;
  final datePublished;
  final String postUrl;
  final String? profImage;
  final likes;

  const Post({
    required this.uid,
    required this.caption,
    required this.username,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImage,
    required this.likes
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'caption': caption,
    'username': username,
    'postId': postId,
    'datePublished': datePublished,
    'postUrl': postUrl,
    'profImage': profImage,
    'likes': likes,
  };

  static Post fromSnap(DocumentSnapshot snapshot){
    var snap = snapshot.data() as Map<String, dynamic>;

    return Post(
      uid: snap['uid'],
      caption: snap['caption'],
      username: snap['username'],
      postId: snap['postId'],
      datePublished: snap['datePublished'],
      postUrl: snap['postUrl'],
      profImage: snap['profImage'],
      likes: snap['likes']
    );
  }

}