import 'package:flutter/material.dart';

class CustomNumericKeypad extends StatelessWidget {
  const CustomNumericKeypad({
    super.key,
    required this.onDigitTap,
    required this.onBackspaceTap,
    this.enabled = true,
  });

  final ValueChanged<int> onDigitTap;
  final VoidCallback onBackspaceTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: keys.map((row) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: row.map((key) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _KeypadButton(
                    label: key,
                    onTap: key == '⌫'
                        ? onBackspaceTap
                        : key.isEmpty
                            ? null
                            : () => onDigitTap(int.parse(key)),
                    isBackspace: key == '⌫',
                    enabled: enabled && key.isNotEmpty,
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.label,
    required this.onTap,
    this.isBackspace = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onTap;
  final bool isBackspace;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 64,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(18),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                    spreadRadius: -1,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: isBackspace
              ? Icon(
                  Icons.backspace_outlined,
                  size: 26,
                  color: enabled ? Colors.black : Colors.grey.shade400,
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontWeight: FontWeight.w700,
                    fontSize: 26,
                    color: enabled ? Colors.black : Colors.grey.shade400,
                    letterSpacing: -0.3,
                  ),
                ),
        ),
      ),
    );
  }
}