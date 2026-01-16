import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Tema sistemini nasıl kullanacağınızı gösteren örnek widget
class ThemeExampleScreen extends StatelessWidget {
  const ThemeExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema ve renk şemasına erişim
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tema Kullanım Örnekleri'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tema renklerini kullanarak Card
            Card(
              // Card theme'den otomatik renk alır
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ana Renk Kullanımı',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Bu metin yüzey rengine uygun renkte.',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Container ile özel renkler
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bilgi mesajı örneği',
                      style: TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Butonlar (otomatik tema renkleri kullanır)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Ana Buton'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('İkincil Buton'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 4. Özel renkler (AppColors'dan)
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ColorChip(
                  color: AppColors.success,
                  label: 'Başarı',
                ),
                _ColorChip(
                  color: AppColors.warning,
                  label: 'Uyarı',
                ),
                _ColorChip(
                  color: AppColors.info,
                  label: 'Bilgi',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // 5. Şeffaf renkler
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Şeffaflık örneği (alpha: 0.1)',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 6. Hata rengi kullanımı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hata mesajı örneği',
                      style: TextStyle(color: colorScheme.onErrorContainer),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 7. Renk paleti gösterimi
            Text(
              'Mevcut Renk Paleti',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _ColorPaletteGrid(colorScheme: colorScheme),
          ],
        ),
      ),
    );
  }
}

/// Renkli chip widget
class _ColorChip extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorChip({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: color.withValues(alpha: 0.2),
      label: Text(
        label,
        style: TextStyle(color: color),
      ),
      avatar: CircleAvatar(
        backgroundColor: color,
        radius: 8,
      ),
    );
  }
}

/// Renk paletini gösteren grid
class _ColorPaletteGrid extends StatelessWidget {
  final ColorScheme colorScheme;

  const _ColorPaletteGrid({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final colors = [
      ('Primary', colorScheme.primary),
      ('Secondary', colorScheme.secondary),
      ('Surface', colorScheme.surface),
      ('Error', colorScheme.error),
      ('Background', Theme.of(context).scaffoldBackgroundColor),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.5,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: colors.length,
      itemBuilder: (context, index) {
        final (label, color) = colors[index];
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: _getContrastColor(color),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getContrastColor(Color color) {
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
