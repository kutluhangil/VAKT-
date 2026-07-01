/// A user-created named list of tip ids. Offline, Hive-backed.
class TipCollection {
  const TipCollection({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.tipIds,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final List<String> tipIds;

  /// Serialized for Hive. Omits [id] — the map is stored under the id key.
  Map<String, dynamic> toMap() => {
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'tipIds': tipIds,
      };

  factory TipCollection.fromMap(String id, Map data) => TipCollection(
        id: id,
        name: (data['name'] ?? '') as String,
        createdAt: DateTime.tryParse((data['createdAt'] ?? '') as String) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        tipIds: ((data['tipIds'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList(),
      );

  TipCollection copyWith({String? name, List<String>? tipIds}) => TipCollection(
        id: id,
        name: name ?? this.name,
        createdAt: createdAt,
        tipIds: tipIds ?? this.tipIds,
      );
}
