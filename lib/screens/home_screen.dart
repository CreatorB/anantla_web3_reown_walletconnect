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
            title: const Text('My Dashboard'),

            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Halaman profil mockup')),
                  );
                },
              ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/qr_scanner');
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.qr_code_scanner, color: Colors.white),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 6.0,
            child: Container(height: 60.0), 
          ),

          body: _buildDashboardBody(context, wallet),
        );
      },
    );
  }

  Widget _buildDashboardBody(BuildContext context, WalletService wallet) {
    if (_isInitializing) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [

        _buildBalanceCard(context, wallet),
        const SizedBox(height: 24),

        const Text('Grafik Saldo (Mockup)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(Icons.show_chart, color: Colors.grey, size: 50),
          ),
        ),
        const SizedBox(height: 24),

        const Text('Riwayat Transaksi (Mockup)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildMockHistoryTile(Icons.shopping_bag, 'Warung Kopi Jaya', '- Rp 15.000'),
        _buildMockHistoryTile(Icons.fastfood, 'Sate Padang', '- Rp 25.000'),
        _buildMockHistoryTile(Icons.receipt, 'Token Listrik', '- Rp 50.000'),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletService wallet) {
    return Card(
      color: Colors.grey[850],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Total Saldo (USDC)', style: TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),

            if (wallet.isConnected)
              Text(
                '${wallet.usdcBalance.toStringAsFixed(2)} USDC',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              )
            else

              const Text(
                '125.50 USDC', 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
              ),

            const SizedBox(height: 20),

            wallet.isConnected
              ? Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        wallet.address ?? 'N/A',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, size: 20, color: Colors.red),
                      onPressed: () async => await _appKitModal.disconnect(),
                    )
                  ],
                )
              : _buildConnectButton(context, wallet), 
          ],
        ),
      ),
    );
  }

  Widget _buildConnectButton(BuildContext context, WalletService wallet) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
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
      child: const Text('Connect Wallet to See Real Balance'),
    );
  }

  Widget _buildMockHistoryTile(IconData icon, String title, String amount) {
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title),
        trailing: Text(amount, style: const TextStyle(color: Colors.red)),
      ),
    );
  }
}