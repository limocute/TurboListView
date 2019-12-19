import 'package:turbolist_example/demos/index.dart';
import 'package:turbolist_example/demos/page_scaffold.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('TurboListView example app'),
        ),
        body: ListPage([
          PageInfo("City Select", (ctx) => CitySelectRoute()),
          PageInfo("City Select(Custom header)",
                  (ctx) => CitySelectCustomHeaderRoute()),
          PageInfo("Contacts List", (ctx) => ContactListRoute()),
          PageInfo("Contacts List 列表头部显示悬浮标签", (ctx) => ContactListRoute2()),
          PageInfo("Contacts List 自定义索引列表", (ctx) => ContactListRoute3()),
          PageInfo(
              "IndexBar & SuspensionView", (ctx) => IndexSuspensionRoute()),
        ]),
      ),
    );
  }
}
