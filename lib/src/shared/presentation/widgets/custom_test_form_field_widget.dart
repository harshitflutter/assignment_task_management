import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:task_management/src/core/constants/app_colors.dart';
import 'package:task_management/src/core/styles/app_text_stryles.dart';

class CustomTestFormFieldWidget extends StatelessWidget {
  final TextInputType? textInputType;
  final TextStyle? textStyle;
  final TextStyle? textHintStyle;
  final TextStyle? prefixTextStyle;
  final TextStyle? counterTextStyle;
  final TextStyle? suffixTextStyle;
  final String? hintText;
  final String? errorText;
  final TextStyle? errorStyle;
  final String? prefixText;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final bool? autoFocus;
  final Widget? suffix;
  final Widget? prefix;
  final double? paddingHorizonatal;
  final double? paddingVertical;
  final bool? filled;
  final bool readOnly;
  final bool? obscureText;
  final TextEditingController textEditingController;
  final Color? fillColor;
  final TextCapitalization? textCapitalization;
  final Color? cursoreColor;
  final String? suffixText;
  final FocusNode? focusNode;
  final InputBorder? enableBorder;
  final int? maxLines;
  final int? maxLength;
  final int? minLines;
  final Function(String)? onChanged;
  final Function(PointerDownEvent)? onTapOutside;
  final TextAlign? textAlign;
  final Function(String)? onSaved;
  final Function()? onTap;
  final Function(String)? onFieldSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final InputBorder? focusedBorder;
  final InputBorder? focusedErrorBorder;
  final InputBorder? errorBorder;
  final Widget? counterWidget;
  final Widget? errorWidget;
  final Widget? lableWidget;
  final String? initialValue;
  final ScrollController? scrollController;
  final double? cursorHeight;
  final double? cursorWidth;
  final TextStyle? floatingLabelStyle;
  final TextStyle? labelStyle;
  final bool? alignLabelWithHint;
  final String? labelText;
  final bool isSucess;
  final bool isFailure;

  const CustomTestFormFieldWidget({
    super.key,
    this.autoFocus,
    this.errorStyle,
    this.textInputType,
    this.suffixText,
    this.onFieldSubmitted,
    this.onTap,
    this.errorBorder,
    this.focusedErrorBorder,
    required this.textEditingController,
    this.textStyle,
    this.inputFormatters,
    this.textHintStyle,
    this.errorText,
    this.onTapOutside,
    this.initialValue,
    this.textCapitalization,
    this.counterWidget,
    this.onChanged,
    this.textAlign,
    this.hintText,
    this.prefixText,
    this.prefix,
    this.suffixIcon,
    this.prefixTextStyle,
    this.obscureText,
    this.paddingVertical,
    this.suffixTextStyle,
    this.filled,
    this.enableBorder,
    this.focusedBorder,
    this.fillColor,
    this.maxLines = 1,
    this.prefixIcon,
    this.focusNode,
    this.onSaved,
    this.maxLength,
    this.suffix,
    this.minLines,
    this.cursoreColor = AppColors.black,
    this.counterTextStyle,
    this.readOnly = false,
    this.paddingHorizonatal,
    this.validator,
    this.scrollController,
    this.errorWidget,
    this.lableWidget,
    this.cursorHeight,
    this.floatingLabelStyle,
    this.labelStyle,
    this.alignLabelWithHint,
    this.cursorWidth,
    this.labelText,
    this.isSucess = false,
    this.isFailure = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: AppColors.fieldShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        minLines: minLines,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardAppearance: Brightness.light,
        scrollController: scrollController,
        controller: textEditingController,
        cursorColor: cursoreColor,
        keyboardType: textInputType,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        textAlign: textAlign ?? TextAlign.start,
        style: textStyle ?? AppTextStyles.fieldTextStyle,
        cursorHeight: cursorHeight ?? 20.h,
        cursorWidth: cursorWidth ?? 2.0,
        onSaved: (newValue) {},
        onTap: onTap,
        focusNode: focusNode,
        initialValue: initialValue,
        autofocus: autoFocus ?? false,
        maxLength: maxLength,
        readOnly: readOnly,
        validator: validator,
        obscureText: obscureText ?? false,
        textCapitalization: textCapitalization ?? TextCapitalization.none,
        onTapOutside: onTapOutside ??
            (event) {
              FocusScope.of(context).unfocus();
            },
        onFieldSubmitted: onFieldSubmitted,
        onChanged: onChanged,
        decoration: InputDecoration(
          floatingLabelStyle: floatingLabelStyle,
          labelText: labelText,
          label: lableWidget,
          labelStyle: labelStyle,
          errorText: null,
          errorStyle: errorStyle,
          isDense: true,
          suffixText: suffixText,
          focusedErrorBorder: focusedErrorBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.red.withOpacity(0.8),
                  width: 2,
                ),
              ),
          errorBorder: errorBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.red.withOpacity(0.6),
                  width: 1.5,
                ),
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: AppColors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide(
              color: AppColors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
          enabledBorder: enableBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(
                  color: AppColors.grey.withOpacity(0.2),
                  width: 1,
                ),
              ),
          focusedBorder: focusedBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(
                  color: AppColors.signInGradient1,
                  width: 2,
                ),
              ),
          suffixStyle: suffixTextStyle,
          suffixIcon: suffixIcon,
          suffix: suffix,
          hintText: hintText,
          counter: counterWidget,
          prefixText: prefixText,
          prefix: prefix,
          alignLabelWithHint: alignLabelWithHint,
          prefixIconConstraints: BoxConstraints(
            minWidth: 48.w,
            minHeight: 20.h,
          ),
          prefixStyle: prefixTextStyle,
          suffixIconConstraints: const BoxConstraints(),
          hintStyle: textHintStyle ?? AppTextStyles.hint400Size10,
          prefixIcon: prefixIcon,
          contentPadding: EdgeInsets.symmetric(
            horizontal: paddingHorizonatal ?? 20.w,
            vertical: paddingVertical ?? 18.h,
          ),
          filled: filled ?? true,
          counterStyle: counterTextStyle,
          fillColor: fillColor ?? AppColors.white,
        ),
      ),
    );
  }
}
