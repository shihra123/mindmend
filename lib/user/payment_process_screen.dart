import 'package:flutter/material.dart';

class PaymentProcessScreen extends StatefulWidget {
  final String therapist;
  final String name;
  final String date;
  final String time;

  PaymentProcessScreen({
    required this.therapist,
    required this.name,
    required this.date,
    required this.time,
  });

  @override
  _PaymentProcessScreenState createState() => _PaymentProcessScreenState();
}

class _PaymentProcessScreenState extends State<PaymentProcessScreen> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  final TextEditingController _upiController = TextEditingController();
  bool _isProcessing = false;
  String _selectedPaymentMethod = 'Card';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Payment Process"),
        backgroundColor: Colors.deepOrangeAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.lightBlue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Appointment Details",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Therapist: ${widget.therapist}",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "Name: ${widget.name}",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "Date: ${widget.date}",
              style: TextStyle(color: Colors.white),
            ),
            Text(
              "Time: ${widget.time}",
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 24),
            Text(
              "Payment Method",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: ['Card', 'UPI']
                  .map((method) =>
                      DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedPaymentMethod = value!;
                });
              },
            ),
            SizedBox(height: 16),
            if (_selectedPaymentMethod == 'Card') ...[
              TextField(
                controller: _cardNumberController,
                decoration: InputDecoration(
                  labelText: "Card Number",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      decoration: InputDecoration(
                        labelText: "Expiry Date (MM/YY)",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      decoration: InputDecoration(
                        labelText: "CVV",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ] else if (_selectedPaymentMethod == 'UPI') ...[
              TextField(
                controller: _upiController,
                decoration: InputDecoration(
                  labelText: "UPI ID",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
            SizedBox(height: 24),
            _isProcessing
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Center(
                    child: ElevatedButton(
                      onPressed: _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrangeAccent,
                        padding:
                            EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        textStyle: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      child: Text("Pay Now"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    // Check if all payment fields are filled
    if (_selectedPaymentMethod == 'Card') {
      if (_cardNumberController.text.isEmpty ||
          _expiryController.text.isEmpty ||
          _cvvController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please fill in all card details."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else if (_selectedPaymentMethod == 'UPI') {
      if (_upiController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Please fill in your UPI ID."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    // Simulate a payment process by showing a loading spinner
    setState(() {
      _isProcessing = true;
    });

    // Simulate a network delay for the payment processing
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isProcessing = false;
      });
      _showPaymentSuccessDialog();
    });
  }

  void _showPaymentSuccessDialog() {
    // Show a dialog after payment is successful
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Payment Successful!"),
          content: Text(
              "Your appointment with ${widget.therapist} has been successfully booked for ${widget.date} at ${widget.time}."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the success dialog
                Navigator.pop(context); // Go back to the booking screen
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
