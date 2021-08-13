import 'package:async/async.dart';
import 'package:eins_manager/constants/color_constant.dart';
import 'package:eins_manager/providers/auth_provider.dart';
import 'package:eins_manager/providers/product_provider.dart';
import 'package:eins_manager/screens/chatting_screen.dart';
import 'package:eins_manager/screens/eins_manager_screen.dart';
import 'package:eins_manager/screens/entrance_screen.dart';
import 'package:eins_manager/widgets/error_dialog.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebaseAuth;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);

  runApp(MultiProvider(
    providers: [
      StreamProvider<firebaseAuth.User?>.value(
        value: firebaseAuth.FirebaseAuth.instance.authStateChanges(),
        initialData: null,
      ),
      ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
      Provider<ProductProvider>(create: (_) => ProductProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future<void> _fetchData(BuildContext context) {
    return _memoizer.runOnce(() async {
      await _initializeEins(context);
    });
  }

  Future<void> _initializeEins(BuildContext context) async {
    try {
      ConnectivityResult result = await Connectivity().checkConnectivity();

      if (result == ConnectivityResult.none) {
        throw "와이파이, 모바일 데이터 혹은 비행기모드 설정을 확인해 주시기 바랍니다.";
      }

      await Firebase.initializeApp();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fetchData(context),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              appBarTheme: AppBarTheme(backgroundColor: Colors.white),
            ),
            home: Builder(builder: (context) {
              errorDialog(context, snapshot.error, afterDialog: (value) {
                SystemChannels.platform.invokeMethod("SystemNavigator.pop");
              });
              return Splash();
            }),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            builder: (BuildContext context, Widget? child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                child: child!,
              );
            },
            title: "EINS",
            theme: ThemeData(
              scaffoldBackgroundColor: kBackgroundColor,
              appBarTheme: AppBarTheme(color: kBackgroundColor),
              primaryColor: kPrimaryColor,
              accentColor: kPrimaryColor,
              textSelectionTheme: TextSelectionThemeData(
                  cursorColor: kPrimaryColor,
                  selectionColor: kPrimaryColor,
                  selectionHandleColor: kPrimaryColor),
              textTheme:
                  Theme.of(context).textTheme.apply(bodyColor: kTextColor),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: context.read<firebaseAuth.User?>() == null
                ? EntranceScreen()
                : EinsManagerScreen(),
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case EntranceScreen.routeName:
                  return MaterialPageRoute(builder: (_) => EntranceScreen());
                case EinsManagerScreen.routeName:
                  return MaterialPageRoute(builder: (_) => EinsManagerScreen());
                case ChattingScreen.routeName:
                  return MaterialPageRoute(builder: (_) => ChattingScreen());
              }
            },
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            appBarTheme: AppBarTheme(backgroundColor: Colors.white),
          ),
          home: Splash(),
        );
      },
    );
  }
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/images/EINS_title.png',
          width: MediaQuery.of(context).size.width * 0.785,
          fit: BoxFit.fitWidth,
        ),
      ),
    );
  }
}
