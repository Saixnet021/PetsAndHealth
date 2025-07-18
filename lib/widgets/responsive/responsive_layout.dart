import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop;
        } else if (constraints.maxWidth >= 800) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveBreakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double desktop = 1200;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobile;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < desktop;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktop;
  }

  static bool isWeb(BuildContext context) {
    return MediaQuery.of(context).size.width > tablet;
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: padding,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1400) return 5;
    if (width >= 1200) return 4;
    if (width >= 900) return 3;
    if (width >= 600) return 2;
    return 1;
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? (isMobile ? double.infinity : 1200),
      ),
      padding:
          padding ??
          EdgeInsets.all(
            isMobile
                ? 16
                : isTablet
                ? 24
                : 32,
          ),
      margin: margin,
      child: child,
    );
  }
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);
    final isTablet = ResponsiveBreakpoints.isTablet(context);

    double fontSize = 16; // default

    if (isMobile && mobileFontSize != null) {
      fontSize = mobileFontSize!;
    } else if (isTablet && tabletFontSize != null) {
      fontSize = tabletFontSize!;
    } else if (desktopFontSize != null) {
      fontSize = desktopFontSize!;
    }

    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final bool forceColumn;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.forceColumn = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    if (isMobile || forceColumn) {
      return Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: children,
      );
    }

    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
}

class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return Container(
      margin: margin ?? EdgeInsets.all(isMobile ? 8 : 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: borderRadius ?? BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: padding ?? EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: backgroundColor ?? Colors.white.withOpacity(0.15),
              borderRadius: borderRadius ?? BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: elevation ?? 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final double? elevation;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return AppBar(
      title: ResponsiveText(
        title,
        mobileFontSize: 18,
        tabletFontSize: 20,
        desktopFontSize: 22,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor ?? Colors.transparent,
      elevation: elevation ?? 0,
      centerTitle: isMobile,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isExpanded;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.color,
    this.textColor,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    final button = icon != null
        ? ElevatedButton.icon(
            onPressed: onPressed,
            icon: Icon(
              icon,
              size: isMobile ? 16 : 20,
              color: textColor ?? Colors.white,
            ),
            label: ResponsiveText(
              text,
              mobileFontSize: 12,
              tabletFontSize: 14,
              desktopFontSize: 16,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? Colors.teal,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        : ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? Colors.teal,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: isMobile ? 8 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: ResponsiveText(
              text,
              mobileFontSize: 12,
              tabletFontSize: 14,
              desktopFontSize: 16,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          );

    return isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

class ResponsiveSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Function(String)? onChanged;
  final VoidCallback? onClear;

  const ResponsiveSearchBar({
    super.key,
    required this.controller,
    required this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveBreakpoints.isMobile(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 8),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: isMobile ? 14 : 16,
          ),
          prefixIcon: const Icon(Icons.search, color: Colors.tealAccent),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    controller.clear();
                    if (onClear != null) onClear!();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white.withOpacity(0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            vertical: isMobile ? 12 : 16,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
