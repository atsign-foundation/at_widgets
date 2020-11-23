import Flutter
import UIKit

public class SwiftAtsignAuthenticationHelperPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "atsign_authentication_helper", binaryMessenger: registrar.messenger())
    let instance = SwiftAtsignAuthenticationHelperPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
