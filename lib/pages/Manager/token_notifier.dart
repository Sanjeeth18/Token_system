import 'package:flutter/foundation.dart';
import 'package:Tokens/database/firebase.dart';

class TokenNotifier extends ChangeNotifier {
  List<int> _tokens = [0, 0, 0, 0]; 

  List<int> get tokens => _tokens;

  void setTokens(List<int> newTokens) {
    _tokens = newTokens;
    notifyListeners();
  }

  Future<void> refreshTokens() async {
    _tokens = await Firestore().readTokens();
    notifyListeners();
  }
}
