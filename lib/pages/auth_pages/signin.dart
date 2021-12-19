import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import 'Widget/singin_container.dart';
import 'signin_vm.dart';
import 'signup.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Widget _usernameWidget(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: const InputDecoration(
        labelText: 'E posta',
        labelStyle: TextStyle(
            color: Color.fromRGBO(173, 183, 192, 1),
            fontWeight: FontWeight.bold),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(173, 183, 192, 1)),
        ),
      ),
    );
  }

  Widget _passwordWidget(TextEditingController controller, bool isVisible,
      Function() changeVisible) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            obscureText: isVisible,
            decoration: const InputDecoration(
              labelText: 'Şifre',
              labelStyle: TextStyle(
                  color: Color.fromRGBO(173, 183, 192, 1),
                  fontWeight: FontWeight.bold),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Color.fromRGBO(173, 183, 192, 1)),
              ),
            ),
          ),
        ),
        GestureDetector(
            onTap: changeVisible,
            child: Icon(isVisible ? Icons.visibility : Icons.visibility_off))
      ],
    );
  }

  Widget _submitButton(Function() action) {
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: action,
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text(
            'Giriş Yap',
            style: TextStyle(
                color: Color.fromRGBO(76, 81, 93, 1),
                fontSize: 25,
                fontWeight: FontWeight.w500,
                height: 1.6),
          ),
          SizedBox.fromSize(
            size: const Size.square(70.0), // button width and height
            child: const ClipOval(
              child: Material(
                color: Color.fromRGBO(76, 81, 93, 1),
                child: Icon(Icons.arrow_forward,
                    color: Colors.white), // button color
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _createAccountLabel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomCenter,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          InkWell(
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => const SignUpPage())),
            child: const Text(
              'Kayıt Ol',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationThickness: 2),
            ),
          ),
          const InkWell(
            // onTap: () {
            //   // Navigator.push(
            //   //     context, MaterialPageRoute(builder: (context) => SignUpPage()));
            // },
            child: Text(
              'Şifremi Unuttum',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                  decorationThickness: 2),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return ChangeNotifierProvider(
      create: (ctx) => SignInVm(ctx),
      child: Consumer<SignInVm>(builder: (_, value, __) {
        return Scaffold(
          body: SizedBox(
            height: height,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Stack(
                children: [
                  Positioned(
                      height: MediaQuery.of(context).size.height * 0.50,
                      child: const SigninContainer()),
                  value.status == LoadingProcess.loading
                      ? SizedBox(
                          height: MediaQuery.of(context).size.height,
                          child: const Center(
                            child: SizedBox(
                              height: 35,
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: <Widget>[
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  SizedBox(height: height * .55),
                                  _usernameWidget(value.emailController),
                                  const SizedBox(height: 20),
                                  _passwordWidget(value.passwordController,
                                      value.isVisible, value.changeVisiblity),
                                  const SizedBox(height: 30),
                                  _submitButton(value.signIn),
                                  SizedBox(height: height * .050),
                                  _createAccountLabel(),
                                ],
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
