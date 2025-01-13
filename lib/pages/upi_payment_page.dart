import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upi_india/upi_india.dart';
import 'package:google_fonts/google_fonts.dart';

class UpiPaymentPage extends StatefulWidget {
  final double amount;
  const UpiPaymentPage({Key? key, required this.amount}) : super(key: key);

  @override
  State<UpiPaymentPage> createState() => _UpiPaymentPageState();
}

class _UpiPaymentPageState extends State<UpiPaymentPage> {
  Future<UpiResponse>? _transaction;
  final UpiIndia _upiIndia = UpiIndia();
  List<UpiApp>? apps;

  @override
  void initState() {
    super.initState();
    _loadUpiApps();
  }

  Future<void> _loadUpiApps() async {
    try {
      final value = await _upiIndia.getAllUpiApps();
      setState(() {
        apps = value;
      });
    } catch (e) {
      print('Error loading UPI apps: $e');
      // Show error message to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load UPI apps. Please try again.'),
          ),
        );
      }
    }
  }

  Future<UpiResponse> initiateTransaction(UpiApp app) {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "9540722521@ybl", // Your UPI ID
      receiverName: '(Sanatan App Developer)',
      transactionRefId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      transactionNote: 'Support The Sanatan App',
      amount: widget.amount,
    );
  }

  Widget displayTransactionData(title, body) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("$title: ", style: const TextStyle(fontSize: 16)),
          Flexible(
            child: Text(body, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '₹${widget.amount.toStringAsFixed(2)}', // Show amount with Rupee symbol
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: const Color(0xFF282828),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Payment Method',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              // UPI Apps Grid
              apps == null
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: apps!.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _transaction = initiateTransaction(apps![index]);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.memory(
                                  apps![index].icon,
                                  height: 40,
                                  width: 40,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  apps![index].name,
                                  style: GoogleFonts.roboto(fontSize: 12),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              const SizedBox(height: 32),
              // QR Code Section
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // QR Code section
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
                            // Add Hero widget for smooth transition
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
                      Container(
                        width: 1,
                        color: Colors.grey[800],
                      ),
                      // Details section
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
                                  '(Sanatan App Developer)',
                                  style: GoogleFonts.roboto(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[850],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, top: 8),
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
                                              '9540722521@ybl',
                                              style: GoogleFonts.roboto(
                                                color: Colors.grey[300],
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon:
                                              const Icon(Icons.copy, size: 20),
                                          color: Colors.grey[400],
                                          onPressed: () {
                                            Clipboard.setData(
                                              const ClipboardData(
                                                  text: '9540722521@ybl'),
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
                                                duration:
                                                    const Duration(seconds: 2),
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
                              const SizedBox(height: 16),
                              Text(
                                'A coffee from you helps me stay awake and code better. Thank you for your support. Jay Shree Ram ❤️',
                                textAlign: TextAlign.start,
                                style: GoogleFonts.roboto(
                                  color: Colors.grey[400],
                                  fontSize: 12,
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
              if (_transaction != null) ...[
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FutureBuilder(
                    future: _transaction,
                    builder: (context, AsyncSnapshot<UpiResponse> snapshot) {
                      if (snapshot.hasError) {
                        return const Center(child: Text('An Error Occurred'));
                      }
                      if (snapshot.hasData) {
                        switch (snapshot.data!.status) {
                          case UpiPaymentStatus.SUCCESS:
                            return Column(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.green, size: 50),
                                const SizedBox(height: 8),
                                Text(
                                  'Transaction Successful',
                                  style: GoogleFonts.roboto(),
                                ),
                                if (snapshot.data!.transactionId != null)
                                  Text('TxnID: ${snapshot.data!.transactionId}',
                                      style: GoogleFonts.roboto()),
                              ],
                            );
                          case UpiPaymentStatus.FAILURE:
                            return const Center(
                                child: Text('Transaction Failed'));
                          case UpiPaymentStatus.SUBMITTED:
                            return const Center(
                                child: Text('Transaction Submitted'));
                          default:
                            return const Center(
                                child: Text('Transaction Status Unknown'));
                        }
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class FullscreenImage extends StatelessWidget {
  final ImageProvider imageProvider;

  const FullscreenImage({
    Key? key,
    required this.imageProvider,
  }) : super(key: key);

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
