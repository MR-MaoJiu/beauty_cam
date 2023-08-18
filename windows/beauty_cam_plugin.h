#ifndef FLUTTER_PLUGIN_BEAUTY_CAM_PLUGIN_H_
#define FLUTTER_PLUGIN_BEAUTY_CAM_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace beauty_cam {

class BeautyCamPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  BeautyCamPlugin();

  virtual ~BeautyCamPlugin();

  // Disallow copy and assign.
  BeautyCamPlugin(const BeautyCamPlugin&) = delete;
  BeautyCamPlugin& operator=(const BeautyCamPlugin&) = delete;

 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace beauty_cam

#endif  // FLUTTER_PLUGIN_BEAUTY_CAM_PLUGIN_H_
