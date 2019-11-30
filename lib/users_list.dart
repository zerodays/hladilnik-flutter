import 'package:flutter/material.dart';
import 'package:hladilnik/api.dart';
import 'package:hladilnik/constants.dart';

class UsersList extends StatelessWidget {
  final List<User> _users;
  final Function _onRefresh;

  UsersList(this._users, this._onRefresh);

  Widget _itemBuilder(BuildContext context, int index) {
    User user = _users[index];
    return _UserTile(user);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    Widget listView;
    if (width <= SMALL_WIDTH) {
      listView = ListView.separated(
        padding: const EdgeInsets.only(top: 8.0),
        itemCount: _users.length,
        itemBuilder: _itemBuilder,
        separatorBuilder: (_, __) => Divider(),
      );
    } else {
      listView = ListView.builder(
        padding: const EdgeInsets.only(top: 8.0),
        itemCount: _users.length,
        itemBuilder: _itemBuilder,
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: SMALL_WIDTH),
        child: RefreshIndicator(
          onRefresh: () async {
            await _onRefresh();
          },
          child: listView,
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final User _user;

  _UserTile(this._user);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    Widget tile = ListTile(
      title: Text(_user.name),
      trailing: Text('${_user.balance} €'),
    );

    if (width <= SMALL_WIDTH) {
      return tile;
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: tile,
        ),
      );
    }
  }
}
