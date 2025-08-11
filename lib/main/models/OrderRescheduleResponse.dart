class OrderRescheduleResponse {
  final bool status;
  final String message;

  OrderRescheduleResponse({required this.status, required this.message});

  // Factory method to create an instance from JSON
  factory OrderRescheduleResponse.fromJson(Map<String, dynamic> json) {
    return OrderRescheduleResponse(
      status: json['status'],
      message: json['message'],
    );
  }

  // Method to convert the object back to JSON (optional)
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
    };
  }
}