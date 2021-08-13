import 'dart:io';

import 'package:eins_manager/constants/color_constant.dart';
import 'package:eins_manager/pages/chatting_page.dart';
import 'package:eins_manager/pages/filter_page.dart';
import 'package:eins_manager/pages/product_sale_page.dart';
import 'package:eins_manager/pages/question_youtube_page.dart';
import 'package:eins_manager/providers/auth_provider.dart';
import 'package:eins_manager/screens/entrance_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EinsManagerScreen extends StatelessWidget {
  static const String routeName = '/home';

  const EinsManagerScreen({Key? key}) : super(key: key);

  Future<void> _logOut(BuildContext context) async {
    final AuthProvider authProv = context.read<AuthProvider>();

    late final bool result;

    if (Platform.isIOS) {
      result = await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text("로그아웃하시겠습니까?"),
            content: Text("로그아웃하고 로그인 페이지로 이동합니다."),
            actions: <Widget>[
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text("취소"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text("로그아웃"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );
    } else {
      result = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("로그아웃하시겠습니까?"),
            content: Text(
              "로그아웃하고 로그인 페이지로 이동합니다.",
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text("로그아웃", style: TextStyle(color: kPrimaryColor)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text("취소", style: TextStyle(color: kPrimaryColor)),
              ),
            ],
          );
        },
      );
    }

    if (result == true) {
      authProv.signOut();

      Navigator.of(context).popAndPushNamed(EntranceScreen.routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          title: Center(
            child: Image.asset(
              'assets/images/EINS.png',
              height: 24,
              fit: BoxFit.fitHeight,
            ),
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  _logOut(context);
                },
                icon: Icon(
                  Icons.exit_to_app,
                  color: kPrimaryColor,
                )),
          ],
          bottom: TabBar(
            indicatorColor: kPrimaryColor,
            tabs: <Widget>[
              Tab(child: Icon(Icons.nfc, color: kPrimaryColor)),
              Tab(child: Icon(Icons.shopping_cart, color: kPrimaryColor)),
              Tab(child: Icon(Icons.manage_search, color: kPrimaryColor)),
              Tab(child: Icon(Icons.chat, color: kPrimaryColor)),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: <Widget>[
              FilterPage(),
              ProductSalePage(),
              QuestionYoutubePage(),
              ChattingPage(),
            ],
          ),
        ),
      ),
    );
  }
}
