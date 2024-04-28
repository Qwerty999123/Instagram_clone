import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_app/pages/add_post_page.dart';
import 'package:instagram_app/pages/feed_page.dart';
import 'package:instagram_app/pages/profile_page.dart';
import 'package:instagram_app/pages/search_page.dart';

const webScreenSize = 600;

List<Widget> homeScreenPages = [
  const FeedPage(),
  const SearchPage(),
  const AddPostPage(),
  Center(child: Text('This is favourites screen')),
  ProfilePage(isCurrentUserProfile: true, uid: FirebaseAuth.instance.currentUser!.uid),
];