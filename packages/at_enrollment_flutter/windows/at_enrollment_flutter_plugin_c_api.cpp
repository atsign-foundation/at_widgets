#include "include/at_enrollment_flutter/at_enrollment_flutter_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "at_enrollment_flutter_plugin.h"

void AtEnrollmentFlutterPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  at_enrollment_flutter::AtEnrollmentFlutterPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
