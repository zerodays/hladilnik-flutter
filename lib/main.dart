import 'package:flutter/material.dart';
import 'package:hladilnik/api.dart';
import 'package:hladilnik/balance_dialog.dart';
import 'package:hladilnik/error.dart';
import 'package:hladilnik/users_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hladilnik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _displayError = false;

  @override
  void initState() {
    super.initState();

    _fetchData();
  }

  void _fetchData() async {
    bool success = await Api().getData();
    setState(() {
      _displayError = !success;
    });
  }

  void _showAddBalanceDialog(BuildContext context) async {
    List<bool> status = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BalanceDialog();
      },
    );

    if (!status[0]) return;
    bool success = status[1];

    if (success) {
      setState(() {
        _displayError = false;
      });
    }

    String message;
    if (success) {
      message = 'Balance updated!';
    } else {
      message = 'Could not update balance...';
    }

    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _retryDataFetch() async {
    Future<bool> res = Api().getData();
    setState(() {
      _displayError = false;
    });

    bool success = await res;
    setState(() {
      _displayError = !success;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget body;

    if (_displayError) {
      body = Error('Could not fetch data', _retryDataFetch);
    } else if (Api().loading) {
      body = Center(
        child: CircularProgressIndicator(),
      );
    } else if (!Api().hasData) {
      body = Error('Data not yet been fetched', _retryDataFetch);
    } else if (Api().users.length == 0) {
      body = Error('No users on server', _retryDataFetch);
    } else {
      body = UsersList(Api().users, _fetchData);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Hladilnik')),
      body: body,
      floatingActionButton: Builder(
        builder: (BuildContext context) {
          return FloatingActionButton(
            onPressed: () => _showAddBalanceDialog(context),
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}
