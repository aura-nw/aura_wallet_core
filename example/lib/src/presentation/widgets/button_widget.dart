import 'package:example/src/application/app_theme/app_theme_builder.dart';
import 'package:flutter/material.dart';

extension RadiusX on Radius {
  Radius subtract(double value) => Radius.elliptical(x - value, y - value);
}

extension BorderRadiusX on BorderRadius {
  BorderRadius subtractBy(double value) => copyWith(
        topLeft: topLeft.subtract(1),
        topRight: topRight.subtract(1),
        bottomLeft: bottomLeft.subtract(1),
        bottomRight: bottomRight.subtract(1),
      );
}

class AppButton extends StatelessWidget {
  final String text;
  final Widget? leading;
  final TextStyle textStyle;

  final Color? color;
  final Gradient? gradient;

  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final double? minWidth;

  final bool disabled;
  final bool loading;

  final void Function()? onPress;

  AppButton({
    Key? key,
    required this.text,
    this.onPress,
    this.color,
    this.gradient,
    this.minWidth,
    this.leading,
    bool? loading,
    bool? disabled,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  })  : assert(color == null || gradient == null),
        loading = loading ?? false,
        disabled = (disabled ?? false) || (loading ?? false),
        padding = padding ?? const EdgeInsets.all(16),
        borderRadius = borderRadius ?? BorderRadius.circular(16),
        textStyle = textStyle ?? const TextStyle(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: AppThemeBuilder(
        builder: (theme) => Ink(
          decoration: BoxDecoration(
            color: disabled ? theme.neutralColor1 : color,
            gradient: disabled ? null : gradient,
          ),
          child: InkWell(
            splashColor: Colors.white10,
            highlightColor: Colors.white10,
            onTap: disabled ? null : onPress,
            child: Container(
              constraints:
                  minWidth != null ? BoxConstraints(minWidth: minWidth!) : null,
              padding: padding,
              alignment: Alignment.center,
              child: loading
                  ? SizedBox.square(
                      dimension: 19.2,
                      child: CircularProgressIndicator(color: textStyle.color))
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        leading ?? const SizedBox.shrink(),
                        if (leading != null)
                          const SizedBox(
                            width: 7,
                          ),
                        Text(text, style: textStyle),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String text;
  final Gradient gradient;
  final TextStyle? textStyle;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final bool? disabled;
  final bool? loading;
  final void Function() onPress;

  const GradientButton({
    Key? key,
    required this.text,
    required this.onPress,
    required this.gradient,
    this.borderRadius,
    this.textStyle,
    this.padding,
    this.disabled,
    this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      borderRadius: borderRadius,
      gradient: gradient,
      disabled: disabled,
      loading: loading,
      padding: padding,
      textStyle: textStyle,
      onPress: onPress,
    );
  }
}

class InactiveGradientButton extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final EdgeInsets padding;
  final BorderRadius borderRadius;
  final bool disabled;
  final bool loading;
  final void Function() onPress;

  InactiveGradientButton({
    Key? key,
    required this.text,
    required this.onPress,
    bool? disabled,
    bool? loading,
    EdgeInsets? padding,
    BorderRadius? borderRadius,
    TextStyle? textStyle,
  })  : padding = padding ?? const EdgeInsets.all(16),
        borderRadius = borderRadius ?? BorderRadius.circular(10),
        textStyle = textStyle ?? const TextStyle(),
        disabled = disabled ?? false,
        loading = loading ?? false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppThemeBuilder(
      builder: (theme) => GradientButton(
        gradient: theme.gradient8,
        onPress: onPress,
        text: text,
        textStyle: textStyle.copyWith(
          color: theme.primaryColor5,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        loading: loading,
        disabled: disabled,
        borderRadius: borderRadius,
        padding: padding,
      ),
    );
  }
}
