import 'package:eins_manager/constants/color_constant.dart';
import 'package:eins_manager/providers/auth_provider.dart';
import 'package:eins_manager/screens/eins_manager_screen.dart';
import 'package:eins_manager/widgets/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EntranceScreen extends StatefulWidget {
  static const String routeName = '/entrance';

  const EntranceScreen({Key? key}) : super(key: key);

  @override
  _EntranceScreenState createState() => _EntranceScreenState();
}

class _EntranceScreenState extends State<EntranceScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    super.dispose();
  }

  Future<void> _logIn(BuildContext context) async {
    try {
      await context.read<AuthProvider>().signIn(
          email: _emailController.text, password: _passwordController.text);

      Navigator.of(context).pushReplacementNamed(EinsManagerScreen.routeName);
    } catch (e) {
      errorDialog(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size mediaSize = MediaQuery.of(context).size;
    final AuthProgressState authState = context.watch<AuthProvider>().state;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: <Widget>[
                Opacity(
                  opacity: 0.6,
                  child: Container(
                    height: mediaSize.height,
                    width: mediaSize.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: <double>[
                          0.6,
                          0.9,
                        ],
                        colors: <Color>[
                          kBackgroundColor,
                          kPrimaryColor,
                        ],
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/EINS_logo.png',
                        width: MediaQuery.of(context).size.width * 0.5,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 20),
                    Container(
                      width: mediaSize.width,
                      child: Center(
                        child: Image.asset(
                          'assets/images/EINS_title.png',
                          height: 50,
                          fit: BoxFit.fitHeight,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "이메일 주소",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: kBackgroundColor,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "비밀번호",
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kPrimaryColor),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: kBackgroundColor,
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: kPrimaryColor)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.all(20),
                      width: mediaSize.width - 40,
                      height: 48,
                      decoration: BoxDecoration(
                          color: kPrimaryColor,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                      child: InkWell(
                        onTap: authState.loading ? null : () => _logIn(context),
                        child: Center(
                          child: Text(
                            "로그인",
                            style: const TextStyle(
                                color: kBackgroundColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
