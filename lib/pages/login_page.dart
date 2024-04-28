import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:instagram_app/pages/signup_page.dart';
import 'package:instagram_app/resources/auth_methods.dart';
import 'package:instagram_app/responsive/mobile_screen_layout.dart';
import 'package:instagram_app/responsive/responsive_layout_screen.dart';
import 'package:instagram_app/responsive/web_screen_layout.dart';
import 'package:instagram_app/utils/colors.dart';
import 'package:instagram_app/utils/global_variables.dart';
import 'package:instagram_app/utils/utils.dart';
import 'package:instagram_app/widgets/text_field_input.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailcontroller = TextEditingController();
  final TextEditingController _passcontroller = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose(){
    super.dispose();
    _emailcontroller.dispose();
    _passcontroller.dispose();
  }

  void loginUser() async{
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().loginUser(
      email: _emailcontroller.text, 
      password: _passcontroller.text
    );

    setState(() {
      _isLoading = false;
    });

    if(res == 'Success'){
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context){
            return const ResponsiveLayout(
              mobileLayout: MobileScreenLayout(),
              webLayout: WebScreenLayout()
            );
          }
        )
      );
    }else{
      showSnackBar(context, res);
    }
  }

  void naviagteToSignup(){
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context){
          return const SignupPage();
        }
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: MediaQuery.of(context).size.width > webScreenSize 
          ? EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width/4)
          : const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(flex: 2, child: Container()),
              SvgPicture.asset('assets/ic_instagram.svg',
                color: primaryColor, 
                height: 64
              ),
              const SizedBox(
                height: 64,
              ),
              TextFieldInput(
                textEditingController: _emailcontroller,
                hint: 'Enter your email',
                textInputType: TextInputType.emailAddress
              ),
              const SizedBox(height: 24),
              TextFieldInput(
                textEditingController: _passcontroller,
                hint: 'Enter your password',
                textInputType: TextInputType.visiblePassword,
                isPass: true,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: loginUser, 
                style: ElevatedButton.styleFrom(
                  foregroundColor: primaryColor,
                  backgroundColor: blueColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 45)
                ),

                child: _isLoading ? const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  )
                ) 
                : const Text('Log in'),
              ),
              
              Flexible(flex: 2, child: Container()),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Don\'t have an account? ', 
                    style: TextStyle(
                      fontSize: 15,
                      color: primaryColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: (){
                      naviagteToSignup();
                    },
                    child: const Text(
                      'Sign Up', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryColor
                      ),
                    ),
                  )
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}
