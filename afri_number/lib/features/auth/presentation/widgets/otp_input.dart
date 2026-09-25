import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInput extends StatefulWidget {
  const OTPInput({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.autoFocus = true,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;

  @override
  State<OTPInput> createState() => _OTPInputState();
}

class _OTPInputState extends State<OTPInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late FocusNode _hiddenFocusNode;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _hiddenFocusNode = FocusNode();

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hiddenFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    _hiddenFocusNode.dispose();
    super.dispose();
  }

  String get _currentCode => _controllers.map((c) => c.text).join();

  void _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      final logicalKey = event.logicalKey;

      if (logicalKey == LogicalKeyboardKey.backspace) {
        _handleBackspace();
      } else if (logicalKey == LogicalKeyboardKey.enter ||
          logicalKey == LogicalKeyboardKey.numpadEnter) {
        _handleSubmit();
      } else if (_isNumericKey(logicalKey)) {
        _handleNumericInput(_getDigitFromKey(logicalKey));
      }
    }
  }

  bool _isNumericKey(LogicalKeyboardKey key) {
    final numericKeys = <LogicalKeyboardKey>{
      LogicalKeyboardKey.digit0,
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
      LogicalKeyboardKey.digit4,
      LogicalKeyboardKey.digit5,
      LogicalKeyboardKey.digit6,
      LogicalKeyboardKey.digit7,
      LogicalKeyboardKey.digit8,
      LogicalKeyboardKey.digit9,
      LogicalKeyboardKey.numpad0,
      LogicalKeyboardKey.numpad1,
      LogicalKeyboardKey.numpad2,
      LogicalKeyboardKey.numpad3,
      LogicalKeyboardKey.numpad4,
      LogicalKeyboardKey.numpad5,
      LogicalKeyboardKey.numpad6,
      LogicalKeyboardKey.numpad7,
      LogicalKeyboardKey.numpad8,
      LogicalKeyboardKey.numpad9,
    };
    return numericKeys.contains(key);
  }

  int _getDigitFromKey(LogicalKeyboardKey key) {
    final digitMap = <LogicalKeyboardKey, int>{
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
    return digitMap[key] ?? 0;
  }

  void _handleNumericInput(int digit) {
    final emptyIndex = _controllers.indexWhere((c) => c.text.isEmpty);
    if (emptyIndex != -1) {
      _controllers[emptyIndex].text = digit.toString();
      _moveFocus(emptyIndex + 1);

      final code = _currentCode;
      widget.onChanged?.call(code);

      if (code.length == widget.length) {
        widget.onCompleted?.call(code);
      }
    }
  }

  void _handleBackspace() {
    final lastFilledIndex = _controllers.lastIndexWhere((c) => c.text.isNotEmpty);
    if (lastFilledIndex != -1) {
      _controllers[lastFilledIndex].clear();
      _moveFocus(lastFilledIndex);

      widget.onChanged?.call(_currentCode);
    }
  }

  void _handleSubmit() {
    if (_currentCode.length == widget.length) {
      widget.onCompleted?.call(_currentCode);
    }
  }

  void _moveFocus(int index) {
    if (index < widget.length) {
      _focusNodes[index].requestFocus();
    } else {
      _hiddenFocusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _hiddenFocusNode,
      onKeyEvent: (node, event) {
        _onKeyEvent(event);
        return KeyEventResult.handled;
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (index) {
          final isFocused = _focusNodes[index].hasFocus;
          final hasValue = _controllers[index].text.isNotEmpty;

          return Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    border: Border.all(
                      color: isFocused
                          ? Colors.black
                          : hasValue
                              ? Colors.black.withValues(alpha: 0.3)
                              : Colors.black.withValues(alpha: 0.12),
                      width: isFocused ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isFocused ? 0.1 : 0.05),
                        blurRadius: isFocused ? 16 : 8,
                        offset: const Offset(0, 4),
                        spreadRadius: isFocused ? 0 : -2,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Text(
                    _controllers[index].text,
                    style: const TextStyle(
                      fontFamily: 'Georgia',
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      color: Colors.black,
                    ),
                  ),
                ),
                if (isFocused && !hasValue)
                  const Center(
                    child: _BlinkingCursor(),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

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
            height: 32,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(1.25),
            ),
          ),
        );
      },
    );
  }
}