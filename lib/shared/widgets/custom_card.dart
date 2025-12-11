import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Gradient? gradient;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.borderRadius,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final cardChild = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: gradient != null
          ? BoxDecoration(
              gradient: gradient,
              borderRadius: borderRadius ?? BorderRadius.circular(16),
            )
          : null,
      child: child,
    );

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 4),
      child: gradient != null
          ? Material(
              color: Colors.transparent,
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius ?? BorderRadius.circular(16),
                child: cardChild,
              ),
            )
          : Card(
              color: color,
              elevation: elevation ?? 2,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius ?? BorderRadius.circular(16),
              ),
              child: InkWell(
                onTap: onTap,
                borderRadius: borderRadius ?? BorderRadius.circular(16),
                child: Container(
                  padding: padding ?? const EdgeInsets.all(16),
                  child: child,
                ),
              ),
            ),
    );
  }
}