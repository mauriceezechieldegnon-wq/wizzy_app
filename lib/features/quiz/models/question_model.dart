class Question {
  final String id;
  final String label;
  final List<String> options;
  final String correctAnswer;
  final int points;

  Question({
    required this.id,
    required this.label,
    required this.options,
    required this.correctAnswer,
    required this.points,
  });

  factory Question.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Question(
      id: documentId,
      label: data['label'] ?? '',
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
      points: data['points'] ?? 5,
    );
  }
}
