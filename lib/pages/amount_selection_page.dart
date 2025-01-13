import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dharmic/pages/upi_payment_page.dart';
import 'package:dharmic/pages/razorpay_payment_page.dart';

class AmountSelectionPage extends StatefulWidget {
  const AmountSelectionPage({Key? key}) : super(key: key);

  @override
  State<AmountSelectionPage> createState() => _AmountSelectionPageState();
}

class _AmountSelectionPageState extends State<AmountSelectionPage> {
  final TextEditingController _customAmountController = TextEditingController();
  final List<Map<String, dynamic>> _amounts = [
    {
      'title': 'Small Coffee',
      'subtitle': 'A pat on the back to dev by buying a delicious coffee.',
      'amount': 40.0,
      'icon': Icons.coffee,
    },
    {
      'title': 'Energy Drink',
      'subtitle': 'Here\'s one can of red bull to keep me coding all night.',
      'amount': 125.0,
      'icon': Icons.coffee_maker,
    },
    {
      'title': 'Coffee & Snack',
      'subtitle':
          'What\'s better than a coffee? A coffee with a bit of blinkit and instamart, i guess.',
      'amount': 500.0,
      'icon': Icons.lunch_dining,
    },
    {
      'title': 'A Full Meal',
      'subtitle': 'If we are going all in, then why not swiggy and zomato.',
      'amount': 1000.0,
      'icon': Icons.dinner_dining,
    },
  ];

  void _navigateToPayment(double amount) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RazorpayPaymentPage(amount: amount),
      ),
    );
  }

  Widget _buildAmountCard(BuildContext context, Map<String, dynamic> data) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: 0.95 + (0.05 * value),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Card(
        color: Colors.grey[900],
        elevation: 4,
        child: InkWell(
          onTap: () => _navigateToPayment(data['amount']),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    data['icon'],
                    color: const Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'],
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Text(
                          data['subtitle'],
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₹${data['amount'].toStringAsFixed(0)}',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAmountCard() {
    return Card(
      color: Colors.grey[900],
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF4CAF50),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Custom Amount',
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Choose your own amount',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _customAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: GoogleFonts.roboto(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        hintText: 'Enter amount',
                        hintStyle: GoogleFonts.roboto(color: Colors.grey[600]),
                        prefixText: '₹ ',
                        prefixStyle: GoogleFonts.roboto(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final amount =
                        double.tryParse(_customAmountController.text);
                    if (amount != null && amount > 0) {
                      _navigateToPayment(amount);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Proceed',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: Text(
          'Support Development',
          style: GoogleFonts.roboto(fontSize: 18),
        ),
        backgroundColor: const Color(0xFF282828),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ..._amounts.map((data) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _buildAmountCard(context, data),
                  )),
              const SizedBox(height: 12),
              _buildCustomAmountCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }
}
