class DirectionsResponse {
  List<String> destinationAddresses;
  List<String> originAddresses;
  List<Row> rows;
  String status;

  DirectionsResponse({
    required this.destinationAddresses,
    required this.originAddresses,
    required this.rows,
    required this.status,
  });

  factory DirectionsResponse.fromJson(Map<String, dynamic> json) {
    return DirectionsResponse(
      destinationAddresses: List<String>.from(json['destination_addresses']),
      originAddresses: List<String>.from(json['origin_addresses']),
      rows: List<Row>.from(json['rows'].map((x) => Row.fromJson(x))),
      status: json['status'],
    );
  }
}

class Row {
  List<Element> elements;

  Row({required this.elements});

  factory Row.fromJson(Map<String, dynamic> json) {
    return Row(
      elements: List<Element>.from(json['elements'].map((x) => Element.fromJson(x))),
    );
  }
}

class Element {
  Distance distance;
  Duration duration;
  String status;

  Element({required this.distance, required this.duration, required this.status});

  factory Element.fromJson(Map<String, dynamic> json) {
    return Element(
      distance: Distance.fromJson(json['distance']),
      duration: Duration.fromJson(json['duration']),
      status: json['status'],
    );
  }
}

class Distance {
  String text;
  int value;

  Distance({required this.text, required this.value});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
      text: json['text'],
      value: json['value'],
    );
  }
}

class Duration {
  String text;
  int value;

  Duration({required this.text, required this.value});

  factory Duration.fromJson(Map<String, dynamic> json) {
    return Duration(
      text: json['text'],
      value: json['value'],
    );
  }
}
