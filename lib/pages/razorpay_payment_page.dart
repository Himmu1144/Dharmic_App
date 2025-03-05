import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayPaymentPage extends StatefulWidget {
  final double amount;
  const RazorpayPaymentPage({super.key, required this.amount});

  @override
  State<RazorpayPaymentPage> createState() => _RazorpayPaymentPageState();
}

class _RazorpayPaymentPageState extends State<RazorpayPaymentPage> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  void _startPayment() {
    Map<String, dynamic> options = {
      'key': 'rzp_test_fkqY6PGR2AqU7z',
      'amount': widget.amount * 100,
      'name': 'The Sanatan App',
      'description': 'Support Development',
      'prefill': {'contact': '', 'email': ''},
      'readonly': {'contact': true, 'email': true},
      'theme': {'color': '#87CEEB'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Error: ${e.toString()}')),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min, // Add this
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              // Wrap with Flexible
              child: Text(
                'Payment Successful! ID: ${response.paymentId}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
        title: Text('₹${widget.amount.toStringAsFixed(2)}',
            style: GoogleFonts.roboto(fontSize: 20)),
        backgroundColor: const Color(0xFF282828),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // QR Code Card
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FullscreenImage(
                                imageProvider:
                                    AssetImage('assets/images/upi/upi.jpg'),
                              ),
                            ),
                          );
                        },
                        child: Hero(
                          tag: 'qr-code',
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/images/upi/upi.jpg',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 1, color: Colors.grey[800]),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                'Himanshu Sharma',
                                style: GoogleFonts.roboto(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                '(The Sanatan App Developer)',
                                style: GoogleFonts.roboto(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // UPI ID Container
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[850],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(left: 12, top: 8),
                                    child: Text(
                                      'UPI ID',
                                      style: GoogleFonts.roboto(
                                        fontSize: 10,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            bottom: 8,
                                          ),
                                          child: Text(
                                            'himmu5056@okhdfcbank',
                                            style: GoogleFonts.roboto(
                                              color: Colors.grey[300],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy, size: 20),
                                        color: Colors.grey[400],
                                        onPressed: () {
                                          Clipboard.setData(
                                            const ClipboardData(
                                                text: 'himmu5056@okhdfcbank'),
                                          );
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: const Row(
                                                children: [
                                                  Icon(Icons.check,
                                                      color: Colors.white),
                                                  SizedBox(width: 8),
                                                  Text('UPI ID copied!'),
                                                ],
                                              ),
                                              backgroundColor:
                                                  Colors.green[700],
                                              behavior:
                                                  SnackBarBehavior.floating,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Razorpay Payment Button
            ElevatedButton(
              onPressed: _startPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Pay Securely with Razorpay',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
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

// Keep the FullscreenImage widget as is
class FullscreenImage extends StatelessWidget {
  final ImageProvider imageProvider;

  const FullscreenImage({
    super.key,
    required this.imageProvider,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Hero(
              // Add Hero widget here too
              tag: 'qr-code',
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image(
                  image: imageProvider,
                  width: MediaQuery.of(context).size.width *
                      0.9, // Make image larger
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
