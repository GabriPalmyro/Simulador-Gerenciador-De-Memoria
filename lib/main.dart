import 'package:flutter/material.dart';
import 'package:mmu_simulator/mmuHome.dart';
import 'package:desktop_window/desktop_window.dart';

import 'mainScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //await DesktopWindow.setMinWindowSize(Size(1200, 700));
  //await DesktopWindow.setMaxWindowSize(Size(1400, 900));

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MMU SIMULATOR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: FirstScreen.id,
      routes: {
        FirstScreen.id: (context) => FirstScreen(),
        MMUHome.id: (context) =>
            MMUHome(ModalRoute.of(context).settings.arguments)
      },
    );
  }
}
