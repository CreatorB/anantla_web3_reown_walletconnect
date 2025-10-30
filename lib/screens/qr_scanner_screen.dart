import 'package:flutter/material.dart';
import 'dart:async';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();

    _startMockScan();
  }

  void _startMockScan() {
    setState(() => _isScanning = true);

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isScanning = false);

      final Map<String, dynamic> mockQrData = {
        'merchant': 'Warung Kopi Jaya',
        'amount': 15000.0,
        'merchantId': 'WKJ-001',
      };

      Navigator.pushReplacementNamed(
        context,
        '/confirm_payment',
        arguments: mockQrData,
      );
    });
  }

  void _simulateInvalidScan() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('QR Code tidak valid atau tidak dikenal.'),
        backgroundColor: Colors.red,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isScanning 
              ? const CircularProgressIndicator()
              : const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 20),
            Text(
              _isScanning ? 'Mengarahkan kamera...' : 'QR Ditemukan!',
              style: const TextStyle(fontSize: 18),
            ),

            Container(
              height: 250,
              width: 250,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            TextButton(
              onPressed: _simulateInvalidScan,
              child: const Text('Simulasikan QR Gagal'),
            ),
          ],
        ),
      ),
    );
  }
}