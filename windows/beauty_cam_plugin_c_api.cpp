#include "include/beauty_cam/beauty_cam_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "beauty_cam_plugin.h"

void BeautyCamPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  beauty_cam::BeautyCamPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
