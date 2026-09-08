import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Streams `true` while the device has some network interface up
/// (Wi-Fi/mobile). This is reachability of *a* network, not proof the
/// backend itself is reachable — `NetworkFailure` (thrown from the API
/// client on an actual failed request) is still the source of truth for
/// "the backend call failed." This provider exists so the UI can show a
/// persistent offline banner proactively, before the user even attempts
/// an action that would hit the network.
final connectivityStatusProvider = StreamProvider<bool>((ref) {
  return Connectivity().onConnectivityChanged.map(
        (results) => !results.contains(ConnectivityResult.none),
      );
});
