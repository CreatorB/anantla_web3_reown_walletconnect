import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:reown_appkit/reown_appkit.dart';
import '../core/config/app_config.dart';

class WalletService extends ChangeNotifier {

  late Web3Client _web3Client;

  bool _isConnected = false;
  bool _isFetchingBalance = false;
  String? _address;
  double _usdcBalance = 0.0;

  bool get isConnected => _isConnected;
  bool get isFetchingBalance => _isFetchingBalance;
  String? get address => _address;
  double get usdcBalance => _usdcBalance;
  Web3Client get web3Client => _web3Client; 

  WalletService() {
    _web3Client = Web3Client(AppConfig.rpcUrl, Client());
  }

  void setConnectionState(bool connected, String? newAddress) {
    _isConnected = connected;
    _address = newAddress;
    if (!connected) {
      _usdcBalance = 0.0; 
    }
    notifyListeners();
  }

  Future<void> fetchBalance() async {
    if (!_isConnected || _address == null) return;

    _isFetchingBalance = true;
    notifyListeners();

    try {
      final contractAddress = EthereumAddress.fromHex(AppConfig.usdcContractAddress);
      final contract = DeployedContract(
        ContractAbi.fromJson(erc20Abi, 'ERC20'), 
        contractAddress,
      );
      final balanceFunction = contract.function('balanceOf');
      final userAddress = EthereumAddress.fromHex(_address!);

      final response = await _web3Client.call(
        contract: contract,
        function: balanceFunction,
        params: [userAddress],
      );
      final balanceInWei = response.first as BigInt;
      final balanceInUsdc = balanceInWei / (BigInt.from(10).pow(AppConfig.usdcDecimals));
      _usdcBalance = balanceInUsdc.toDouble();
    } catch (e) {
      debugPrint("Error mengambil saldo: $e");
      _usdcBalance = 0.0;
    }

    _isFetchingBalance = false;
    notifyListeners();
  }
}

const String erc20Abi = '''
[
  {"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"balance","type":"uint256"}],"type":"function"},
  {"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"type":"function"}
]
''';