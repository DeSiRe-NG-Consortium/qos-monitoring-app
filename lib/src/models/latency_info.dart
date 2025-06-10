class LatencyInfo {
  String? latency;
  String? jitter;

  LatencyInfo({
    this.latency,
    this.jitter,
  });

  LatencyInfo.fromJson(Map<String, dynamic> json) {
    latency = json['latency'];
    jitter = json['jitter'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['latency'] = latency;
    data['jitter'] = jitter;
    return data;
  }
}
