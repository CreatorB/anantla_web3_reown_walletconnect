import 'dart:async';

import 'package:flutter/material.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {

  bool _isLoading = false;

  void _onConfirmPayment() {
    setState(() => _isLoading = true);

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pembayaran Berhasil!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context); 
    });
  }

  @override
  Widget build(BuildContext context) {

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final String merchant = args['merchant'];
    final double amount = args['amount'];

    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Pembayaran')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Memproses Transaksi...'),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.store, size: 60, color: Colors.blue),
                const SizedBox(height: 16),

                Text(
                  merchant,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Anda akan membayar sejumlah:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 16),

                Text(
                  'Rp ${amount.toStringAsFixed(0)}', 
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                const Spacer(),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _onConfirmPayment,
                  child: const Text('KONFIRMASI & BAYAR'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {

                    Navigator.pop(context);
                  },
                  child: const Text('BATAL'),
                ),
              ],
            ),
      ),
    );
  }
}