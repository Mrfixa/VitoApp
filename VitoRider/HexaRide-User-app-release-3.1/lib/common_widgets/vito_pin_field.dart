import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/styles.dart';

class VitoPinField extends StatefulWidget {
  final int length;
  final bool obscured;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final TextEditingController? controller;

  const VitoPinField({
    super.key,
    this.length = 6,
    this.obscured = true,
    this.onChanged,
    this.onCompleted,
    this.controller,
  });

  @override
  State<VitoPinField> createState() => _VitoPinFieldState();
}

class _VitoPinFieldState extends State<VitoPinField> with SingleTickerProviderStateMixin {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    if (widget.controller != null) {
      widget.controller!.addListener(_syncFromExternal);
    }
  }

  void _syncFromExternal() {
    final text = widget.controller?.text ?? '';
    for (int i = 0; i < widget.length; i++) {
      _controllers[i].text = i < text.length ? text[i] : '';
    }
  }

  void shake() {
    _shakeController.forward(from: 0);
  }

  String get _currentValue => _controllers.map((c) => c.text).join();

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (int i = 0; i < widget.length && i < digits.length; i++) {
        _controllers[i].text = digits[i];
      }
      if (digits.length >= widget.length) {
        _focusNodes.last.unfocus();
        widget.onCompleted?.call(_currentValue);
      }
      setState(() {});
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    widget.controller?.text = _currentValue;
    widget.onChanged?.call(_currentValue);

    if (_currentValue.length == widget.length) {
      widget.onCompleted?.call(_currentValue);
    }
    setState(() {});
  }

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(_shakeController.isAnimating
              ? (_shakeAnimation.value * ((_shakeController.value % 0.1 > 0.05) ? 1 : -1))
              : 0, 0),
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.length, (index) {
          final filled = _controllers[index].text.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: 44,
            height: 52,
            decoration: BoxDecoration(
              color: filled
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.12)
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
              border: Border.all(
                color: filled ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                width: filled ? 2 : 1,
              ),
            ),
            child: Transform.scale(
              scale: filled ? 1.08 : 1.0,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                obscureText: widget.obscured,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  counterText: '',
                  border: InputBorder.none,
                ),
                style: textBold.copyWith(fontSize: Dimensions.fontSizeLarge),
                onChanged: (v) => _onChanged(index, v),
              ),
            ),
          );
        }),
      ),
    );
  }
}
