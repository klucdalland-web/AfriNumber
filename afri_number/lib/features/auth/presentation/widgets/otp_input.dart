import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInput extends StatefulWidget {
  const OTPInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.autoFocus = true,
    this.maxBoxSize = 60,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;

  /// Plafond de la taille d'une case (tablettes, web).
  final double maxBoxSize;

  @override
  OTPInputState createState() => OTPInputState();
}

class OTPInputState extends State<OTPInput> {
  late final List<TextEditingController> _controllers;
  late final FocusNode _hiddenFocusNode;
  int _currentIndex = 0;

  static final Map<LogicalKeyboardKey, int> _digitMap = {
    LogicalKeyboardKey.digit0: 0,
    LogicalKeyboardKey.digit1: 1,
    LogicalKeyboardKey.digit2: 2,
    LogicalKeyboardKey.digit3: 3,
    LogicalKeyboardKey.digit4: 4,
    LogicalKeyboardKey.digit5: 5,
    LogicalKeyboardKey.digit6: 6,
    LogicalKeyboardKey.digit7: 7,
    LogicalKeyboardKey.digit8: 8,
    LogicalKeyboardKey.digit9: 9,
    LogicalKeyboardKey.numpad0: 0,
    LogicalKeyboardKey.numpad1: 1,
    LogicalKeyboardKey.numpad2: 2,
    LogicalKeyboardKey.numpad3: 3,
    LogicalKeyboardKey.numpad4: 4,
    LogicalKeyboardKey.numpad5: 5,
    LogicalKeyboardKey.numpad6: 6,
    LogicalKeyboardKey.numpad7: 7,
    LogicalKeyboardKey.numpad8: 8,
    LogicalKeyboardKey.numpad9: 9,
  };

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _hiddenFocusNode = FocusNode();

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _hiddenFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    _hiddenFocusNode.dispose();
    super.dispose();
  }

  String get _currentCode => _controllers.map((c) => c.text).join();

  // ----- API publique -----

  /// Accepte un `int` ou un `String` (ex. 5 ou '5').
  void addDigit(dynamic digit) {
    final value = int.tryParse(digit.toString());
    if (value == null || value < 0 || value > 9) return;
    _handleNumericInput(value);
  }

  void deleteLastDigit() => _handleBackspace();

  /// Vide tous les champs (utilisé après un "resend").
  void clear() {
    if (!mounted) return;
    setState(() {
      for (final c in _controllers) {
        c.clear();
      }
      _currentIndex = 0;
    });
    widget.onChanged?.call('');
  }

  // ----- Gestion clavier physique -----
  bool _isHandledKey(LogicalKeyboardKey key) =>
      key == LogicalKeyboardKey.backspace ||
      key == LogicalKeyboardKey.enter ||
      key == LogicalKeyboardKey.numpadEnter ||
      _digitMap.containsKey(key);

  void _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.backspace) {
      _handleBackspace();
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _handleSubmit();
    } else if (_digitMap.containsKey(key)) {
      _handleNumericInput(_digitMap[key]!);
    }
  }

  // ----- Saisie / suppression -----
  void _handleNumericInput(int digit) {
    if (!mounted) return;
    final emptyIndex = _controllers.indexWhere((c) => c.text.isEmpty);
    if (emptyIndex == -1) return;

    setState(() {
      _controllers[emptyIndex].text = digit.toString();
      _currentIndex = (emptyIndex + 1).clamp(0, widget.length - 1);
    });

    final code = _currentCode;
    widget.onChanged?.call(code);

    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  void _handleBackspace() {
    if (!mounted) return;
    final lastFilledIndex = _controllers.lastIndexWhere(
      (c) => c.text.isNotEmpty,
    );
    if (lastFilledIndex == -1) return;

    setState(() {
      _controllers[lastFilledIndex].clear();
      _currentIndex = lastFilledIndex;
    });

    widget.onChanged?.call(_currentCode);
  }

  void _handleSubmit() {
    if (_currentCode.length == widget.length) {
      widget.onCompleted?.call(_currentCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final allFilled = _currentCode.length == widget.length;

    return Focus(
      focusNode: _hiddenFocusNode,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent && _isHandledKey(event.logicalKey)) {
          _onKeyEvent(event);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;

          // Tout est proportionnel à la largeur disponible.
          final gap = (maxW * 0.02).clamp(4.0, 12.0);
          final boxW = ((maxW - gap * (widget.length - 1)) / widget.length)
              .clamp(0.0, widget.maxBoxSize);
          final boxH = boxW * 1.2;
          final radius = boxW * 0.28;

          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var index = 0; index < widget.length; index++) ...[
                if (index > 0) SizedBox(width: gap),
                _buildBox(
                  colors: colors,
                  index: index,
                  width: boxW,
                  height: boxH,
                  radius: radius,
                  allFilled: allFilled,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildBox({
    required ColorScheme colors,
    required int index,
    required double width,
    required double height,
    required double radius,
    required bool allFilled,
  }) {
    final isFocused = !allFilled && index == _currentIndex;
    final hasValue = _controllers[index].text.isNotEmpty;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              color: colors.surfaceContainerHighest,
              border: Border.all(
                color: isFocused
                    ? colors.primary
                    : hasValue
                        ? colors.outline
                        : colors.outlineVariant,
                width: isFocused ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(
                    alpha: isFocused ? 0.1 : 0.05,
                  ),
                  blurRadius: isFocused ? 12 : 6,
                  offset: const Offset(0, 3),
                  spreadRadius: isFocused ? 0 : -2,
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              _controllers[index].text,
              style: TextStyle(
                fontFamily: 'Georgia',
                fontWeight: FontWeight.w700,
                fontSize: width * 0.5,
                color: colors.onSurface,
              ),
            ),
          ),
          if (isFocused)
            Center(
              child: _BlinkingCursor(
                color: colors.primary,
                height: height * 0.5,
              ),
            ),
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Container(
            width: 2.5,
            height: widget.height,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(1.25),
            ),
          ),
        );
      },
    );
  }
}