import 'dart:html' as html;

class UserSession {
  // Store user login session
  String storeUserSession(String userId) {
    return html.window.localStorage['userId'] = userId;
  }

// Retrieve user login session
  String? getUserSession() {
    return html.window.localStorage['userId'];
  }

// Clear user login session
  void clearUserSession() {
    html.window.localStorage.remove('userId');
  }
}
