import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review & Pay'),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Schedule Section
            Text(
              'Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            ListTile(
              leading: Icon(Icons.access_time, color: Colors.black),
              title: Text('Time'),
            ),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.black),
              title: Text('Date'),
            ),
            Divider(),

            // Bill Details Section
            Text(
              'Bill Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            ListTile(
              title: Text('Consultation fees'),
              trailing: Text('Amount'),
            ),
            ListTile(
              title: Text('Booking fee'),
              trailing: Text('Amount'),
            ),
            ListTile(
              title: Text(
                'Total Pay',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: Text(
                'Amount',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(),

            // Payment Options Section
            Text(
              'Pay with',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.0),
            ListTile(
              leading: Icon(Icons.credit_card, color: Colors.black),
              title: Text('Payment Method'),
              trailing: TextButton(
                onPressed: () {
                  // Handle change payment method
                },
                child: Text('Change'),
              ),
            ),
            SizedBox(height: 20.0),

            // Pay Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle payment
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text('Pay (Amount)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}