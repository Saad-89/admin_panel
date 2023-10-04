import 'package:flutter/material.dart';

class DeleteReasonDialog extends StatefulWidget {
  @override
  _DeleteReasonDialogState createState() => _DeleteReasonDialogState();
}

class _DeleteReasonDialogState extends State<DeleteReasonDialog> {
  String? _selectedReason;
  final List<String> reasons = [
    'Misconduct',
    'Invalid Information',
    'Duplicate Entry',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reason for Deletion'),
      content: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text('Select a reason',
              style: TextStyle(color: Colors.grey[600])),
          value: _selectedReason,
          dropdownColor: Color(0xffF3F2FF), // background color of the dropdown
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.0,
            fontFamily: 'karla',
          ),
          items: reasons.map((String reason) {
            return DropdownMenuItem<String>(
              value: reason,
              child: Text(reason),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedReason = newValue;
            });
          },
          icon: Icon(Icons.arrow_drop_down, color: Color(0xff6858FE)),
          itemHeight: 50.0, // height for each dropdown item (optional)
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll(Colors.deepPurpleAccent)),
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop({'confirmed': false});
          },
        ),
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll(Colors.deepPurpleAccent)),
          child: Text('Confirm Delete'),
          onPressed: () {
            if (_selectedReason != null) {
              Navigator.of(context)
                  .pop({'confirmed': true, 'reason': _selectedReason});
            } else {
              // Optionally, you can show a snackbar/message prompting the user to select a reason
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Please select a reason for deletion')),
              );
            }
          },
        ),
      ],
    );
  }
}
