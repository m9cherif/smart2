#ifndef RUNNER_FLUTTER_WRAPPER_APP_H_
#define RUNNER_FLUTTER_WRAPPER_APP_H_

#include <windows.h>

class FlutterWrapperApp {
 public:
  FlutterWrapperApp();
  ~FlutterWrapperApp();

 protected:
  bool OnCreate();
  void OnDestroy();
};

#endif  // RUNNER_FLUTTER_WRAPPER_APP_H_
