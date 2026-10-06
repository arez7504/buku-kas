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
  final bool isArchived;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.isArchived = false,
  });

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    bool? isArchived,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isArchived: isArchived ?? this.isArchived,
    );
  }
}
