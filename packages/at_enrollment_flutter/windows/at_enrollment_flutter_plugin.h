#ifndef FLUTTER_PLUGIN_AT_ENROLLMENT_FLUTTER_PLUGIN_H_
#define FLUTTER_PLUGIN_AT_ENROLLMENT_FLUTTER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace at_enrollment_flutter {

class AtEnrollmentFlutterPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AtEnrollmentFlutterPlugin();

  virtual ~AtEnrollmentFlutterPlugin();

  // Disallow copy and assign.
  AtEnrollmentFlutterPlugin(const AtEnrollmentFlutterPlugin&) = delete;
  AtEnrollmentFlutterPlugin& operator=(const AtEnrollmentFlutterPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace at_enrollment_flutter

#endif  // FLUTTER_PLUGIN_AT_ENROLLMENT_FLUTTER_PLUGIN_H_
