import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_app/models/user.dart' as models;
import 'package:instagram_app/providers/user_provider.dart';
import 'package:instagram_app/resources/auth_methods.dart';
import 'package:instagram_app/utils/colors.dart';
import 'package:instagram_app/utils/utils.dart';
import 'package:provider/provider.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  Uint8List? _file;
  final TextEditingController _captionController = TextEditingController();
  bool _isLoading = false;

  void postImage(
    String uid,
    String username,
    String profImage,
  ) async {
    try{
      setState(() {
        _isLoading = true;
      });
      String res = await AuthMethods().storePost(
        caption: _captionController.text, 
        file: _file!, 
        uid: uid, 
        username: username, 
        profImage: profImage
      );

      setState(() {
        _isLoading = false;
      });

      if (res == 'success'){
        showSnackBar(context, 'Posted');
        setState(() {
          _file = null;
        });
        _captionController.clear();
      }else{
        showSnackBar(context, res);
      }

    }catch(err){
      showSnackBar(context, err.toString());
    }
  }

  @override
  void dispose(){
    super.dispose();
    _captionController.dispose();
  }

  _selectImage(BuildContext context) async{
    return showDialog(
      context: context, 
      builder: (context){
        return SimpleDialog(
          title: const Text('Create a Post'),
          children: [
            SimpleDialogOption(
              onPressed: () async{
                Navigator.of(context).pop();
                Uint8List file = await pickImage(
                  ImageSource.camera
                );
                setState(() {
                  _file = file;
                });
              },
              child: const Row(
                children:[
                  Icon(Icons.camera_alt_outlined),
                  SizedBox(width: 5),
                  Text('Take a photo'),
                ],
              ),
            ),

            SimpleDialogOption(
              onPressed: () async{
                Navigator.of(context).pop();
                Uint8List file = await pickImage(
                  ImageSource.gallery
                );
                setState(() {
                  _file = file;
                });
              },
              child: const Row(
                children:[
                  Icon(Icons.photo_outlined),
                  SizedBox(width: 5,),
                  Text('Choose from device'),
                ] 
              ),
            ),

            SimpleDialogOption(
              child: const Text('Cancel'),
              onPressed: () async{
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    models.User _user = Provider.of<UserProvider>(context).getUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.arrow_back
          ),
        ),
        title: const Text('New Post'),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () {
              if(_file != null && _captionController.text.isNotEmpty){
                postImage(_user.uid, _user.username, _user.imageUrl!);
              }else if((_file == null && _captionController.text.isEmpty) || _file == null){
                showDialog(
                  context: context, 
                  builder: (context){
                    return AlertDialog(
                      title: const Text('No file selected'),
                      content: const Text('Select image or video'),
                      actions: [
                        TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          }, 
                          child: const Text('Ok'),
                        )
                      ]
                    );
                  }
                );
              }else if(_captionController.text.isEmpty){
                showDialog(
                  context: context, 
                  builder: (context){
                    return AlertDialog(
                      title: const Text('No caption added'),
                      content: const Text('Are you sure you want to post without a caption ?'),
                      actions: [
                        TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                          }, 
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: (){
                            Navigator.of(context).pop();
                            postImage(_user.uid, _user.username, _user.imageUrl!);
                          }, 
                          child: const Text('Yes'),
                        )
                      ]
                    );
                  }
                );
              }
              

            }, 
            child: const Text(
              'Post',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 15
              )
            )
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView(
          children: [
            _isLoading ? const LinearProgressIndicator() : const Padding(padding: EdgeInsets.only(top: 0),),
            
            Row(
              children:[
                CircleAvatar(
                  backgroundImage: _user.imageUrl == null
                  ? const NetworkImage(
                    'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg',
                  )
                  : NetworkImage(
                    _user.imageUrl!,
                  ),
                  radius: 25,
                ),
                
                const SizedBox(
                  width: 15,
                ),

                Text(
                  _user.username,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold
                  )
                ),
              ] 
            ),
            
            const SizedBox(
              height: 15
            ),

            GestureDetector(
              onTap: () => _selectImage(context),
              child: _file == null
              
              ? Container(
                width: double.infinity,
                height: 250,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://static.vecteezy.com/system/resources/thumbnails/001/500/603/small/add-icon-free-vector.jpg'
                    )
                  )
                ),
              )
              : Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  color: mobileBackgroundColor,
                  image: DecorationImage(
                    image: MemoryImage(_file!)
                  )
                ),
              )
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'Write a Caption...',
                border: InputBorder.none,
              ),
              maxLines: 4,
            ) 
          ],
        ),
      )
    );
  }
}