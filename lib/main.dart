import 'package:flutter/material.dart';
import 'package:settings_tiles/settings_tiles.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const Monet2ConfigApp());
}

class Monet2ConfigApp extends StatelessWidget {
  const Monet2ConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monet2 Configuration',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'FlexFontEn',
      ),
      home: const AppearanceSettingsPage(),
    );
  }
}

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  late SharedPreferences _prefs;
  bool _isEngineEnabled = true;
  double _vibrancy = 0.5;
  double _brightness = 0.5;

  static const String ENGINE_ENABLED_KEY = 'engine_enabled';
  static const String VIBRANCY_KEY = 'vibrancy';
  static const String BRIGHTNESS_KEY = 'brightness';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isEngineEnabled = _prefs.getBool(ENGINE_ENABLED_KEY) ?? true;
      _vibrancy = _prefs.getDouble(VIBRANCY_KEY) ?? 0.5;
      _brightness = _prefs.getDouble(BRIGHTNESS_KEY) ?? 0.5;
    });
  }

  Future<void> _setEnabled(bool value) async {
    setState(() {
      _isEngineEnabled = value;
    });
    await _prefs.setBool(ENGINE_ENABLED_KEY, value);
  }

  Future<void> _setVibrancy(double value) async {
    setState(() {
      _vibrancy = value;
    });
    await _prefs.setDouble(VIBRANCY_KEY, value);
  }

  Future<void> _setBrightness(double value) async {
    setState(() {
      _brightness = value;
    });
    await _prefs.setDouble(BRIGHTNESS_KEY, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: 'Monet2 Engine',
            tiles: [
              SettingsTile.switchTile(
                title: 'Enable Engine',
                value: _isEngineEnabled,
                onToggle: _setEnabled,
              ),
            ],
          ),
          SettingsSection(
            title: 'Theme Adjustments',
            tiles: [
              SettingsTile(
                title: 'Vibrancy',
                child: Slider(
                  value: _vibrancy,
                  onChanged: _setVibrancy,
                ),
              ),
              SettingsTile(
                title: 'Brightness',
                child: Slider(
                  value: _brightness,
                  onChanged: _setBrightness,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
