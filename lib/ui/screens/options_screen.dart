import 'package:flutter/material.dart';
import '../../services/sound_service.dart';
import '../utils/screen_utils.dart';

/// Options screen for adjusting game settings
class OptionsScreen extends StatefulWidget {
  const OptionsScreen({super.key});

  @override
  State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
  late bool _musicEnabled;
  late bool _soundEnabled;
  late double _soundEffectsVolume;
  late double _soundVolumeMultiplier;
  late double _musicVolumeMultiplier;
  late SoundService _soundService;

  @override
  void initState() {
    super.initState();
    _soundService = SoundService();
    _musicEnabled = _soundService.isMusicEnabled;
    _soundEnabled = _soundService.isSoundEnabled;
    _soundEffectsVolume = _soundService.soundVolume;
    _soundVolumeMultiplier = _soundService.soundVolumeMultiplier;
    _musicVolumeMultiplier = _soundService.musicVolumeMultiplier;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          'Options',
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(ScreenUtils.relativeSize(context, 0.04)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Music Toggle
              _buildToggleControl(
                context: context,
                title: 'Background Music',
                value: _musicEnabled,
                onChanged: (value) {
                  setState(() {
                    _musicEnabled = value;
                  });
                  _soundService.setMusicEnabled(value);
                },
              ),
              
              SizedBox(height: ScreenUtils.relativeSize(context, 0.04)),
              
              // Sound Effects Toggle
              _buildToggleControl(
                context: context,
                title: 'Sound Effects',
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() {
                    _soundEnabled = value;
                  });
                  _soundService.setSoundEnabled(value);
                },
              ),
              
              SizedBox(height: ScreenUtils.relativeSize(context, 0.04)),
              
              // Sound Effects Volume (only shown if sound effects are enabled)
              if (_soundEnabled) ...[
                _buildVolumeControl(
                  context: context,
                  title: 'Sound Effects Volume',
                  value: _soundEffectsVolume,
                  maxValue: _soundService.soundEffectsMaxVolume,
                  onChanged: (value) {
                    setState(() {
                      _soundEffectsVolume = value;
                    });
                    _soundService.setSoundVolume(value);
                  },
                ),
                
                SizedBox(height: ScreenUtils.relativeSize(context, 0.04)),
                
                // Sound Volume Multiplier
                _buildVolumeControl(
                  context: context,
                  title: 'Sound Volume Multiplier',
                  value: _soundVolumeMultiplier,
                  maxValue: 1.0,
                  onChanged: (value) {
                    setState(() {
                      _soundVolumeMultiplier = value;
                    });
                    _soundService.setSoundVolumeMultiplier(value);
                  },
                ),
              ],
              
              SizedBox(height: ScreenUtils.relativeSize(context, 0.04)),
              
              // Music Volume Multiplier
              _buildVolumeControl(
                context: context,
                title: 'Music Volume Multiplier',
                value: _musicVolumeMultiplier,
                maxValue: 1.0,
                onChanged: (value) {
                  setState(() {
                    _musicVolumeMultiplier = value;
                  });
                  _soundService.setMusicVolumeMultiplier(value);
                },
              ),
              
              SizedBox(height: ScreenUtils.relativeSize(context, 0.04)),
              
              // Info text about individual volumes
              Padding(
                padding: EdgeInsets.only(top: ScreenUtils.relativeSize(context, 0.02)),
                child: Text(
                  'Note: Individual sound (truck/money) and music (menu/background) volumes are controlled in config.dart',
                  style: TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: ScreenUtils.relativeFontSize(
                      context,
                      0.014,
                      min: 12,
                      max: 16,
                    ),
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleControl({
    required BuildContext context,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: ScreenUtils.relativeFontSize(
              context,
              0.018,
              min: 16,
              max: 24,
            ),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
        ),
      ],
    );
  }

  Widget _buildVolumeControl({
    required BuildContext context,
    required String title,
    required double value,
    double maxValue = 1.0,
    required ValueChanged<double> onChanged,
  }) {
    // Calculate percentage relative to max value
    final percentage = ((value / maxValue) * 100).round();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: ScreenUtils.relativeFontSize(
                  context,
                  0.018,
                  min: 16,
                  max: 24,
                ),
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontFamily: 'Fredoka',
                fontSize: ScreenUtils.relativeFontSize(
                  context,
                  0.016,
                  min: 14,
                  max: 20,
                ),
                fontWeight: FontWeight.w500,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
        SizedBox(height: ScreenUtils.relativeSize(context, 0.015)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.green,
            inactiveTrackColor: Colors.grey[300],
            thumbColor: Colors.green,
            overlayColor: Colors.green.withOpacity(0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 6,
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: maxValue,
            divisions: (maxValue * 100).round(),
            label: '$percentage%',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

