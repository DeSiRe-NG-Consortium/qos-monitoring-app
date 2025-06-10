class CustomSetting {
  int id;
  bool showNotification;
  int value;
  bool showError;
  bool lowerIsBetter;
  int defaultValue;

  CustomSetting(
      {required this.id,
      required this.showNotification,
      required this.value,
      required this.defaultValue,
      required this.showError,
      required this.lowerIsBetter});

  factory CustomSetting.fromMap(Map<String, dynamic> map) {
    return CustomSetting(
      id: map['id'] as int,
      showNotification: map['showNotification'] as bool,
      value: map['value'] as int,
      defaultValue: map['defaultValue'] as int,
      showError: map['showError'] as bool,
      lowerIsBetter: map['lowerIsBetter'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'showNotification': showNotification,
      'value': value,
      'defaultValue': defaultValue,
      'showError': showError,
      'lowerIsBetter': lowerIsBetter,
    };
  }
}
