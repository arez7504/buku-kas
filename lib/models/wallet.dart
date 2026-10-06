// Model Wallet sesuai SPEC.md bagian 2.A
class Wallet {
  final String id;
  final String name;
  final int initialBalance;
  final bool isArchived;

  const Wallet({
    required this.id,
    required this.name,
    required this.initialBalance,
    this.isArchived = false,
  });

  Wallet copyWith({
    String? id,
    String? name,
    int? initialBalance,
    bool? isArchived,
  }) {
    return Wallet(
      id: id ?? this.id,
      name: name ?? this.name,
      initialBalance: initialBalance ?? this.initialBalance,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
