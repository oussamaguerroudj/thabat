# ADR-011: Flutter Foundation — state management, routing, networking

**Status:** Accepted (Phase 5)

## Context

Phase 5 needs to fix: state management, routing, and the API client/interceptor pattern, before any real feature screen is built on top (Phase 6+). Getting these three wrong is expensive to unwind later, so each gets a real alternatives comparison, same discipline as the backend ADRs.

## Decisions

### State management: Riverpod
**Alternatives considered:** Bloc (more ceremony per feature — event/state classes for everything, heavier for a team this size), plain `Provider` (older, and `ChangeNotifier`-based state doesn't fit the router's need to read auth state from outside the widget tree cleanly).
**Decision:** `flutter_riverpod`. Providers are plain Dart objects, testable without pumping a widget tree, and — critically for the auth guard — readable from `go_router`'s `redirect` callback via `ref.read`, without threading a `BuildContext` through routing logic.

### Routing: go_router
**Alternatives considered:** raw `Navigator` 2.0 (correct but verbose — reimplementing what go_router already does), `auto_route` (codegen adds a build step for marginal gain over go_router's declarative API at this project's route count).
**Decision:** `go_router`, with one `GoRoute` per screen (see `core/router/app_router.dart`) and a single `redirect` callback implementing the auth guard, rather than scattering auth checks across individual screens.

### Networking: Dio + a dedicated auth interceptor
**Alternatives considered:** the bare `http` package (no interceptor chain — the access-token-attach + 401-refresh-and-retry flow would have to be duplicated at every call site instead of centralized once).
**Decision:** `dio`, with `AuthInterceptor` as the only place that touches tokens on the request/response path. It mirrors the backend's actual `/auth/refresh` contract from Phase 3 exactly: on a 401, it calls `/auth/refresh` with the stored refresh token, and on success retries the original request once with the new access token — matching the backend's real rotate-on-use behavior, not a generic guess at what a refresh flow "usually" looks like.

### Typography: `google_fonts` package, not bundled `.ttf` files
Phase 4's prototype pulls Cairo and Aref Ruqaa from Google Fonts' CDN, and no font binaries were provided as project assets. `google_fonts` is the pragmatic match for that today. **Consequence, stated plainly:** this makes first-render typography dependent on a network fetch (with local caching after that), which is not ideal for an offline-first religious app. `core/theme/app_typography.dart` isolates every place a font is chosen, specifically so swapping to bundled asset fonts later is a change in one file, not a hunt across the codebase.

## Consequence

Every feature screen built from Phase 6 onward depends on: `core/network/api_client.dart` for HTTP calls (never instantiate `Dio` directly in a feature), `core/router/app_router.dart` for navigation (never `Navigator.push` a raw route for a named screen), and `core/theme/` for all colors/spacing/radii (never a hardcoded hex value in a feature widget).
