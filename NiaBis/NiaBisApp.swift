import SwiftUI
import SwiftData
import NiaBisUI

@main
struct NiaBisApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      ContentView()
    }
  }
}
