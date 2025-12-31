import 'package:flutter/material.dart';
import 'package:saber/components/home/sentry_consent_dialog.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/sentry/sentry_init.dart';
import 'package:saber/i18n/strings.g.dart';

class SettingsSentryConsent extends StatelessWidget {
  const SettingsSentryConsent({super.key});

  String _getSubtitle() {
    // In this fork, Sentry is hard-disabled
    return t.settings.prefDescriptions.sentry.inactive;
  }

  @override
  Widget build(BuildContext context) {
    final title = t.settings.prefLabels.sentry;
    final subtitle = _getSubtitle();
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      leading: const Icon(Icons.bug_report),
      title: Text(title, style: const TextStyle(fontSize: 18)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, style: const TextStyle(fontSize: 13)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              t.settings.prefDescriptions.sentry.inactive.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
      onTap: null, // Disable interaction
      enabled: false, // Visually indicate it's disabled
    );
  }
}
