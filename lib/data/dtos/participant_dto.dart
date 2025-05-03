class ParticipantDTO {
  final String id;
  final String name;
  final int bibNumber;

  ParticipantDTO({
    required this.id,
    required this.name,
    required this.bibNumber,
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
    );
  }
}
