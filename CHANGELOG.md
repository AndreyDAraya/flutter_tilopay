## 1.0.0

Initial stable release of the official Tilopay Flutter SDK.

### Features

- `TilopayClient` — full API client with all Tilopay endpoints
- **Redirect flow** — `login()` + `processPayment()` with hosted checkout form
- **Native flow (FAC)** — `loginSdk()` + `processPaymentFac()` with card token
- **3D Secure** — automatic handling of `htmlFormData` challenge (type `100`)
- **TokenEx retry** — `processPaymentTokenex()` with up to 3 automatic retries
- **Recurring payments** — `processRecurrentPayment()` for subscriptions
- **Modifications** — `processModification()` for capture, refund and reversal
- **Card tokenization** — `processTokenize()` with built-in WebView flow
- **Card removal** — `removeCard()` to delete saved tokens
- **HMAC-SHA256 verification** — `TilopayHashVerifier` for webhooks and redirect callbacks
- `TilopayTokenizeWebview` — customizable WebView widget for tokenization
- Full exception hierarchy: `TilopayAuthException`, `TilopayLicenseException`,
  `TilopayNetworkException`, `TilopayHashVerificationException`, `TilopayIntegrationException`
- Sandbox config via `TilopayConfig.sandbox`
- Debug logging via `TilopayConfig(debugLog: true)`
