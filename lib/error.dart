import 'package:flutter/material.dart';

class Error extends StatelessWidget {
  final String _error;
  final Function _onRetry;

  Error(this._error, this._onRetry);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Text(
            _error,
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 24.0,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: RaisedButton(
            child: Text('Retry'),
            onPressed: _onRetry,
            color: Theme.of(context).colorScheme.secondary,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ],
    );
  }
}
