/// Mirrors backend `app/modules/ai_orchestration/schemas.py::RetrievedEvidence`.
class VerificationEvidence {
  const VerificationEvidence({
    required this.chunkId,
    required this.sourceName,
    required this.sourceType,
    required this.content,
    required this.similarityScore,
    this.sourceUrl,
  });

  final String chunkId;
  final String sourceName;
  final String sourceType;
  final String content;
  final double similarityScore;
  final String? sourceUrl;

  factory VerificationEvidence.fromJson(Map<String, dynamic> json) {
    return VerificationEvidence(
      chunkId: json['chunk_id'] as String,
      sourceName: json['source_name'] as String,
      sourceType: json['source_type'] as String,
      content: json['content'] as String,
      similarityScore: (json['similarity_score'] as num).toDouble(),
      sourceUrl: json['source_url'] as String?,
    );
  }
}

/// Mirrors backend `app/modules/verification/models.py::VerificationStatus`
/// exactly — four states, never a freeform string. `unknown` exists only
/// as a defensive fallback if the backend ever adds a status value this
/// client doesn't know about yet; it is never sent, only possibly received.
enum VerificationStatus {
  verified,
  needsReview,
  unreliable,
  inconclusive,
  unknown;

  static VerificationStatus fromWire(String value) {
    switch (value) {
      case 'verified':
        return VerificationStatus.verified;
      case 'needs_review':
        return VerificationStatus.needsReview;
      case 'unreliable':
        return VerificationStatus.unreliable;
      case 'inconclusive':
        return VerificationStatus.inconclusive;
      default:
        return VerificationStatus.unknown;
    }
  }
}

/// Mirrors backend `app/modules/verification/schemas.py::VerificationResponse`.
class VerificationResult {
  const VerificationResult({
    required this.id,
    required this.status,
    required this.explanation,
    required this.evidence,
    required this.disclaimer,
    required this.createdAt,
  });

  final String id;
  final VerificationStatus status;
  final String explanation;
  final List<VerificationEvidence> evidence;
  final String disclaimer;
  final DateTime createdAt;

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      id: json['id'] as String,
      status: VerificationStatus.fromWire(json['status'] as String),
      explanation: json['explanation'] as String,
      evidence: (json['evidence'] as List)
          .map((e) => VerificationEvidence.fromJson(e as Map<String, dynamic>))
          .toList(),
      disclaimer: json['disclaimer'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
