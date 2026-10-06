// Tipe Kategori: pemasukan atau pengeluaran sesuai SPEC.md
enum CategoryType {
  income,
  expense,
}

// Model Category sesuai SPEC.md bagian 2.B
class Category {
  final String id;
  final String name;
  final CategoryType type;

  const Category({
    required this.id,
    required this.name,
    required this.type,
  });
}
