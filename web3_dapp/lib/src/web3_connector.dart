import 'dart:convert';
import 'dart:typed_data';

import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';

typedef OnDisplayUri = Future<void> Function(String uri);

class Web3Connector {
  late Web3App _client;

  Future<void> init() async {
    _client = await Web3App.createInstance(
      projectId: 'cb401e4bc87845ed4760de4b168e6059',
      metadata: const PairingMetadata(
        name: 'Defly dApp',
        description: 'A dapp that can request that transactions be signed',
        url: 'https://walletconnect.com',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
      ),
    );
  }

  Future<SessionData?> connect({OnDisplayUri? onDisplayUri}) async {
    final response = await _client.connect(
      requiredNamespaces: {
        'algorand': const RequiredNamespace(
          chains: ['algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDe'],
          methods: ['algo_signTxn'],
          events: [],
        ),
      },
    );

    final uri = response.uri?.toString();

    if (uri == null) {
      return null;
    }

    await onDisplayUri?.call(uri);

    return response.session.future;
  }

  Future<void> signTransaction({
    required String topic,
    required Uint8List transaction,
    String? message,
  }) async {
    final signature = await _client.request(
      topic: topic,
      chainId: 'algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDe',
      request: SessionRequestParams(
        method: 'algo_signTxn',
        params: [
          [
            {
              'txn': base64Encode(transaction),
              'message': message ?? '',
            }
          ],
        ],
      ),
    );

    print(signature);
  }
}
