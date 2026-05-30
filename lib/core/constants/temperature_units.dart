enum TemperatureUnit { celsius, fahrenheit }

extension TemperatureUnitExtension on TemperatureUnit {
  String get label => this == TemperatureUnit.celsius ? '°C' : '°F';
  double toDisplay(double celsiusValue) =>
      this == TemperatureUnit.celsius ? celsiusValue : celsiusValue * 9 / 5 + 32;
  double fromDisplay(double displayValue) =>
      this == TemperatureUnit.celsius ? displayValue : (displayValue - 32) * 5 / 9;
}
