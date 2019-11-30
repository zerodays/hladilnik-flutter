import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hladilnik/api.dart';
import 'package:hladilnik/constants.dart';

class BalanceDialog extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BalanceDialogState();
}

class _BalanceDialogState extends State<BalanceDialog> {
  bool _saving = false;

  int _selectedUserID = -1;
  double _amount = 0.0;

  void _save() async {
    setState(() {
      _saving = true;
    });

    bool success = await Api().addBalance(_selectedUserID, _amount);
    Navigator.of(context).pop([true, success]);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> elements = [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: DropdownButton<int>(
          isExpanded: true,
          value: _selectedUserID < 0 ? null : _selectedUserID,
          hint: Text('User'),
          items: Api().users.map((User user) {
            return DropdownMenuItem<int>(
              value: user.id,
              child: Text('${user.name} (${user.balance} €)'),
            );
          }).toList(),
          onChanged: (int id) {
            setState(() {
              _selectedUserID = id;
            });
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(32.0, 8.0, 32.0, 0.0),
        child: TextField(
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            labelText: 'Amount',
            suffixText: '€',
          ),
          inputFormatters: [
            WhitelistingTextInputFormatter(RegExp('^\\d+[,\\.]?\\d{0,2}')),
          ],
          onChanged: (String value) {
            double amount = double.tryParse(value.replaceAll(',', '.'));

            setState(() {
              _amount = amount == null ? 0.0 : amount;
            });
          },
        ),
      ),
    ];

    if (_saving) {
      elements = [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ];
    }

    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxWidth: SMALL_WIDTH),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(32.0, 32.0, 32.0, 16.0),
              child: Text(
                'Add Balance',
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 32.0,
                ),
              ),
            ),
            ...elements,
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop([false, false]),
                    textColor: Colors.red,
                  ),
                  FlatButton(
                    child: Text('Save'),
                    textColor: Theme.of(context).colorScheme.secondary,
                    onPressed:
                        (_selectedUserID < 0 || _amount <= 0.0) ? null : _save,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
