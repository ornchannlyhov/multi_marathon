class ParticipantDTO {
  final String id;
  final String name;
  final int bibNumber;
    final bool isTracked; // ✅ Add this line

  ParticipantDTO({
    required this.id,
    required this.name,
    required this.bibNumber,
    required this.isTracked, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'bibNumber': bibNumber,
    };
  }

  factory ParticipantDTO.fromMap(Map<String, dynamic> map) {
    return ParticipantDTO(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      bibNumber: map['bibNumber'] ?? 0,
      isTracked: map['isTracked'] ?? false, 
    );
  }
}
