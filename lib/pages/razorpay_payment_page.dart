import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentPage extends StatefulWidget {
  final double amount;

  const RazorpayPaymentPage({
    Key? key,
    required this.amount,
  }) : super(key: key);

  @override
  State<RazorpayPaymentPage> createState() => _RazorpayPaymentPageState();
}

class _RazorpayPaymentPageState extends State<RazorpayPaymentPage> {
  late Razorpay _razorpay;
  final List<Map<String, dynamic>> _paymentOptions = [
    {
      'title': 'Google Pay',
      'icon': 'assets/images/upi/upi.jpg',
      'method': 'upi',
      'preferredApp': 'gpay'
    },
    {
      'title': 'PhonePe',
      'icon': 'assets/images/upi/upi.jpg',
      'method': 'upi',
      'preferredApp': 'phonepe'
    },
    {
      'title': 'Paytm',
      'icon': 'assets/images/upi/upi.jpg',
      'method': 'upi',
      'preferredApp': 'paytm'
    },
    {'title': 'BHIM UPI', 'icon': 'assets/images/upi/upi.jpg', 'method': 'upi'},
    {
      'title': 'Credit/Debit Card',
      'icon': 'assets/images/upi/upi.jpg',
      'method': 'card'
    },
    {
      'title': 'Net Banking',
      'icon': 'assets/images/upi/upi.jpg',
      'method': 'netbanking'
    },
  ];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _startPayment(Map<String, dynamic> option) {
    var options = {
      'key': 'rzp_test_fkqY6PGR2AqU7z',
      'amount': widget.amount * 100,
      'name': 'Sanatan App',
      'description': 'Support Development',
      'prefill': {'contact': '', 'email': ''},
      'method': option['method'],
      // Handle UPI specific options
      if (option['method'] == 'upi') ...{
        'method': 'upi',
        'upi': {
          'flow': 'intent', // Forces external app opening
          if (option['preferredApp'] != null)
            'preferred_apps': [option['preferredApp']]
        }
      },
      // Handle other payment methods
      if (option['method'] == 'card') 'method': 'card',
      if (option['method'] == 'netbanking') 'method': 'netbanking',
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed to initialize')),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Payment Successful! ID: ${response.paymentId}'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'Choose Payment Method',
          style: GoogleFonts.roboto(fontSize: 18),
        ),
        backgroundColor: const Color(0xFF282828),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount:',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  Text(
                    '₹${widget.amount.toStringAsFixed(2)}',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4CAF50),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Payment Options',
              style: GoogleFonts.roboto(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            ..._paymentOptions.map((option) => Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => _startPayment(option),
                    leading: Image.asset(
                      option['icon'],
                      width: 32,
                      height: 32,
                    ),
                    title: Text(
                      option['title'],
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.grey,
                      size: 16,
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }
}
