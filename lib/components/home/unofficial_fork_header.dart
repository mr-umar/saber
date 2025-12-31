import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UnofficialForkHeader extends StatelessWidget {
  const UnofficialForkHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => launchUrl(Uri.parse('https://github.com/mr-umar/saber')),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Unofficial fork',
              style: TextStyle(
                fontSize: 10,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              FontAwesomeIcons.github,
              size: 10,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}


