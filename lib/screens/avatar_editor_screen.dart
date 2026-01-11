import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/avatar.dart';
import '../repositories/avatar_repository.dart';

class AvatarEditorScreen extends StatefulWidget {
  final int? userId;

  const AvatarEditorScreen({this.userId, super.key});

  @override
  State<AvatarEditorScreen> createState() => _AvatarEditorScreenState();
}

class _AvatarEditorScreenState extends State<AvatarEditorScreen> {
  final AvatarRepository _avatarRepo = AvatarRepository();

  // Seçili özellikler
  String selectedHairStyle = 'short';
  Color selectedHairColor = Colors.brown;
  String selectedOutfit = 'casual';
  Color selectedOutfitColor = Colors.blue;
  String selectedGender = 'male';

  // Aktif tab (saç, kıyafet, cinsiyet)
  String activeTab = 'hair';

  // Saç stilleri
  final List<String> hairStyles = ['short', 'long', 'curly', 'bald'];
  
  // Kıyafet seçenekleri
  final List<String> outfits = ['casual', 'formal', 'sport', 'hoodie'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avatar Düzenleme'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveAvatar,
          ),
        ],
      ),
      body: Column(
        children: [
          // Avatar Önizleme Alanı (Stack ile katmanlar)
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: _buildAvatarPreview(),
              ),
            ),
          ),

          // Renk Seçici
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                Text(
                  activeTab == 'hair' ? 'Saç Rengi' : 'Kıyafet Rengi',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildColorWheel(),
              ],
            ),
          ),

          // Alt Menü (Saç, Kıyafet, Cinsiyet)
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTab('Saç', 'hair', Icons.face),
                        _buildTab('Kıyafet', 'outfit', Icons.checkroom),
                        _buildTab('Cinsiyet', 'gender', Icons.wc),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // İçerik
                  Expanded(
                    child: _buildTabContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Avatar Önizleme (Stack ile katmanlar)
  Widget _buildAvatarPreview() {
    return SizedBox(
      width: 300,
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Beden (Asset'ten gelecek)
          Image.asset(
            'assets/images/body_$selectedGender.png',
            width: 300,
            height: 400,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 300,
                height: 400,
                color: Colors.grey[300],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person, size: 100, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Beden resmi\nbody_$selectedGender.png',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            },
          ),

          // Saç (Renk ile)
          if (selectedHairStyle != 'bald')
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                selectedHairColor,
                BlendMode.srcATop,
              ),
              child: Image.asset(
                'assets/images/hair_$selectedHairStyle.png',
                width: 300,
                height: 400,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 200,
                    height: 100,
                    margin: const EdgeInsets.only(bottom: 200),
                    decoration: BoxDecoration(
                      color: selectedHairColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        selectedHairStyle,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Kıyafet (Renk ile)
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              selectedOutfitColor,
              BlendMode.srcATop,
            ),
            child: Image.asset(
              'assets/images/outfit_$selectedOutfit.png',
              width: 300,
              height: 400,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 150,
                  margin: const EdgeInsets.only(top: 150),
                  decoration: BoxDecoration(
                    color: selectedOutfitColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      selectedOutfit,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Color Wheel
  Widget _buildColorWheel() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            Color tempColor = activeTab == 'hair' ? selectedHairColor : selectedOutfitColor;
            
            return AlertDialog(
              title: Text(activeTab == 'hair' ? 'Saç Rengi Seç' : 'Kıyafet Rengi Seç'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: tempColor,
                  onColorChanged: (Color color) {
                    tempColor = color;
                  },
                  pickerAreaHeightPercent: 0.8,
                  displayThumbColor: true,
                  enableAlpha: false,
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
                      if (activeTab == 'hair') {
                        selectedHairColor = tempColor;
                      } else {
                        selectedOutfitColor = tempColor;
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
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: activeTab == 'hair' ? selectedHairColor : selectedOutfitColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(Icons.palette, color: Colors.white),
      ),
    );
  }

  // Tab Buton
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

  // Tab İçeriği
  Widget _buildTabContent() {
    if (activeTab == 'hair') {
      return _buildHairOptions();
    } else if (activeTab == 'outfit') {
      return _buildOutfitOptions();
    } else {
      return _buildGenderOptions();
    }
  }

  // Saç Seçenekleri
  Widget _buildHairOptions() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: hairStyles.length,
      itemBuilder: (context, index) {
        final style = hairStyles[index];
        final isSelected = selectedHairStyle == style;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedHairStyle = style;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
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
                  style == 'bald' ? Icons.circle : Icons.face,
                  size: 32,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  style,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Kıyafet Seçenekleri
  Widget _buildOutfitOptions() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: outfits.length,
      itemBuilder: (context, index) {
        final outfit = outfits[index];
        final isSelected = selectedOutfit == outfit;
        return GestureDetector(
          onTap: () {
            setState(() {
              selectedOutfit = outfit;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
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
                  Icons.checkroom,
                  size: 32,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                const SizedBox(height: 4),
                Text(
                  outfit,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Cinsiyet Seçenekleri
  Widget _buildGenderOptions() {
    return Padding(
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
        });
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 3,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
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
      final avatar = Avatar(
        userId: widget.userId ?? 1, // TODO: Gerçek user ID'yi kullan
        hairStyle: selectedHairStyle,
        hairColor: '#${selectedHairColor.value.toRadixString(16).substring(2)}',
        outfit: selectedOutfit,
        outfitColor: '#${selectedOutfitColor.value.toRadixString(16).substring(2)}',
      );

      await _avatarRepo.createAvatar(avatar);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar kaydedildi!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    }
  }
}
