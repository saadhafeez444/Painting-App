import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:painting_app/key_constants/key_constants.dart';
import 'package:painting_app/models/painting.dart';
import 'package:painting_app/services/banner_services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';



class PaymentScreen extends StatefulWidget {
  final Painting book;
  const PaymentScreen({super.key, required this.book});
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethod = 0;
  final _formKey = GlobalKey<FormState>();
  final _cardController = TextEditingController();
  final _cvvController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  Map<String, dynamic>? paymentIntent;

  bool _isValidPhone(String phone) {
    return RegExp(r'^03[0-9]{9}$').hasMatch(phone);
  }

  bool _isValidPin(String pin) {
    return pin.length >= 4 && pin.length <= 6;
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool _isValidAccount(String account) {
    return account.length >= 9;
  }

  bool _isValidIBAN(String iban) {
    return iban.length >= 16;
  }

  final List<PaymentMethod> _paymentMethods = [
    PaymentMethod(
      name: 'JazzCash',
      icon: Icons.phone_android,
      color: const Color(0xFFF6851F),
      fields: {'phone': 'Phone Number', 'pin': 'PIN'},
    ),
    PaymentMethod(
      name: 'EasyPaisa',
      icon: Icons.phone_iphone,
      color: const Color(0xFF00A79D),
      fields: {'phone': 'Phone Number', 'pin': 'PIN'},
    ),
    PaymentMethod(
      name: 'PayPal',
      icon: Icons.payment,
      color: const Color(0xFF003087),
      fields: {'email': 'Email', 'password': 'Password'},
    ),
    PaymentMethod(
      name: 'Bank Transfer',
      icon: Icons.account_balance,
      color: Colors.blue,
      fields: {'account': 'Account Number', 'iban': 'IBAN'},
    ),
  ];


  double get _parsedPrice => widget.book.price;

  String get _formattedPrice {
    final fmt = NumberFormat.currency(
      locale: 'en_PK',
      symbol: 'PKR ',
      decimalDigits: 0,
    );
    return fmt.format(_parsedPrice);
  }

  @override
  Widget build(BuildContext context) {

    final currencyFormat = NumberFormat.currency(symbol: 'Rs ', decimalDigits: 0);
    final formattedPriceWithRs = currencyFormat.format(_parsedPrice);

    return Scaffold(
      backgroundColor: const Color(0xFF2D2F41),
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Payment Gateway',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBookCard(_formattedPrice),
            const SizedBox(height: 30),
            _buildPaymentMethods(),
            const SizedBox(height: 30),
            _buildPaymentForm(),
            const SizedBox(height: 30),
            _buildPayButton(_formattedPrice),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCard(String formattedPrice) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  
                  decoration: BoxDecoration(
                     image: widget.book.imagePath.startsWith('assets/')
                              ? DecorationImage(
                                  image: AssetImage(widget.book.imagePath),
                                  fit: BoxFit.fill,
                                )
                              : (File(widget.book.imagePath).existsSync()
                                    ? DecorationImage(
                                        image: FileImage(
                                          File(widget.book.imagePath),
                                        ),
                                        fit: BoxFit.fill,
                                      )
                                    : null),
                  ),
                  width: 100,
                  height: 120,
               
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      widget.book.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.book.artistName,
                         maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                         maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      '$formattedPrice',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white24),
          const SizedBox(height: 10),
          const Text(
            'Secure Payment Gateway',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Payment Method',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _paymentMethods.length,
            separatorBuilder: (_, __) => const SizedBox(width: 15),
            itemBuilder: (context, index) {
              final method = _paymentMethods[index];
              return GestureDetector(
                onTap: () => setState(() => _selectedMethod = index),
                child: Container(
                  width: 120,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: method.color.withOpacity(_selectedMethod == index ? 1 : 0.3),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: _selectedMethod == index ? Colors.amber : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(method.icon, color: Colors.white, size: 30),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 110,
                        child: Text(
                          method.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

Widget _buildPaymentForm() {
  final currentMethod = _paymentMethods[_selectedMethod];

  return Form(
    key: _formKey,
    child: Column(
      children: [
        ...currentMethod.fields.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextFormField(
              controller: _getController(entry.key),
              obscureText: entry.key == 'pin' || entry.key == 'password',
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: entry.value,
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: _getFieldIcon(entry.key),
              ),
              validator: (value) {
                final trimmedValue = value?.trim() ?? '';

                if (trimmedValue.isEmpty) {
                  return 'This field is required';
                }

                if (entry.key == 'phone' && !_isValidPhone(trimmedValue)) {
                  return 'Enter a valid Pakistan phone (03XXXXXXXXX)';
                }
                if (entry.key == 'pin' && !_isValidPin(trimmedValue)) {
                  return 'PIN must be 4-6 digits';
                }
                if (entry.key == 'email' && !_isValidEmail(trimmedValue)) {
                  return 'Enter a valid email';
                }
                if (entry.key == 'account' && !_isValidAccount(trimmedValue)) {
                  return 'Account must be at least 9 characters';
                }
                if (entry.key == 'iban' && !_isValidIBAN(trimmedValue)) {
                  return 'IBAN seems too short';
                }

                return null;
              },
              onChanged: (value) {
             
                final trimmed = value.trimLeft();
                if (value != trimmed) {
                  _getController(entry.key).text = trimmed;
                  _getController(entry.key).selection = TextSelection.fromPosition(
                    TextPosition(offset: trimmed.length),
                  );
                }
              },
            ),
          );
        }).toList(),
      ],
    ),
  );
}


  Icon _getFieldIcon(String key) {
    switch (key) {
      case 'phone':
        return const Icon(Icons.phone, color: Colors.white70);
      case 'pin':
        return const Icon(Icons.lock, color: Colors.white70);
      case 'email':
        return const Icon(Icons.email, color: Colors.white70);
      case 'password':
        return const Icon(Icons.password, color: Colors.white70);
      default:
        return const Icon(Icons.payment, color: Colors.white70);
    }
  }

  TextEditingController _getController(String key) {
    switch (key) {
      case 'phone':
        return _phoneController;
      case 'pin':
        return _pinController;
      case 'email':
        return _cardController;
      case 'password':
        return _cvvController;
      default:
        return _cardController;
    }
  }

  Widget _buildPayButton(String formattedPrice) {
    // show "Rs " label if you want but user asked for PKR formatted earlier.
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // You used both makePayment() and _processPayment() in previous code.
            // I kept makePayment as primary payment flow (Stripe). You can call _processPayment if you want the dialog flow.
            await makePayment();
          } else {
            BannerService().showBanner(context, "Please complete the form correctly");
          }
        },
        child: Text(
          'Pay $formattedPrice',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _processPayment() async {
    // numeric comparison using double
    if (_parsedPrice <= 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Invalid Price'),
          content: const Text('Could not process payment due to invalid pricing'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: Colors.amber),
        ),
      );

      await Future.delayed(const Duration(seconds: 2));

      Navigator.pop(context); // close loading

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Payment Successful'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  makePayment();
                },
                child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
              ),
              const SizedBox(height: 20),
              Text(
                '${_formattedPrice} transferred to:\n'
                'JazzCash Account:\n+92 320 7539323\n'
                'Account Holder: Usman Khalid',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> makePayment() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.amber)),
      );

      // Stripe / backend expects amount in the smallest currency unit.
      // For PKR, multiply by 100 (paisa).
      final amountInSmallestUnit = (_parsedPrice * 100).round().toString();

      paymentIntent = await createPaymentIntent(amountInSmallestUnit, 'PKR');

      Navigator.pop(context);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Usman Khalid',
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'PK',
            currencyCode: 'PKR',
            testEnv: true,
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment successful")),
      );

      paymentIntent = null;
    } on StripeException catch (e) {
      Navigator.pop(context);

      // show a banner as in your original code - adapt message as needed
      BannerService().showBanner(context, '${_formattedPrice} transferred to:\n'
          'Meezan Bank:\n14060105801600\n'
          'Account Holder: Usman Khalid');
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Payment failed. Please try again.")),
      );
      print('Error: $e');
    }
  }

  Future<Map<String, dynamic>?> createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'currency': currency,
        'amount': amount,
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer $secret_key',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      print('createPaymentIntent error: $e');
      return null;
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) async {
        await Stripe.instance.confirmPaymentSheetPayment();
      });
      paymentIntent = null;
    } on StripeException catch (e) {
      print(e.toString());
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void dispose() {
    _cardController.dispose();
    _cvvController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }
}

class PaymentMethod {
  final String name;
  final IconData icon;
  final Color color;
  final Map<String, String> fields;

  PaymentMethod({
    required this.name,
    required this.icon,
    required this.color,
    required this.fields,
  });
}
