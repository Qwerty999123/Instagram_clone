import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_app/pages/login_page.dart';
import 'package:instagram_app/resources/auth_methods.dart';
import 'package:instagram_app/utils/colors.dart';
import 'package:instagram_app/utils/global_variables.dart';
import 'package:instagram_app/utils/utils.dart';
import 'package:instagram_app/widgets/text_field_input.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {

  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passcontroller = TextEditingController();
  final TextEditingController _biocontroller = TextEditingController();
  final TextEditingController _usernamecontroller = TextEditingController();
  Uint8List? _image;
  bool _isLoading = false;

  @override
  void dispose(){
    super.dispose();
    _emailcontroller.dispose();
    _passcontroller.dispose();
    _biocontroller.dispose();
    _usernamecontroller.dispose();
  }

  void selectImage() async{
    Uint8List im = await pickImage(ImageSource.gallery);

    setState(() {
      _image = im;
    });
  }

  void signUpUser() async{
    setState(() {
      _isLoading = true;
    });
    String res = await AuthMethods().signUpUser(
      username: _usernamecontroller.text, 
      email: _emailcontroller.text, 
      bio: _biocontroller.text, 
      password: _passcontroller.text,
      file: _image
    );

    setState(() {
      _isLoading = false;
    });

    if(res != 'success'){
      showSnackBar(context, res); 
    }
  }
  
  void naviagteToLogin(){
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context){
            return const LoginPage();
          }
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize 
          ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/4)
          : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(child: Container(),),
              SvgPicture.asset('assets/ic_instagram.svg',
                color: primaryColor, 
                height: 64
              ),
                    
              const SizedBox(height: 30,),
                    
              Stack(
                children: [
                  _image != null 
                  ? CircleAvatar(
                    radius: 60,
                    backgroundImage: MemoryImage(_image!),
                  )
                  : const CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'
                    ), 
                  ),
                  Positioned(
                    bottom: -8,
                    left: 78,
                    child: IconButton(
                      iconSize: 32,
                      onPressed: (){
                        selectImage();
                      }, 
                      icon: const Icon(
                        Icons.add_a_photo, 
                        color: primaryColor,
                      ),
                    ),
                  )
                ],
              ),
                    
              const SizedBox(height: 30,),
              TextFieldInput(
                textEditingController: _usernamecontroller,
                hint: 'Enter your username',
                textInputType: TextInputType.emailAddress
              ),
                    
              const SizedBox(height: 20),
              TextFieldInput(
                textEditingController: _emailcontroller,
                hint: 'Enter your email',
                textInputType: TextInputType.visiblePassword,
              ),
                    
              const SizedBox(height: 20),
              TextFieldInput(
                textEditingController: _biocontroller,
                hint: 'Enter your bio',
                textInputType: TextInputType.visiblePassword,
              ),
                    
              const SizedBox(height: 20),
              TextFieldInput(
                textEditingController: _passcontroller,
                hint: 'Enter your password',
                textInputType: TextInputType.visiblePassword,
                isPass: true,
              ),
                    
              const SizedBox(height: 20),
                    
              ElevatedButton(
                onPressed: signUpUser, 
                style: ElevatedButton.styleFrom(
                  foregroundColor: primaryColor,
                  backgroundColor: blueColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  minimumSize: const Size(double.infinity, 45)
                ),
                    
                child: _isLoading ? const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  )
                ) 
                : const Text('Sign up'),
              ),
                    
              Flexible(flex: 2, child: Container()),
                    
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Have an account? ', 
                    style: TextStyle(
                      fontSize: 15,
                      color: primaryColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: naviagteToLogin,
                    child: const Text(
                      'Log in', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryColor
                      ),
                    ),
                  )
                ],
              ),
              
                    
            ],
          ),
        )
      ),
    );
  }
}