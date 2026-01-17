import 'package:flutter/material.dart';
import '../theme/theme_manager.dart';

class ThemeToggleButton extends StatelessWidget {
  final ThemeManager themeManager;
  
  const ThemeToggleButton({
    required this.themeManager,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    
    return Positioned(
      right: 16,
      bottom: 16,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: brightness == Brightness.dark 
              ? colorScheme.surfaceContainerHighest 
              : colorScheme.surface,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: () => themeManager.toggleTheme(),
            customBorder: const CircleBorder(),
            child: Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(12),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return RotationTransition(
                    turns: animation,
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Icon(
                  themeManager.themeIcon,
                  key: ValueKey(themeManager.themeMode),
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
