import 'package:ata_new_app/models/payment.dart';
import 'package:ata_new_app/services/payment_service.dart';
import 'package:ata_new_app/services/video_service.dart';
import 'package:flutter/material.dart';
import 'package:ata_new_app/providers/cart_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class VideoCheckoutPage extends StatefulWidget {
  @override
  _VideoCheckoutPageState createState() => _VideoCheckoutPageState();
}

class _VideoCheckoutPageState extends State<VideoCheckoutPage> {
  Payment? payment;
  bool isLoadingPayment = true;
  bool isLoadingPaymentError = false;
  String paymentQRCodeImageUrl = '';

  @override
  void initState() {
    super.initState();
    getPayment();
  }

  Future<void> getPayment() async {
    try {
      final fetchedPayment = await PaymentService.fetchPayment();
      setState(() {
        payment = fetchedPayment;
        isLoadingPayment = false;
      });
    } catch (error) {
      print('Error fetching payment info: $error');
      setState(() {
        isLoadingPayment = false;
        isLoadingPaymentError = true;
      });
    }
  }

  Future<void> _openLinkPayment() async {
    final Uri paymentUrl = Uri.parse(payment?.url ?? '');
    if (await canLaunchUrl(paymentUrl)) {
      await launchUrl(paymentUrl);
    } else {
      throw 'Could not launch $paymentUrl';
    }
  }

  bool isSubmitting = false;
  XFile? _transactionImage;

  final ImagePicker _picker = ImagePicker();

  // Function to simulate transaction upload
  Future<void> submitTransaction() async {
    if (_transactionImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please upload transaction image.'),
          backgroundColor: Colors.red.shade400, // Red background color
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await VideoService.orderPlaylistVideo(
          context: context, image: _transactionImage!);
      // Handle success (e.g., show success message or navigate)
    } catch (error) {
      print('Error submitting transaction: $error');
      // Handle error (e.g., show error message)
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  // Function to pick image from gallery or camera
  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _transactionImage = XFile(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final totalPrice = cartProvider.totalPrice().toStringAsFixed(2);

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Theme.of(context).colorScheme.primary,
        title: Text('Checkout'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('\$$totalPrice',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade400)),
                ],
              ),
              SizedBox(height: 20),

              // Payment QR Code Image
              isLoadingPayment
                  ? Center(child: CircularProgressIndicator())
                  : GestureDetector(
                      onTap: _openLinkPayment,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              payment?.image ?? '',
                              width: 250,
                              fit: BoxFit.contain,
                              errorBuilder: (BuildContext context, Object error,
                                  StackTrace? stackTrace) {
                                return Column(
                                  children: [
                                    Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 50,
                                      color: Colors.grey.shade400,
                                    ),
                                    Text('Loading Image Error!')
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 20),

              // Payment Instructions Link
              Center(
                child: GestureDetector(
                  onTap: _openLinkPayment,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Click Here to Pay',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_outward_rounded,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 50),

              // Image upload section
              Text(
                'Upload Payment Transaction Image:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: _transactionImage == null
                        ? Border.all(color: Colors.grey, width: 0.5)
                        : Border.all(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(10),
                    image: _transactionImage != null
                        ? DecorationImage(
                            image: FileImage(File(_transactionImage!.path)),
                            fit: BoxFit.contain,
                          )
                        : null,
                  ),
                  child: _transactionImage == null
                      ? Center(
                          child: Icon(
                            Icons.camera_alt,
                            size: 50,
                            color: Colors.grey.shade400,
                          ),
                        )
                      : null,
                ),
              ),
              SizedBox(height: 20),

              // Submit Button
              if (isSubmitting)
                Center(child: CircularProgressIndicator())
              else
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: submitTransaction,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Submit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
