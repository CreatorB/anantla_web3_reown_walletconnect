import 'package:anantla/core/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/reown_appkit.dart';
import '../services/wallet_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late ReownAppKitModal _appKitModal;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();

  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitializing) {
      _initializeAppKit();
    }
  }

  Future<void> _initializeAppKit() async {

    _appKitModal = ReownAppKitModal(
      context: context, 
      projectId: AppConfig.walletConnectProjectID,
      metadata: const PairingMetadata(
        name: 'D30 QR Payment App',
        description: 'Aplikasi pembayaran D30',
        url: 'https://www.dspread.com',
        icons: ['https://www.dspread.com/favicon.ico'],
        redirect: Redirect(native: 'anantla://', linkMode: false), 
      ),
      requiredNamespaces: {
        'eip155': RequiredNamespace(
          chains: ['eip155:${AppConfig.chainId}'], 
          methods: ['eth_sendTransaction', 'personal_sign'],
          events: ['chainChanged', 'accountsChanged'],
        ),
      },
    );

    _appKitModal.onModalConnect.subscribe(_onConnect);
    _appKitModal.onModalDisconnect.subscribe(_onDisconnect);

    await _appKitModal.init();

    final walletService = context.read<WalletService>();
    if (_appKitModal.isConnected && _appKitModal.session != null) {
      final address = _appKitModal.session!.getAddress('eip155');
      walletService.setConnectionState(true, address);
      walletService.fetchBalance();
    }

    setState(() => _isInitializing = false);
  }

  void _onConnect(ModalConnect? event) {
    if (event != null && mounted) {
      final address = _appKitModal.session!.getAddress('eip155');
      final walletService = context.read<WalletService>();

      walletService.setConnectionState(true, address);
      walletService.fetchBalance(); 

      Navigator.pop(context); 
    }
  }

  void _onDisconnect(ModalDisconnect? event) {
    if (mounted) {
      context.read<WalletService>().setConnectionState(false, null);
    }
  }

  @override
  void dispose() {

    _appKitModal.onModalConnect.unsubscribe(_onConnect);
    _appKitModal.onModalDisconnect.unsubscribe(_onDisconnect);
    _appKitModal.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<WalletService>(
      builder: (context, wallet, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('D30 Wallet'),
            actions: [
              if (wallet.isConnected)
                IconButton(
                  icon: wallet.isFetchingBalance
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : const Icon(Icons.refresh),
                  onPressed: wallet.isFetchingBalance ? null : wallet.fetchBalance,
                ),
              if (wallet.isConnected)
                IconButton(
                  icon: const Icon(Icons.logout),

                  onPressed: () async {
                    await _appKitModal.disconnect(); 
                  },
                ),
            ],
          ),
          body: Center(
            child: wallet.isConnected
                ? _buildWalletInfo(context, wallet)
                : _buildConnectButton(context, wallet), 
          ),
        );
      },
    );
  }

  Widget _buildWalletInfo(BuildContext context, WalletService wallet) {

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

         children: [
          const Text('Wallet Terhubung:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text(
            wallet.address ?? 'N/A',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          const Text('Saldo Anda:', style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          if (wallet.isFetchingBalance && wallet.usdcBalance == 0.0)
            const CircularProgressIndicator()
          else
            Text(
              '${wallet.usdcBalance.toStringAsFixed(2)} USDC',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Pindai QR untuk Membayar'),
            onPressed: () {

            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context, WalletService wallet) {
    if (_isInitializing) {
      return const CircularProgressIndicator(); 
    }

    return ElevatedButton(
      child: const Text('Connect Wallet'),
      onPressed: () {

        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (sheetContext) {

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: AppKitModalConnectButton(
                appKit: _appKitModal,
              ),
            );
          },
        );
      },
    );
  }
}