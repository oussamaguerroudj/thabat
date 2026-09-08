/// App-wide configuration. `apiBaseUrl` is read from a compile-time define
/// (`--dart-define=API_BASE_URL=...`) rather than hardcoded, mirroring the
/// backend's "never hardcode config" rule (`app/core/config.py`). The
/// fallback below is for local development against the Phase 1 backend
/// running via its `docker-compose.yml` on the same machine.
abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8000',
  );
}
