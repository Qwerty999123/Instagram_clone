
import 'package:flutter/material.dart';
import 'package:instagram_app/providers/user_provider.dart';
import 'package:instagram_app/utils/global_variables.dart';
import 'package:provider/provider.dart';

class ResponsiveLayout extends StatefulWidget {
  final Widget webLayout;
  final Widget mobileLayout;
  const ResponsiveLayout({
    super.key, 
    required this.mobileLayout, 
    required this.webLayout
  });

  @override
  State<ResponsiveLayout> createState() => _ResponsiveLayoutState();
}

class _ResponsiveLayoutState extends State<ResponsiveLayout> {
  @override
  void initState(){
    super.initState();
    addData();
  }

  void addData() async{
    UserProvider userProvider = Provider.of(context, listen: false);
    await userProvider.refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        if(constraints.maxWidth > webScreenSize){
          return widget.webLayout;
        }else{
          return widget.mobileLayout;
        }
      }
    );
  }
}