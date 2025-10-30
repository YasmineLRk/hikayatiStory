class Section {
  final String id;
  final String heading;
  final String text;
  final String? imageUrl; // GitHub link per phase 1
  final String? audioUrl;

  Section({
    required this.id,
    required this.heading,
    required this.text,
    this.imageUrl,
    this.audioUrl,
  });

  Map<String, dynamic> toMap(String storyId, int order) {
    return {
      'id': id,
      'storyId': storyId,
      'heading': heading,
      'text': text,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'orderIndex': order,
    };
  }

  factory Section.fromMap(Map<String, dynamic> m) {
    return Section(
      id: m['id'],
      heading: m['heading'],
      text: m['text'],
      imageUrl: m['imageUrl'],
      audioUrl: m['audioUrl'],
    );
  }
}
