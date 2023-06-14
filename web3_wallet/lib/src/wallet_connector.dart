import 'package:algorand_dart/algorand_dart.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:web3_wallet/src/secure_store.dart';

typedef OnSessionProposal = void Function(int id, ProposalData params);

class WalletConnector {
  static const namespace = 'algorand';
  static const chainId = 'algorand:SGO1GKSzyE7IEPItTxCByw9x8FmnrCDe';

  final accounts = <Account>[];

  late final Web3Wallet wallet;

  Future<void> init({
    OnSessionProposal? onSessionProposal,
  }) async {
    wallet = await Web3Wallet.createInstance(
      projectId: 'ad705502202918e3b0bae0cf817fb38e',
      metadata: const PairingMetadata(
        name: 'Defly Wallet',
        description: 'A wallet that can be requested to sign transactions',
        url: 'https://walletconnect.com',
        icons: ['https://avatars.githubusercontent.com/u/37784886'],
      ),
      storage: Web3Storage(),
    );

    wallet.onSessionProposal.subscribe((args) async {
      if (args == null) {
        return;
      }

      onSessionProposal?.call(args.id, args.params);
    });

    wallet.onAuthRequest.subscribe((args) {
      print(args);
    });

    wallet.registerRequestHandler(
      chainId: chainId,
      method: 'algo_signTxn',
      handler: _handleSignTransaction,
    );

    // Load the Algorand accounts
    final account = await Account.random();
    accounts.add(account);
  }

  Future<void> pair(String uri) async {
    await wallet.pair(uri: Uri.parse(uri));
  }

  Future<void> approveSession({
    required int id,
    required Map<String, Namespace> namespaces,
  }) async {
    await wallet.approveSession(id: id, namespaces: namespaces);
  }

  Future<String> _handleSignTransaction(topic, parameters) async {
    // Handling Steps
    // 1. Parse the request, if there are any errors thrown while trying to parse
    // the client will automatically respond to the requester with a
    // JsonRpcError.invalidParams error
    final parsedResponse = parameters;

    // 2. Show a modal to the user with the signature info: Allow approval/rejection
    bool userApproved = true;

    // 3. Respond to the dApp based on user response
    if (userApproved) {
      return 'Signed!';
    } else {
      throw Errors.getSdkError(Errors.USER_REJECTED_SIGN);
    }
  }
}
