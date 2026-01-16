# Tema Kullanım Kılavuzu

Bu uygulama için özel bir tema sistemi oluşturulmuştur. Renkleri kolayca değiştirebilir ve açık/koyu mod arasında geçiş yapabilirsiniz.

## 📂 Tema Dosyası
Tema ayarları: `lib/theme/app_theme.dart`

## 🎨 Renkleri Değiştirme

### 1. Temel Renkleri Değiştirme
`lib/theme/app_theme.dart` dosyasındaki `AppColors` sınıfını düzenleyin:

```dart
class AppColors {
  // Açık Mod Renkleri
  static const lightPrimary = Color(0xFF2196F3);    // Ana renk
  static const lightSecondary = Color(0xFF03A9F4);  // İkincil renk
  static const lightBackground = Color(0xFFF5F5F5); // Arka plan
  // ... diğer renkler

  // Koyu Mod Renkleri
  static const darkPrimary = Color(0xFF90CAF9);     // Ana renk
  static const darkSecondary = Color(0xFF64B5F6);   // İkincil renk
  static const darkBackground = Color(0xFF121212);  // Arka plan
  // ... diğer renkler
}
```

### 2. Ekranlarda Tema Renklerini Kullanma

Her ekranda tema renklerine şu şekilde erişin:

```dart
@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);
  final colorScheme = theme.colorScheme;
  
  return Container(
    color: colorScheme.surface,        // Yüzey rengi
    child: Text(
      'Merhaba',
      style: TextStyle(
        color: colorScheme.onSurface,  // Yüzey üstü metin rengi
      ),
    ),
  );
}
```

### 3. Kullanılabilir Tema Renkleri

- `colorScheme.primary` - Ana renk
- `colorScheme.secondary` - İkincil renk
- `colorScheme.surface` - Kart, panel vb. yüzey rengi
- `colorScheme.error` - Hata rengi
- `colorScheme.onPrimary` - Ana renk üzerindeki metin/ikon rengi
- `colorScheme.onSurface` - Yüzey üzerindeki metin/ikon rengi
- `colorScheme.onBackground` - Arka plan üzerindeki metin/ikon rengi

### 4. Özel Renkler

Özel renkler doğrudan `AppColors` sınıfından erişilebilir:

```dart
import 'package:lip_app/theme/app_theme.dart';

Container(
  color: AppColors.success,  // Yeşil - başarı
  // veya
  color: AppColors.warning,  // Turuncu - uyarı
  // veya
  color: AppColors.info,     // Mavi - bilgi
)
```

## 🌓 Tema Modu Değiştirme

### Sistem Ayarına Göre (Otomatik)
`lib/main.dart` dosyasında:
```dart
themeMode: ThemeMode.system,  // Sistem ayarına göre (varsayılan)
```

### Sabit Açık Mod
```dart
themeMode: ThemeMode.light,   // Her zaman açık mod
```

### Sabit Koyu Mod
```dart
themeMode: ThemeMode.dark,    // Her zaman koyu mod
```

### Kullanıcı Seçimine Göre (İleride eklenebilir)
Ayarlar ekranında kullanıcının tema seçimini kaydetmek için:
1. SharedPreferences ile seçimi kaydet
2. State management ile tema modunu değiştir
3. Örnek kod eklenebilir

## 🎯 Örnek Renk Paletleri

### Mavi Tema (Şu anki)
```dart
lightPrimary: Color(0xFF2196F3)
darkPrimary: Color(0xFF90CAF9)
```

### Mor Tema
```dart
lightPrimary: Color(0xFF9C27B0)
darkPrimary: Color(0xFFCE93D8)
```

### Yeşil Tema
```dart
lightPrimary: Color(0xFF4CAF50)
darkPrimary: Color(0xFF81C784)
```

### Turuncu Tema
```dart
lightPrimary: Color(0xFFFF9800)
darkPrimary: Color(0xFFFFB74D)
```

## ✅ Avantajlar

1. **Tek Noktadan Kontrol**: Tüm renkler `app_theme.dart` dosyasında
2. **Kolay Değişiklik**: Renk kodlarını değiştirmeniz yeterli
3. **Tutarlılık**: Tüm uygulama aynı renk paletini kullanır
4. **Otomatik Koyu Mod**: Sistem ayarına göre otomatik değişir
5. **Tip Güvenliği**: Renkler statik olarak tanımlı

## 🔧 Bakım

Yeni bir ekran eklerken:
1. `Theme.of(context)` ile tema erişin
2. Sabit renk kullanmayın (Colors.blue gibi)
3. Her zaman `colorScheme` renklerini kullanın
4. Gerekirse `AppColors` sınıfına özel renkler ekleyin

## 📝 Notlar

- Renk değişiklikleri hot reload ile görünür
- Tüm renkler Material Design 3 uyumlu
- Erişilebilirlik için kontrast oranları optimize edilmiş
