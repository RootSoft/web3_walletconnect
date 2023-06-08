import 'package:algorand_dart/algorand_dart.dart';
import 'package:flutter/material.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3_dapp/src/web3_connector.dart';

void main() {
  runApp(const Web3App());
}

class Web3App extends StatelessWidget {
  const Web3App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web3 dApp',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Web3AppPage(title: 'Web3 dApp'),
    );
  }
}

class Web3AppPage extends StatefulWidget {
  const Web3AppPage({super.key, required this.title});

  final String title;

  @override
  State<Web3AppPage> createState() => _Web3AppPageState();
}

class _Web3AppPageState extends State<Web3AppPage> {
  final _connector = Web3Connector();
  final _algorand = Algorand();

  String? displayUri;
  SessionData? _session;

  @override
  void initState() {
    super.initState();

    _connector.init();
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
            TextButton(
              child: const Text('Generate URI'),
              onPressed: () async {
                final session = await _connector.connect(
                  onDisplayUri: (uri) async {
                    setState(() {
                      displayUri = uri;
                    });
                  },
                );

                if (session == null) {
                  return;
                }

                setState(() {
                  _session = session;
                });
              },
            ),
            SelectableText(displayUri ?? ''),
            TextButton(
              child: const Text('Sign transaction'),
              onPressed: _session != null
                  ? () async {
                      final topic = _session?.topic;
                      if (topic == null) {
                        return;
                      }

                      final accounts = _session
                              ?.namespaces['algorand']?.accounts
                              .map((a) => Address.fromAlgorandAddress(
                                  a.split(':').last))
                              .toList() ??
                          [];

                      final tx = await _algorand.createPaymentTransaction(
                        sender: accounts.first,
                        receiver: accounts.first,
                        amount: BigInt.zero,
                      );

                      print(accounts);
                      final response = _connector.signTransaction(
                        topic: topic,
                        transaction: tx.toBytes(),
                      );
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
