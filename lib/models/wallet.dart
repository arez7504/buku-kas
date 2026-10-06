// Model Wallet sesuai SPEC.md bagian 2.A
class Wallet {
  final String id;
  final String name;
  final int initialBalance;

  const Wallet({
    required this.id,
    required this.name,
    required this.initialBalance,
  });
}
