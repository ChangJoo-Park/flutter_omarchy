import 'package:flutter/widgets.dart';
import 'package:flutter_omarchy/src/theme/colors.dart';
import 'package:flutter_omarchy/src/theme/theme.dart';
import 'package:flutter_omarchy/src/widgets/utils/default_foreground.dart';
import 'package:flutter_omarchy/src/widgets/utils/grouping.dart';
import 'package:flutter_omarchy/src/widgets/utils/pointer_area.dart';
import 'package:flutter_omarchy/src/widgets/utils/side_positioning.dart';

class OmarchyStatusBar extends StatelessWidget {
  const OmarchyStatusBar({super.key, this.leading, this.trailing});

  final List<Widget>? leading;
  final List<Widget>? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    return ClipRect(
      child: Container(
        height: (theme.text.normal.fontSize ?? 14) * 1.8,
        color: theme.colors.normal.black,
        child: DefaultTextStyle(
          style: DefaultTextStyle.of(context).style,
          maxLines: 1,
          child: Row(
            children: [
              if (leading case final leading?)
                Expanded(
                  child: SidePositioning(
                    position: SidePosition.leading,
                    child: Stack(
                      children: [
                        ListView(
                          scrollDirection: Axis.horizontal,
                          children: [...leading.group(), SizedBox(width: 24)],
                        ),
                        Positioned(
                          width: 24,
                          top: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  theme.colors.normal.black.withValues(
                                    alpha: 0,
                                  ),
                                  theme.colors.normal.black,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(child: SizedBox()),
              if (trailing case final trailing?)
                Flexible(
                  flex: 0,
                  fit: FlexFit.tight,
                  child: SidePositioning(
                    position: SidePosition.leading,
                    child: ListView(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      children: [...trailing..group()].reversed.toList(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum OmarchyStatusColor { black, blue }

class OmarchyStatus extends StatelessWidget {
  const OmarchyStatus({
    super.key,
    required this.child,
    this.accent = AnsiColor.white,
    this.onTap,
  });

  final Widget child;
  final AnsiColor accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = OmarchyTheme.of(context);
    final normal = theme.colors.normal[accent];
    final bright = theme.colors.bright[accent];
    if (onTap != null) {
      return PointerArea(
        onTap: onTap,
        builder: (context, state, child) {
          return AnimatedContainer(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            duration: const Duration(milliseconds: 120),
            decoration: BoxDecoration(
              color: switch (state) {
                PointerState(isPressed: true) => normal.withValues(alpha: 0.4),
                PointerState(isHovering: true) => normal.withValues(alpha: 0.3),
                _ => normal.withValues(alpha: 0.2),
              },
            ),
            child: DefaultForeground(
              foreground: bright,
              child: Center(child: this.child),
            ),
          );
        },
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      color: normal.withValues(alpha: 0.3),
      child: DefaultForeground(foreground: bright, child: child),
    );
  }
}
