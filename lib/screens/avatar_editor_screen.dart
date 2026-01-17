import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../theme/theme_manager.dart';
import '../widgets/theme_toggle_button.dart';

class AvatarEditorScreen extends StatefulWidget {
  final int? userId;
  final ThemeManager? themeManager;

  const AvatarEditorScreen({this.userId, this.themeManager, super.key});

  @override
  State<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends State<AvatarEditorScreen> {
  bool _isLoading = true;

  String selectedGender = 'male';
  String selectedSkinTone = 'light'; 
  String selectedEye = 'male-eye'; 
  Color selectedEyeColor = const Color(0xFF8B4513); 
  String? selectedHair;
  Color selectedHairColor = const Color(0xFF3D2817); 
  String? selectedBottomWear;
  Color selectedBottomColor = Colors.blue;
  String? selectedTopWear;
  Color selectedTopColor = Colors.red;

  String activeTab = 'gender';

  final Map<String, Map<String, List<String>>> avatarParts = {
    'male': {
      'eye': ['male-eye'],
      'hair': ['male-hair1', 'male-hair2'],
      'bottom': ['male-pant', 'male-sort'],
      'top': ['male-shirt', 'male-sweat'],
    },
    'female': {
      'eye': ['female-eye'],
      'hair': ['female-hair1', 'female-hair2', 'female-hair3', 'female-hair4'],
      'bottom': ['female-pant', 'etek'],
      'top': ['female-tisort', 'female-uzun-tisort', 'female-sweat'],
    },
  };

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    try {
      final response = await ApiService.instance.getAvatar();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null && mounted) {
          setState(() {
            
            // Cinsiyet
            if (data['gender'] != null) {
              selectedGender = data['gender'];
            }
            
            // Ten rengi
            if (data['skin_tone'] != null) {
              selectedSkinTone = data['skin_tone'];
            }
            
            // Göz rengi
            if (data['eye_color'] != null) {
              selectedEyeColor = _hexToColor(data['eye_color']);
            }
            // Göz tipini cinsiyete göre ayarla
            selectedEye = selectedGender == 'male' ? 'male-eye' : 'female-eye';
            
            // Saç
            if (data['hair_style'] != null) {
              selectedHair = data['hair_style'];
            }
            if (data['hair_color'] != null) {
              selectedHairColor = _hexToColor(data['hair_color']);
            }
            
            // Üst giysi
            selectedTopWear = data['top_clothing'];
            if (data['top_clothing_color'] != null) {
              selectedTopColor = _hexToColor(data['top_clothing_color']);
            }
            
            // Alt giysi
            selectedBottomWear = data['bottom_clothing'];
            if (data['bottom_clothing_color'] != null) {
              selectedBottomColor = _hexToColor(data['bottom_clothing_color']);
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Avatar yükleme hatası: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Düzenleme'),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: _saveAvatar,
            icon: const Icon(Icons.save, color: Colors.white),
            label: const Text(
              'Kaydet',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: _buildAvatarPreview(),
                  ),
                ),
              ),

              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              _buildTab('Cinsiyet', 'gender', Icons.wc),
                              const SizedBox(width: 8),
                              _buildTab('Ten', 'skin', Icons.palette),
                              const SizedBox(width: 8),
                              _buildTab('Göz', 'eye', Icons.visibility),
                              const SizedBox(width: 8),
                              _buildTab('Saç', 'hair', Icons.face_retouching_natural),
                              const SizedBox(width: 8),
                              _buildTab('Alt', 'bottom', Icons.checkroom),
                              const SizedBox(width: 8),
                              _buildTab('Üst', 'top', Icons.checkroom_outlined),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: _buildTabContent(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (widget.themeManager != null)
            ThemeToggleButton(themeManager: widget.themeManager!),
        ],
      ),
    );
  }

  Widget _buildAvatarPreview() {
    final bodyImage =
        'body-$selectedGender${selectedSkinTone == 'dark' ? '-dark' : ''}.png';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          double maxSize;

          if (screenWidth < 600) {
            maxSize = 250.0;
          } else if (screenWidth < 900) {
            maxSize = 350.0;
          } else {
            maxSize = 450.0;
          }

          final size =
              constraints.maxWidth < maxSize ? constraints.maxWidth : maxSize;

          return Center(
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/$bodyImage',
                    width: size,
                    height: size,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: size,
                        height: size,
                        color: Colors.grey[300],
                        child: Icon(Icons.person,
                            size: size * 0.5, color: Colors.grey[400]),
                      );
                    },
                  ),

                  if (selectedBottomWear != null)
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        selectedBottomColor,
                        BlendMode.modulate,
                      ),
                      child: Image.asset(
                        'assets/images/$selectedBottomWear.png',
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                      ),
                    ),

                  if (selectedTopWear != null)
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        selectedTopColor,
                        BlendMode.modulate,
                      ),
                      child: Image.asset(
                        'assets/images/$selectedTopWear.png',
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                      ),
                    ),

                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      selectedEyeColor,
                      BlendMode.modulate,
                    ),
                    child: Image.asset(
                      'assets/images/$selectedEye.png',
                      width: size,
                      height: size,
                      fit: BoxFit.contain,
                    ),
                  ),

                  if (selectedHair != null)
                    ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        selectedHairColor,
                        BlendMode.modulate,
                      ),
                      child: Image.asset(
                        'assets/images/$selectedHair.png',
                        width: size,
                        height: size,
                        fit: BoxFit.contain,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showColorPickerDialog(String category) {
    Color currentColor;
    String label;

    if (category == 'eye') {
      currentColor = selectedEyeColor;
      label = 'Göz Rengi';
    } else if (category == 'hair') {
      currentColor = selectedHairColor;
      label = 'Saç Rengi';
    } else if (category == 'bottom') {
      currentColor = selectedBottomColor;
      label = 'Alt Kıyafet Rengi';
    } else {
      currentColor = selectedTopColor;
      label = 'Üst Kıyafet Rengi';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        Color tempColor = currentColor;

        return AlertDialog(
          title: Text('$label Seç'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: tempColor,
              onColorChanged: (Color color) {
                tempColor = color;
              },
              availableColors: const [
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
                Colors.brown,
                Colors.grey,
                Colors.blueGrey,
                Colors.black,
                Colors.white,
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  if (category == 'eye') {
                    selectedEyeColor = tempColor;
                  } else if (category == 'hair') {
                    selectedHairColor = tempColor;
                  } else if (category == 'bottom') {
                    selectedBottomColor = tempColor;
                  } else {
                    selectedTopColor = tempColor;
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Seç'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTab(String label, String tabId, IconData icon) {
    final isActive = activeTab == tabId;
    return InkWell(
      onTap: () {
        setState(() {
          activeTab = tabId;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (activeTab) {
      case 'gender':
        return _buildGenderOptions();
      case 'skin':
        return _buildSkinToneOptions();
      case 'eye':
        return _buildPartOptions('eye', selectedEye);
      case 'hair':
        return _buildHairOptions();
      case 'bottom':
        return _buildPartOptions('bottom', selectedBottomWear);
      case 'top':
        return _buildPartOptions('top', selectedTopWear);
      default:
        return const Center(child: Text('Seçenek bulunamadı'));
    }
  }

  Widget _buildSkinToneOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildSkinToneOption('light', 'Açık Ten', const Color(0xFFFFDBAC)),
          _buildSkinToneOption('dark', 'Koyu Ten', const Color(0xFF8D5524)),
        ],
      ),
    );
  }

  Widget _buildSkinToneOption(String tone, String label, Color color) {
    final isSelected = selectedSkinTone == tone;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSkinTone = tone;
        });
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey, width: 2),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHairOptions() {
    final hairStyles = avatarParts[selectedGender]?['hair'] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Saç Rengi:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () => _showColorPickerDialog('hair'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selectedHairColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.palette, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildHairNumberButton(null, 'Yok'),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(
              hairStyles.length,
              (index) => _buildHairNumberButton(
                hairStyles[index],
                '${index + 1}',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHairNumberButton(String? hairStyle, String label) {
    final isSelected = selectedHair == hairStyle;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedHair = hairStyle;
        });
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade400,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.blue : Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPartOptions(String category, String? selectedValue) {
    final parts = avatarParts[selectedGender]?[category] ?? [];
    final showNoneOption = category != 'eye';

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        int crossAxisCount;

        if (screenWidth < 600) {
          crossAxisCount = 3; // Mobil
        } else if (screenWidth < 900) {
          crossAxisCount = 4; 
        } else {
          crossAxisCount = 5; 
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: parts.length + (showNoneOption ? 1 : 0),
          itemBuilder: (context, index) {
            if (showNoneOption && index == 0) {
              final isSelected = selectedValue == null;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (category == 'bottom') selectedBottomWear = null;
                    if (category == 'top') selectedTopWear = null;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close,
                        size: 32,
                        color: isSelected ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Yok',
                        style: TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final partIndex = showNoneOption ? index - 1 : index;
            final part = parts[partIndex];
            final isSelected = selectedValue == part;

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (category == 'eye') selectedEye = part;
                  if (category == 'bottom') selectedBottomWear = part;
                  if (category == 'top') selectedTopWear = part;
                });
              },
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue.withValues(alpha: 0.2)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.asset(
                              'assets/images/$part-thumbn.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.image_not_supported,
                                  size: 32,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _formatPartName(part),
                            style: TextStyle(
                              fontSize: 10,
                              color:
                                  isSelected ? Colors.blue : Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          _showColorPickerDialog(category);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.palette,
                            size: 16,
                            color: category == 'eye'
                                ? selectedEyeColor
                                : category == 'bottom'
                                    ? selectedBottomColor
                                    : selectedTopColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatPartName(String part) {
    return part
        .replaceAll('-', ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  Widget _buildGenderOptions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildGenderOption('male', Icons.male, 'Erkek'),
          _buildGenderOption('female', Icons.female, 'Kadın'),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon, String label) {
    final isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
          // Cinsiyet değişince göz otomatik değişsin, diğerleri sıfırlansın
          selectedEye = gender == 'male' ? 'male-eye' : 'female-eye';
          selectedHair = null;
          selectedBottomWear = null;
          selectedTopWear = null;
        });
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Avatar Kaydetme
  Future<void> _saveAvatar() async {
    try {
      String colorToHex(Color color) {
        return '#${color.red.toRadixString(16).padLeft(2, '0')}'
            '${color.green.toRadixString(16).padLeft(2, '0')}'
            '${color.blue.toRadixString(16).padLeft(2, '0')}';
      }

      // API'ye avatar kaydet - tüm özellikler
      await ApiService.instance.updateAvatar(
        gender: selectedGender,
        skinTone: selectedSkinTone,
        eyeColor: colorToHex(selectedEyeColor),
        hairStyle: selectedHair,
        hairColor: selectedHair != null ? colorToHex(selectedHairColor) : null,
        topClothing: selectedTopWear,
        topClothingColor: selectedTopWear != null ? colorToHex(selectedTopColor) : null,
        bottomClothing: selectedBottomWear,
        bottomClothingColor: selectedBottomWear != null ? colorToHex(selectedBottomColor) : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatarınız kaydedildi!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
