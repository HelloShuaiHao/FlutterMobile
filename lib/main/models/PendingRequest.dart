import 'dart:convert';

enum RequestType {
  pickup,
  delivery,
  proofOfDelivery,
  taskStatus,
}

enum RequestStatus {
  pending,
  retrying,
  failed,
}

class PendingRequest {
  final String id;
  final RequestType type;
  final String taskId;
  final String taskName;
  final Map<String, dynamic> requestData;
  final DateTime createdAt;
  final int retryCount;
  final RequestStatus status;
  final String? errorMessage;
  final String? photoPath;
  final String? signaturePath;

  PendingRequest({
    required this.id,
    required this.type,
    required this.taskId,
    required this.taskName,
    required this.requestData,
    required this.createdAt,
    this.retryCount = 0,
    this.status = RequestStatus.pending,
    this.errorMessage,
    this.photoPath,
    this.signaturePath,
  });

  factory PendingRequest.fromJson(Map<String, dynamic> json) {
    return PendingRequest(
      id: json['id'] as String,
      type: RequestType.values[json['type'] as int],
      taskId: json['taskId'] as String,
      taskName: json['taskName'] as String,
      requestData: Map<String, dynamic>.from(json['requestData'] as Map),
      createdAt: DateTime.parse(json['createdAt'] as String),
      retryCount: json['retryCount'] as int? ?? 0,
      status: RequestStatus.values[json['status'] as int? ?? 0],
      errorMessage: json['errorMessage'] as String?,
      photoPath: json['photoPath'] as String?,
      signaturePath: json['signaturePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.index,
      'taskId': taskId,
      'taskName': taskName,
      'requestData': requestData,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
      'status': status.index,
      'errorMessage': errorMessage,
      'photoPath': photoPath,
      'signaturePath': signaturePath,
    };
  }

  PendingRequest copyWith({
    String? id,
    RequestType? type,
    String? taskId,
    String? taskName,
    Map<String, dynamic>? requestData,
    DateTime? createdAt,
    int? retryCount,
    RequestStatus? status,
    String? errorMessage,
    String? photoPath,
    String? signaturePath,
  }) {
    return PendingRequest(
      id: id ?? this.id,
      type: type ?? this.type,
      taskId: taskId ?? this.taskId,
      taskName: taskName ?? this.taskName,
      requestData: requestData ?? this.requestData,
      createdAt: createdAt ?? this.createdAt,
      retryCount: retryCount ?? this.retryCount,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      photoPath: photoPath ?? this.photoPath,
      signaturePath: signaturePath ?? this.signaturePath,
    );
  }

  String get typeLabel {
    switch (type) {
      case RequestType.pickup:
        return 'Pickup';
      case RequestType.delivery:
        return 'Delivery';
      case RequestType.proofOfDelivery:
        return 'Proof of Delivery';
      case RequestType.taskStatus:
        return 'Task Status';
    }
  }
}
