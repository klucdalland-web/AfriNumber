import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPInput extends StatefulWidget {
  const OTPInput({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.autoFocus = true,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autoFocus;

  @override
  OTPInputState createState() => OTPInputState();
}

class OTPInputState extends State<OTPInput> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String _code = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    if (widget.autoFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  // ----- API publique -----
  void addDigit(int digit) {
    if (_code.length >= widget.length) return;
    _applyCode('$_code$digit');
  }

  void deleteLastDigit() {
    if (_code.isEmpty) return;
    _applyCode(_code.substring(0, _code.length - 1));
  }

  /// Vide tous les champs (utilisé après un "resend").
  void clear() {
    if (!mounted) return;
    _applyCode('');
    _focusNode.requestFocus();
  }

  void _applyCode(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    final truncated = digitsOnly.length > widget.length
        ? digitsOnly.substring(0, widget.length)
        : digitsOnly;

    if (truncated == _code && _controller.text == truncated) return;

    setState(() => _code = truncated);

    if (_controller.text != truncated) {
      _controller.value = TextEditingValue(
        text: truncated,
        selection: TextSelection.collapsed(offset: truncated.length),
      );
    }

    widget.onChanged?.call(truncated);

    if (truncated.length == widget.length) {
      widget.onCompleted?.call(truncated);
    }
  }

  void _onChanged(String value) => _applyCode(value);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final allFilled = _code.length == widget.length;
    final currentIndex = allFilled ? widget.length - 1 : _code.length;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Champ invisible : déclenche le clavier natif du téléphone.
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autoFocus,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                enableSuggestions: false,
                autocorrect: false,
                showCursor: false,
                maxLength: widget.length,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                onChanged: _onChanged,
                onSubmitted: (_) {
                  if (_code.length == widget.length) {
                    widget.onCompleted?.call(_code);
                  }
                },
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.length, (index) {
              final isFocused =
                  _focusNode.hasFocus && !allFilled && index == currentIndex;
              final hasValue =
                  index < _code.length && _code[index].isNotEmpty;
              final digit = hasValue ? _code[index] : '';

              return Container(
                width: 48,
                height: 56,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
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
                            blurRadius: isFocused ? 16 : 8,
                            offset: const Offset(0, 4),
                            spreadRadius: isFocused ? 0 : -2,
                          ),
                        ],
                      ),
                    ),
                    Center(
                      child: Text(
                        digit,
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontWeight: FontWeight.w700,
                          fontSize: 28,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    if (isFocused)
                      Center(child: _BlinkingCursor(color: colors.primary)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor({required this.color});

  final Color color;

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
              color: widget.color,
              borderRadius: BorderRadius.circular(1.25),
            ),
          ),
        );
      },
    );
  }
}
