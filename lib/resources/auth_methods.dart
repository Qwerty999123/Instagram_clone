import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:instagram_app/models/post.dart';
import 'package:instagram_app/models/user.dart' as models;
// As keyword is used because the user class of models made specially in this project was clashing with
// User class in firebase auth file which is made by flutter team
import 'package:instagram_app/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class AuthMethods{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<models.User> getUserDetails() async{

    DocumentSnapshot snapshot = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();

    return models.User.fromSnap(snapshot);
  }

  // sign up user
  
  Future<String> signUpUser({
    required String username,
    required String email,
    required String bio,
    required String password,
    required Uint8List? file,
  }) async{
    String res = 'Something went wrong';
    String? imageUrl;
    try{
      if(email.isNotEmpty && username.isNotEmpty && bio.isNotEmpty && password.isNotEmpty){
        // register user
        UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
        
        if(file != null){
          imageUrl = await StorageMethods().uploadImage('profilePics', file, false);
        }

        // This syntax is used to avoid clash as mentioned above
        models.User user = models.User(
          uid: cred.user!.uid, 
          email: email, 
          username: username, 
          bio: bio, 
          followers: [], 
          following: [], 
          imageUrl: imageUrl
        );
        
        // add user to database
        await _firestore.collection('users').doc(cred.user!.uid).set(user.toJson());

        res = 'Success';
      }
    }catch(err){
      res = err.toString();
    }
    print(res);
    return res;
  }

  // Login user

  Future<String> loginUser({
    required String email,
    required String password
  }) async{
    String res = 'Something went wrong';
    try{
      if(email.isNotEmpty && password.isNotEmpty){
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = 'Success';
      }else{
        res = 'Please enter all the fields';
      }
    }catch(err){
      res = err.toString();
    }

    return res;
     
  }

  Future<String> storePost({
    required String caption,
    required Uint8List file,
    required String uid,
    required String username,
    required String? profImage,
  }) async{
    String res = 'Some error occured';
    try{
      String photoUrl = await StorageMethods().uploadImage('posts', file, true);
      String postId = const Uuid().v1();

      Post post = Post(
        caption: caption,
        uid: uid,
        username: username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImage: profImage,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());

      res = 'success';

    }catch(err){
      res = err.toString();
    }

    return res;
  }

  Future<void> likePost({
    required String postId,
    required String uid,
    required List likes,
    required bool smallLike
  }) async{
    try{
      if(likes.contains(uid)){
        if(smallLike){
          await _firestore.collection('posts').doc(postId).update({
            'likes': FieldValue.arrayRemove([uid]),
          });
        }else{}
      }else{

        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> uploadComment({
    required String comment,
    required String postId,
    required String uid,
    required String username,
    required String? profImage,
    required List likes,
  }) async {

    try{
      String commentId = const Uuid().v1();
      await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
        'uid': uid,
        'comment': comment,
        'username': username,
        'date': DateTime.now(),
        'profImage': profImage,
        'likes': likes
      });
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> deletePost({
    required String postId,
  }) async {
    try{
      await _firestore.collection('posts').doc(postId).delete();
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> followUser({
    required String currentUid,
    required String followUid,
  }) async {
    try{
      DocumentSnapshot snap = await _firestore.collection('users').doc(currentUid).get();
      List following = (snap.data()! as dynamic)['following'];

      if(following.contains(followUid)){
        await _firestore.collection('users').doc(followUid).update({
          'followers' : FieldValue.arrayRemove([currentUid])
        });
        await _firestore.collection('users').doc(currentUid).update({
          'following' : FieldValue.arrayRemove([followUid])
        });
      }else{
        await _firestore.collection('users').doc(followUid).update({
          'followers' : FieldValue.arrayUnion([currentUid])
        });
        await _firestore.collection('users').doc(currentUid).update({
          'following' : FieldValue.arrayUnion([followUid])
        });
      }
    }catch(e){
      print(e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}