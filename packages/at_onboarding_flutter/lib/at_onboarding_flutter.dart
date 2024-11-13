library at_onboarding_flutter;

// Re-export some important external dependencies
export 'package:at_backupkey_flutter/at_backupkey_flutter.dart';
export 'package:at_client_mobile/at_client_mobile.dart';

// Core package requirements
export 'src/at_onboarding.dart';
export 'src/at_onboarding_result.dart';
export 'src/utils/at_onboarding_app_constants.dart' show RootEnvironment;
export 'src/services/at_onboarding_config.dart';

// Additional customizations
export './localizations/generated/l10n.dart';
export 'src/services/at_onboarding_theme.dart';
