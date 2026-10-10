// Tipe Kategori: pemasukan atau pengeluaran sesuai SPEC.md
enum CategoryType {
  income,
  expense,
}

// Model Category sesuai SPEC.md bagian 2.B dan Milestone UI-7
class Category {
  final String id;
  final String name;
  final CategoryType type;
  final bool isArchived;
  final String? iconKey;
  final String? colorKey;

  const Category({
    required this.id,
    required this.name,
    required this.type,
    this.isArchived = false,
    this.iconKey,
    this.colorKey,
  });

  Category copyWith({
    String? id,
    String? name,
    CategoryType? type,
    bool? isArchived,
    String? iconKey,
    String? colorKey,
    bool clearIconKey = false,
    bool clearColorKey = false,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isArchived: isArchived ?? this.isArchived,
      iconKey: clearIconKey ? null : (iconKey ?? this.iconKey),
      colorKey: clearColorKey ? null : (colorKey ?? this.colorKey),
    );
  }
}
