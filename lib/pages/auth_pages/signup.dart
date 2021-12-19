import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import 'Widget/signup_container.dart';
import 'signup_vm.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final UnderlineInputBorder _border = const UnderlineInputBorder(
    borderSide: BorderSide(color: Colors.white),
  );

  final TextStyle _textStyle = const TextStyle(
      color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13);

  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(left: 0, top: 20, bottom: 10),
              child: const Icon(Icons.keyboard_arrow_left, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nameWidget(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      style: _textStyle,
      decoration: InputDecoration(
        labelText: 'İsim',
        labelStyle: _textStyle,
        enabledBorder: _border,
      ),
    );
  }

  Widget _emailWidget(TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: _textStyle,
      validator: (mail) {},
      decoration: InputDecoration(
        //hintText: 'Enter your full name',
        labelText: 'Email',
        labelStyle: _textStyle,
        enabledBorder: _border,
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
            keyboardType: TextInputType.visiblePassword,
            textInputAction: TextInputAction.next,
            obscureText: isVisible,
            style: _textStyle,
            decoration: InputDecoration(
              labelText: 'Şifre',
              labelStyle: _textStyle,
              enabledBorder: _border,
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
            'Kayıt Ol',
            style: TextStyle(
                color: Colors.white,
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

  Widget _createLoginLabel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.bottomLeft,
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: const Text(
          'Giriş',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.underline,
            decorationThickness: 2,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return ChangeNotifierProvider(
      create: (ctx) => SignUpVm(ctx),
      child: Consumer<SignUpVm>(
        builder: (_, value, __) => Scaffold(
          body: SizedBox(
            height: height,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: _stack(context, height, value),
            ),
          ),
        ),
      ),
    );
  }

  Stack _stack(BuildContext context, double height, SignUpVm vm) {
    return Stack(
      children: [
        Positioned(
            height: MediaQuery.of(context).size.height * 1,
            child: const SignUpContainer()),
        vm.status == LoadingProcess.loading
            ? SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const Center(
                  child: SizedBox(
                    height: 35,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            : Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _body(height, vm),
                  ),
                ],
              ),
        if (checkPop(context))
          Positioned(top: 60, left: 0, child: _backButton()),
      ],
    );
  }

  Column _body(double height, SignUpVm vm) {
    return Column(
      children: [
        SizedBox(height: height * .4),
        _nameWidget(vm.nameController),
        const SizedBox(height: 20),
        _emailWidget(vm.emailController),
        const SizedBox(height: 20),
        _passwordWidget(
            vm.passwordController, vm.isVisible, vm.changeVisiblity),
        const SizedBox(height: 80),
        if (vm.errorMsg != '') ...{
          _errorMessageSection(vm.errorMsg),
          const SizedBox(height: 20),
        },
        _submitButton(vm.signUp),
        SizedBox(height: height * .050),
        _createLoginLabel(),
      ],
    );
  }

  Widget _errorMessageSection(String errorMsg) {
    return Align(
      alignment: Alignment.center,
      child: Text(
        errorMsg,
        style: TextStyle(color: Theme.of(context).errorColor),
      ),
    );
  }
}
