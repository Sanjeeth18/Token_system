import 'package:cloud_firestore/cloud_firestore.dart';

/// Token count statistics for the manager/admin dashboard.
class TokenCounts {
  final int nonVeg;
  final int veg;
  final int nonVegPurchased;
  final int vegPurchased;

  const TokenCounts({
    this.nonVeg = 0,
    this.veg = 0,
    this.nonVegPurchased = 0,
    this.vegPurchased = 0,
  });

  int get totalNonVeg => nonVeg + nonVegPurchased;
  int get totalVeg => veg + vegPurchased;

  bool get isVegAvailable => veg > 0;
  bool get isNonVegAvailable => nonVeg > 0;
  bool get hasActiveTokens => nonVeg > 0 || veg > 0;

  TokenCounts copyWith({
    int? nonVeg,
    int? veg,
    int? nonVegPurchased,
    int? vegPurchased,
  }) {
    return TokenCounts(
      nonVeg: nonVeg ?? this.nonVeg,
      veg: veg ?? this.veg,
      nonVegPurchased: nonVegPurchased ?? this.nonVegPurchased,
      vegPurchased: vegPurchased ?? this.vegPurchased,
    );
  }

  factory TokenCounts.fromMap(Map<String, dynamic> data) {
    return TokenCounts(
      nonVeg: (data['non-veg'] as num?)?.toInt() ?? 0,
      veg: (data['veg'] as num?)?.toInt() ?? 0,
      nonVegPurchased: (data['non-veg_purchased'] as num?)?.toInt() ?? 0,
      vegPurchased: (data['veg_purchased'] as num?)?.toInt() ?? 0,
    );
  }

  static const TokenCounts empty = TokenCounts();

  @override
  String toString() =>
      'TokenCounts(veg: $veg, nonVeg: $nonVeg, vegP: $vegPurchased, nonVegP: $nonVegPurchased)';
}

/// Token holdings for a student.
class StudentTokens {
  final int nonVeg;
  final int veg;
  final int eggs;

  const StudentTokens({this.nonVeg = 0, this.veg = 0, this.eggs = 0});

  bool get hasAnyToken => nonVeg > 0 || veg > 0 || eggs > 0;

  StudentTokens copyWith({int? nonVeg, int? veg, int? eggs}) {
    return StudentTokens(
      nonVeg: nonVeg ?? this.nonVeg,
      veg: veg ?? this.veg,
      eggs: eggs ?? this.eggs,
    );
  }

  factory StudentTokens.fromMap(Map<String, dynamic> data) {
    return StudentTokens(
      nonVeg: (data['non-veg'] as num?)?.toInt() ?? 0,
      veg: (data['veg'] as num?)?.toInt() ?? 0,
      eggs: (data['eggs'] as num?)?.toInt() ?? 0,
    );
  }

  /// Convert to the legacy [List<int>] format: [nonVeg, veg, eggs].
  List<int> toList() => [nonVeg, veg, eggs];

  static const StudentTokens empty = StudentTokens();

  @override
  String toString() =>
      'StudentTokens(veg: $veg, nonVeg: $nonVeg, eggs: $eggs)';
}

/// A pending token purchase selection made by a student before confirming.
class TokenSelection {
  final bool wantsNonVeg;
  final bool wantsVeg;
  final int eggCount;

  const TokenSelection({
    this.wantsNonVeg = false,
    this.wantsVeg = false,
    this.eggCount = 0,
  });

  bool get hasSelection => wantsNonVeg || wantsVeg || eggCount > 0;

  TokenSelection copyWith({
    bool? wantsNonVeg,
    bool? wantsVeg,
    int? eggCount,
  }) {
    return TokenSelection(
      wantsNonVeg: wantsNonVeg ?? this.wantsNonVeg,
      wantsVeg: wantsVeg ?? this.wantsVeg,
      eggCount: eggCount ?? this.eggCount,
    );
  }

  /// Convert to the legacy [List<int>] format: [nonVeg, veg, eggs].
  List<int> toList() => [wantsNonVeg ? 1 : 0, wantsVeg ? 1 : 0, eggCount];
}

/// Record of a token purchase transaction.
class TokenTransactionModel {
  final String id;
  final String rollNumber;
  final String category;
  final int count;
  final String date;
  final String time;
  final DateTime timestamp;

  const TokenTransactionModel({
    required this.id,
    required this.rollNumber,
    required this.category,
    required this.count,
    required this.date,
    required this.time,
    required this.timestamp,
  });

  factory TokenTransactionModel.fromFirestore(dynamic doc) {
    final data = (doc.data() as Map<String, dynamic>?) ?? {};
    final ts = data['timestamp'];
    DateTime parsedTime = DateTime.now();
    if (ts is Timestamp) {
      parsedTime = ts.toDate();
    }
    return TokenTransactionModel(
      id: doc.id as String,
      rollNumber: data['rollNumber'] as String? ?? '',
      category: data['category'] as String? ?? 'veg',
      count: (data['count'] as num?)?.toInt() ?? 1,
      date: data['date'] as String? ?? '',
      time: data['time'] as String? ?? '',
      timestamp: parsedTime,
    );
  }
}

