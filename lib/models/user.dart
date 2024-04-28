import 'package:cloud_firestore/cloud_firestore.dart';

class User{
  final String uid;
  final String email;
  final String username;
  final String bio;
  final List followers;
  final List following;
  final String? imageUrl;

  const User({
    required this.uid,
    required this.email,
    required this.username,
    required this.bio,
    required this.followers,
    required this.following,
    required this.imageUrl
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'username': username,
    'bio': bio,
    'followers': followers,
    'following': following,
    'imageUrl': imageUrl,
  };

  static User fromSnap(DocumentSnapshot snapshot){
    var snap = snapshot.data() as Map<String, dynamic>;

    return User(
      uid: snap['uid'],
      email: snap['email'],
      username: snap['username'],
      bio: snap['bio'],
      followers: snap['followers'],
      following: snap['following'],
      imageUrl: snap['imageUrl'],
    );
  }

}