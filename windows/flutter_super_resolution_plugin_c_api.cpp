#include "include/flutter_super_resolution/flutter_super_resolution_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "flutter_super_resolution_plugin.h"

void FlutterSuperResolutionPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  flutter_super_resolution::FlutterSuperResolutionPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
