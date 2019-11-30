import 'package:flutter/material.dart';
import 'package:hladilnik/api.dart';
import 'package:hladilnik/balance_dialog.dart';
import 'package:hladilnik/error.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
    List<bool> success = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return BalanceDialog();
      },
    );

    if (success[0]) {
      setState(() {
        _displayError = !success[1];
      });
    }
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
      body = _CenterLoading();
    } else if (!Api().hasData) {
      body = Error('Data not yet been fetched', _retryDataFetch);
    } else if (Api().users.length == 0) {
      body = Error('No users on server', _retryDataFetch);
    } else {
      body = _UsersList(Api().users, _fetchData);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Hladilnik')),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddBalanceDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}

class _CenterLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(),
    );
  }
}

class _UsersList extends StatelessWidget {
  final List<User> _users;
  final Function _onRefresh;

  _UsersList(this._users, this._onRefresh);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await _onRefresh();
      },
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 8.0),
        itemCount: _users.length,
        itemBuilder: (BuildContext context, int index) {
          User user = _users[index];
          return ListTile(
            title: Text(user.name),
            trailing: Text('${user.balance} €'),
          );
        },
        separatorBuilder: (_, __) => Divider(),
      ),
    );
  }
}
