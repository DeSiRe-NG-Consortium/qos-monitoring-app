import 'package:flutter/material.dart';
import 'package:flutter_connectivity_test/main.dart';
import 'package:flutter_connectivity_test/src/models/customsetting.dart';
import 'package:flutter_connectivity_test/src/service/settings_service.dart';
import 'package:numberpicker/numberpicker.dart';

class SettingsView extends StatefulWidget {
  static const routeName = '/settings';

  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  List<CustomSetting> _settings = [];
  List<String> _urls = [];
  
  TextEditingController downloadUrlController = TextEditingController();
  TextEditingController uploadUrlController = TextEditingController();

  TextEditingController frontendUrlController = TextEditingController();
  TextEditingController pingUrlController = TextEditingController();

  List<int> _selectedValues = [];

  bool updateNotifications = false;

  List<String> settingTitles = [
    'SS-RSRP (dB)',
    'RSRQ (dB)',
    'SINR (dB)',
    'Latency (ms)',
    'Jitter (ms)',
    'Download (mbit/s)',
    'Upload (mbit/s)',
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _settings = await SettingsStorage.loadSettings();
    if (_settings.isEmpty) {
      _settings = await SettingsStorage.defaultSettings();
    }
    _selectedValues = _settings.map((s) => s.value).toList();

    _urls = await SettingsStorage.loadUrlSettings();

    updateNotifications = await SettingsStorage.loadNotificationSettings();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 74, 74, 74),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 32, bottom: 16),
                child: Text('Settings', style: TextStyle(fontSize: 32, color: Colors.white)),
              ),
              const Divider(height: 2, thickness: 1, color: Colors.white54),
              const Padding(
                padding: EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 16.0),
                child: Text('Threshold Warnings', style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
              if (_settings.isNotEmpty)
                ...List.generate(_settings.length, (index) {
                  return _buildNumberPicker(_settings[index], index);
                }),
              const SizedBox(height: 32),
              Padding(padding: EdgeInsets.only(left: 20, right: 2, bottom: 24), child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Switch(
                      value: updateNotifications,
                      overlayColor: const WidgetStatePropertyAll<Color>(Colors.white),
                      trackColor: WidgetStatePropertyAll<Color>(updateNotifications ? Colors.green : Colors.red),
                      thumbColor: const WidgetStatePropertyAll<Color>(Colors.black),
                      onChanged: (bool value) {
                        setState(() {
                          updateNotifications = value;
                        });
                      },
                    ),
                    Padding(padding: EdgeInsets.only(left: 8), child:
                      InkWell(onTap: () {
                        setState(() {
                          updateNotifications = !updateNotifications;  
                        });
                      }, child:
                        Text('update existing notifications', style: TextStyle(fontSize: 16))
                      )
                    )
                  ]
                )),
              const SizedBox(height: 24),
              Text('Download Server', ),
              Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 4), child:
                TextField(
                  controller: downloadUrlController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: downloadUrlController.text == '' ? _urls.isEmpty ? '' : _urls[0] : downloadUrlController.text,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 0, right: 0, top: 16), child:
                Text('Upload Server', ),
              ),
              Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 4), child:
                TextField(
                  controller: uploadUrlController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: uploadUrlController.text == '' ? _urls.isEmpty ? '' : _urls[1] : uploadUrlController.text,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 0, right: 0, top: 16), child:
                Text('Frontend URL', ),
              ),
              Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 4), child:
                TextField(
                  controller: frontendUrlController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: frontendUrlController.text == '' ? _urls.isEmpty ? '' : _urls[3] : frontendUrlController.text,
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.only(left: 0, right: 0, top: 16), child:
                Text('Ping/Latency IP', ),
              ),
              Padding(padding: EdgeInsets.only(left: 16, right: 16, top: 4), child:
                TextField(
                  controller: pingUrlController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: pingUrlController.text == '' ? _urls.isEmpty ? '' : _urls[2] : pingUrlController.text,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: EdgeInsets.only(left: 16), child:
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: 
                        const Text('< ZURÜCK', style: TextStyle(color: Colors.white, fontSize: 15)),
                    )),
                  Padding(padding: EdgeInsets.only(right: 16), child:
                    ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: 
                        const Text('SPEICHERN', style: TextStyle(color: Colors.white, fontSize: 15)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberPicker(CustomSetting setting, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Checkbox(
            value: setting.showNotification,
            activeColor: Colors.amber,
            onChanged: (bool? newValue) {
                setState(() {
                  setting.showNotification = newValue!;
                });
            }
          ),
          SizedBox( width: 160, child:
            InkWell(
              onTap: () {
                setState(() {
                  setting.showNotification = !setting.showNotification; 
                });        
              }, 
              child:
                Text(
                  settingTitles[setting.id], 
                  style: const TextStyle(fontSize: 16, color: Colors.white)
                )
            )
          ),
          NumberPicker(
            axis: Axis.horizontal,
            value: _selectedValues[index],
            itemWidth: 40,
            minValue: -200,
            maxValue: 200,
            step: 1,
            haptics: true,
            onChanged: (value) {
              setState(() {
                _selectedValues[index] = value;
              });
            },
            textStyle: const TextStyle(color: Colors.grey),
            selectedTextStyle: const TextStyle(color: Color.fromARGB(255, 214, 214, 214), fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    await SettingsStorage.saveSettings(
      List.generate(_settings.length, (index) {
        return CustomSetting(
          id: index,
          showNotification: _settings[index].showNotification,
          value: _selectedValues[index],
          defaultValue: _settings[index].defaultValue,
          showError: false,
          lowerIsBetter: _settings[index].lowerIsBetter,
        );
      }),
    );

    List<String> urlSettings = [
      downloadUrlController.text == '' ? _urls[0] : downloadUrlController.text,
      uploadUrlController.text == '' ? _urls[1] : uploadUrlController.text,
      pingUrlController.text == '' ? _urls[2] : pingUrlController.text,
      frontendUrlController.text == '' ? _urls[3] : frontendUrlController.text,
    ];
    await SettingsStorage.saveUrlSettings(urlSettings);

    await SettingsStorage.saveNotificationSettings(updateNotifications);

    await notificationService?.cancelAllNotifications();
    settingsUpdate = true;

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
