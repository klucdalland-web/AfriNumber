import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Widget d'animation de chiffres façon "Hacking / Matrix / Rolling Counter".
/// Anime un montant de 0 (ou caractères aléatoires) vers la valeur cible.
class HackingNumberText extends StatefulWidget {
  const HackingNumberText({
    super.key,
    required this.targetValue,
    this.prefix = '',
    this.suffix = '',
    this.style,
    this.duration = const Duration(milliseconds: 1400),
    this.isCurrency = true,
  });

  /// Valeur numérique cible (ex: 40800.00)
  final double targetValue;

  /// Préfixe (ex: "$ ", "£ ")
  final String prefix;

  /// Suffixe (ex: " FCFA", " €")
  final String suffix;

  /// Style du texte
  final TextStyle? style;

  /// Durée totale de l'animation
  final Duration duration;

  /// Si vrai, formate avec 2 décimales et séparateur de milliers
  final bool isCurrency;

  @override
  State<HackingNumberText> createState() => _HackingNumberTextState();
}

class _HackingNumberTextState extends State<HackingNumberText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  Timer? _scrambleTimer;
  final Random _random = Random();
  bool _isScrambling = true;
  String _scramblePrefix = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    // Effet de brouillage façon "matrix/hacking" au démarrage
    _scrambleTimer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (_controller.value > 0.4) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isScrambling = false;
          });
        }
        return;
      }
      if (mounted) {
        setState(() {
          _scramblePrefix = List.generate(
            4,
            (_) => _random.nextInt(10).toString(),
          ).join();
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _scrambleTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String _formatNumber(double val) {
    if (widget.isCurrency) {
      final parts = val.toStringAsFixed(2).split('.');
      final integerPart = parts[0].replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$integerPart.${parts[1]}';
    }
    return val.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentValue = _animation.value * widget.targetValue;
        final formatted = _formatNumber(currentValue);

        if (_isScrambling && _animation.value < 0.2) {
          return Text(
            '${widget.prefix}$_scrambleDigitsFormatted${widget.suffix}',
            style: widget.style,
          );
        }

        return Text(
          '${widget.prefix}$formatted${widget.suffix}',
          style: widget.style,
        );
      },
    );
  }

  String get _scrambleDigitsFormatted {
    return '$_scramblePrefix.${_random.nextInt(99).toString().padLeft(2, '0')}';
  }
}
