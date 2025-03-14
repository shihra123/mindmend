import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> therapist;

  PaymentScreen({required this.therapist});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = "UPI";
  String upiId = ""; // UPI ID input field
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    final therapist = widget.therapist;

    return Scaffold(
      appBar: AppBar(
        title: Text("Payment"),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Therapist details
            Text('Therapist: ${therapist['name']}'),
            Text('Fees: ₹${therapist['fees']}'),
            SizedBox(height: 10),
            _buildDetailRow(Icons.confirmation_number, "Token No: ${therapist['id']}"),

            // Date and Time pickers
            SizedBox(height: 20),
            GestureDetector(
              onTap: _selectDate,
              child: _buildDetailRow(Icons.calendar_today, 
                  "Select Date: ${selectedDate == null ? 'Not selected' : "${selectedDate!.toLocal()}".split(' ')[0]}"),
            ),
            SizedBox(height: 10),
            GestureDetector(
              onTap: _selectTime,
              child: _buildDetailRow(Icons.access_time, 
                  "Select Time: ${selectedTime == null ? 'Not selected' : selectedTime!.format(context)}"),
            ),

            // Payment method options
            SizedBox(height: 20),
            Text('Select Payment Method'),
            Row(
              children: [
                Radio(
                  value: "UPI",
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value!;
                    });
                  },
                ),
                Text('UPI'),
                SizedBox(width: 20),
                Radio(
                  value: "Card",
                  groupValue: selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() {
                      selectedPaymentMethod = value!;
                    });
                  },
                ),
                Text('Card'),
              ],
            ),

            // UPI ID input field when UPI is selected
            if (selectedPaymentMethod == "UPI")
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      upiId = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Enter UPI ID",
                    hintText: "example@upi",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

            SizedBox(height: 20),

            // Proceed to payment button
            Spacer(),
            ElevatedButton(
              onPressed: () {
                // Implement your payment logic here (e.g., integrating a payment gateway)
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Payment Successful"),
                    content: Text("Your appointment with ${therapist['name']} is confirmed."),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context); // Go back to the previous screen
                        },
                        child: Text("OK"),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text("Proceed to Payment", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // Function to select Date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Function to select Time
  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange),
          SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
