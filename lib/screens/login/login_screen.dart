import 'package:bitrack_mobile_flutter/base/res/media.dart';
import 'package:bitrack_mobile_flutter/base/res/styles/app_styles.dart';
import 'package:bitrack_mobile_flutter/screens/login/widgets/form_login.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          height: size.height,
          decoration: BoxDecoration(
            color: AppStyles.darkRedColor,
            image: DecorationImage(
              image: AssetImage(AppMedia.bgLogin),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            spacing: 20,
            children: [
              const Expanded(child: SizedBox()),
              Image.asset(AppMedia.logo, scale: 2.5),
              Container(
                width: size.width * 0.9,
                padding: const EdgeInsets.symmetric(
                  vertical: 35,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppStyles.whiteColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: FormLogin(),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }
}
