import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BookAppointmentScreen extends StatefulWidget {
  @override
  _BookAppointmentScreenState createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  String? _selectedTherapist;
  late Razorpay _razorpay; // Used 'late' to ensure initialization

  final List<String> _therapists = [
    "Dr. Smith - Psychologist",
    "Dr. Johnson - Psychiatrist",
    "Dr. Brown - Counselor",
    "Dr. Williams - Therapist",
    "Dr. Davis - Mental Health Coach",
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    // Razorpay event listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear(); // Cleaning up the Razorpay instance
    super.dispose();
  }

  void _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
      });
    }
  }

  void _selectTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Successful! Appointment Confirmed."),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment Failed! Try Again."),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment via External Wallet: ${response.walletName}"),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _startPayment() {
    if (_nameController.text.isEmpty ||
        _dateController.text.isEmpty ||
        _timeController.text.isEmpty ||
        _selectedTherapist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill in all details before proceeding."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    var options = {
      "key": "rzp_test_YourKeyHere", // Replace with your Razorpay key
      "amount": 50000, // Amount in paise (500 INR)
      "currency": "INR",
      "name": "Mind Mend",
      "description": "Therapy Appointment",
      "prefill": {
        "contact": "9999999999",
        "email": "user@example.com",
      },
      "theme": {"color": "#FF6F00"}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book Appointment"),
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Therapist",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedTherapist,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: _therapists.map((therapist) {
                  return DropdownMenuItem(
                    value: therapist,
                    child: Text(therapist),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedTherapist = value;
                  });
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Your Name",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  labelText: "Preferred Date",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _timeController,
                readOnly: true,
                onTap: _selectTime,
                decoration: InputDecoration(
                  labelText: "Preferred Time",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
              SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _startPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text("Proceed to Payment"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
