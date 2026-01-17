import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'custom_text_field.dart';
import 'validation_error.dart';

/// Validated text field with built-in validation and error display
class ValidatedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;
  final bool showErrorInline;
  final EdgeInsetsGeometry? contentPadding;

  const ValidatedTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.inputFormatters,
    this.errorText,
    this.showErrorInline = true,
    this.contentPadding,
  });

  @override
  State<ValidatedTextField> createState() => _ValidatedTextFieldState();
}

class _ValidatedTextFieldState extends State<ValidatedTextField> {
  String? _errorText;
  bool _hasBeenTouched = false;

  @override
  void initState() {
    super.initState();
    _errorText = widget.errorText;
  }

  @override
  void didUpdateWidget(ValidatedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.errorText != oldWidget.errorText) {
      _errorText = widget.errorText;
    }
  }

  void _validate(String? value) {
    if (widget.validator != null) {
      setState(() {
        _errorText = widget.validator!(value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomTextField(
          controller: widget.controller,
          label: widget.label,
          hint: widget.hint,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.suffixIcon,
          onSuffixIconTap: widget.onSuffixIconTap,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: (value) {
            if (_hasBeenTouched) {
              _validate(value);
            }
            widget.onChanged?.call(value);
          },
          onSubmitted: (value) {
            _hasBeenTouched = true;
            _validate(value);
            widget.onSubmitted?.call(value);
          },
          onTap: widget.onTap,
          validator: (value) {
            if (!_hasBeenTouched) return null;
            _hasBeenTouched = true;
            final error = widget.validator?.call(value);
            _errorText = error;
            return error;
          },
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          inputFormatters: widget.inputFormatters,
          errorText: _errorText,
          contentPadding: widget.contentPadding,
        ),
        if (widget.showErrorInline && _errorText != null && _errorText!.isNotEmpty)
          ValidationError(message: _errorText!),
      ],
    );
  }
}
