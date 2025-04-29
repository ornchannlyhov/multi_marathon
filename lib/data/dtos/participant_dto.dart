class ParticipantDTO {
  final String name;
  final int bibNumber;

  ParticipantDTO({
    required this.name,
    required this.bibNumber,
  });

  Map<String, dynamic> toMap() {
    return {'name': name, 'bibNumber': bibNumber};
  }

  factory ParticipantDTO.fromMap(Map<String, dynamic> map) {
    return ParticipantDTO(
      name: map['name'] ?? '',
      bibNumber: map['bibNumber'] ?? 0,
    );
  }
}
