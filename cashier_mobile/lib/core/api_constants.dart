//Stores all API URLs in one place
class ApiConstants {
  // Base URL — all requests start from here
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  // ── Auth ──────────────────────────────────
  static const String login = '/auth/login'; // POST → get token
  static const String logout = '/auth/logout'; // POST → delete token

  // ── Cashier ───────────────────────────────
  static const String products = '/cashier/products'; // GET → product list
  static const String categories =
      '/cashier/categories'; // GET → category pills

  // ── Orders (coming soon) ──────────────────
  static const String orders = '/cashier/orders'; // POST → create order
}
