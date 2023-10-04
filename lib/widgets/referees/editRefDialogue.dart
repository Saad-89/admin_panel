import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../screens/refrees.dart';

class EditRefereeDialog extends StatefulWidget {
  final Referees referee;

  EditRefereeDialog({required this.referee});

  @override
  _EditRefereeDialogState createState() => _EditRefereeDialogState();
}

class _EditRefereeDialogState extends State<EditRefereeDialog> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _addressController = TextEditingController();

  String? _selectedSpecialization;
  List<String> _specializations = [
    'Football',
    'Cricket',
    'Boxing',
    'Volleyball',
  ];

  String? _selectedExperience;
  List<String> _experiences = [
    '0-1 years',
    '1-3 years',
    '3-5 years',
    '5+ years',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.referee.name;
    _emailController.text = widget.referee.email;
    _ageController.text = widget.referee.age;
    _addressController.text = widget.referee.address;
    _selectedExperience = widget.referee.experience;
    _selectedSpecialization = widget.referee.specialization;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("EDIT REFEREE"),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter Referee Name',
                  hintStyle: TextStyle(
                    fontFamily: 'karla',
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Colors.blueGrey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  hintText: 'Enter Referee Email',
                  hintStyle: TextStyle(
                    fontFamily: 'karla',
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Colors.blueGrey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter referee email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _ageController,
                decoration: InputDecoration(
                  hintText: 'Enter Referee Age',
                  hintStyle: TextStyle(
                    fontFamily: 'karla',
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Colors.blueGrey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter referee age';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedExperience,
                hint: Text('Select experience'),
                decoration: InputDecoration(
                  hintText: 'Select experience',
                  hintStyle: TextStyle(
                    fontFamily: 'karla',
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Colors.blueGrey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                items: _experiences.map((String experience) {
                  return DropdownMenuItem<String>(
                    value: experience,
                    child: Text(experience),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedExperience = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select experience';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<String>(
                value: _selectedSpecialization,
                hint: Text('Select a specialization'),
                decoration: InputDecoration(
                  hintText: 'Select a specialization',
                  hintStyle: TextStyle(
                    fontFamily: 'karla',
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Colors.blueGrey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                items: _specializations.map((String specialization) {
                  return DropdownMenuItem<String>(
                    value: specialization,
                    child: Text(specialization),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSpecialization = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a specialization';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText: 'Enter Referee Address',
                  hintStyle: TextStyle(
                    fontFamily: 'karla',
                  ),
                  border: OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 0.5,
                      color: Colors.blueGrey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.blueGrey,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter referee address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll(Colors.deepPurpleAccent)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          style: ButtonStyle(
              backgroundColor:
                  MaterialStatePropertyAll(Colors.deepPurpleAccent)),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              Referees editedReferee = Referees(
                id: widget.referee.id,
                name: _nameController.text,
                email: _emailController.text,
                age: _ageController.text,
                address: _addressController.text,
                experience: _selectedExperience!,
                specialization: _selectedSpecialization!,
              );

              final docRef = FirebaseFirestore.instance
                  .collection('referees')
                  .doc(widget.referee.id);
              await docRef.update({
                'name': _nameController.text,
                'email': _emailController.text,
                'age': _ageController.text,
                'address': _addressController.text,
                'experience': _selectedExperience!,
                'specialization': _selectedSpecialization!,
              });
              Navigator.pop(context, editedReferee);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Referee Updated successfully',
                    style: TextStyle(color: Colors.black),
                  ),
                  backgroundColor: Colors.yellow,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            }
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
