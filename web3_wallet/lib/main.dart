import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3_wallet/src/wallet_connector.dart';

void main() {
  runApp(const Web3Wallet());
}

class Web3Wallet extends StatelessWidget {
  const Web3Wallet({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3 Wallet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Web3WalletPage(title: 'Web3 Wallet'),
    );
  }
}

class Web3WalletPage extends StatefulWidget {
  const Web3WalletPage({super.key, required this.title});

  final String title;

  @override
  State<Web3WalletPage> createState() => _Web3WalletPageState();
}

class _Web3WalletPageState extends State<Web3WalletPage> {
  final _connector = WalletConnector();

  TextEditingController? _controller;

  @override
  void initState() {
    super.initState();

    _connector.init(
      onSessionProposal: (id, params) {
        // Show UI dialog to select the accounts and approve or deny the session

        // Accounts should conform to "namespace:chainId:address" format.
        final namespaces = {
          'algorand': Namespace(
            accounts: _connector.accounts
                .map((a) =>
                    'algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDe:${a.publicAddress}')
                .toList(),
            methods: ['algo_signTxn'],
            events: ['accountsChanged', 'chainChanged'],
          ),
        };

        _connector.approveSession(id: id, namespaces: namespaces);
      },
    );

    _controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'wc://',
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              child: const Text('Pair'),
              onPressed: () async {
                final uri = _controller?.text ?? '';

                if (uri.isEmpty) {
                  return;
                }

                await _connector.pair(uri);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}
