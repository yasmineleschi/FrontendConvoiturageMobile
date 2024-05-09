import 'package:flutter/material.dart';

class ReservationPage extends StatefulWidget {
  final Map<String, dynamic> offer;

  ReservationPage({required this.offer});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  late double totalPrice = 0.0;
  String paymentMethod = "Cash";
  int numberOfPassengers = 1;

  late TextEditingController contactController;

  @override
  void initState() {
    super.initState();
    contactController = TextEditingController();
  }

  @override
  void dispose() {
    contactController.dispose();
    super.dispose();
  }

  Future<void> _addReservation() async {}

  void _showAddReservationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              title: Text('Add Reservation'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: contactController,
                        decoration: InputDecoration(labelText: 'Contact Info'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter contact info';
                          }
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (numberOfPassengers > 1) {
                                  numberOfPassengers--;
                                  _calculateTotalPrice();
                                }
                              });
                            },
                            child: Icon(Icons.remove),
                          ),
                          SizedBox(width: 10.0),
                          Text(
                            '$numberOfPassengers',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(width: 10.0),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                if (numberOfPassengers < 4) {
                                  numberOfPassengers++;
                                  _calculateTotalPrice();
                                }
                              });
                            },
                            child: Icon(Icons.add),
                          ),
                        ],
                      ),
                      Text('Total Price $totalPrice'),
                      DropdownButtonFormField<String>(
                        value: paymentMethod,
                        decoration:
                            InputDecoration(labelText: 'Payment Method'),
                        items:
                            ['Credit Card', 'D17', 'Cash'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            paymentMethod = newValue!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select payment method';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Add'),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      ;
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _calculateTotalPrice() {
    totalPrice = numberOfPassengers * 10.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Make Reservation'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                _showAddReservationDialog(context);
              },
              child: Text('Make Reservation'),
            ),

          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ReservationPage(offer: {}),
  ));
}
