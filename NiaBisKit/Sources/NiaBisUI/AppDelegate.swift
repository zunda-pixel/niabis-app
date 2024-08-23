import SwiftUI
import MetricKit
import Sentry

public final class AppDelegate: NSObject, UIApplicationDelegate {
  public func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    MXMetricManager.shared.add(self)
    let options = Sentry.Options()
    options.dsn = SecretConstants.sentryDsnURL.absoluteString
    options.tracesSampleRate = 1.0
    options.attachScreenshot = true
    options.attachViewHierarchy = true
    options.enableMetricKit = true
    options.enableMetricKitRawPayload = true
    SentrySDK.start(options: options)
    return true
  }
  
  public func applicationWillTerminate(_ application: UIApplication) {
    MXMetricManager.shared.remove(self)
  }
}

extension AppDelegate: MXMetricManagerSubscriber {
  nonisolated public func didReceive(_ payloads: [MXMetricPayload]) {
    var attachments: [Attachment] = []
    for payload in payloads {
      let attachment = Attachment(data: payload.jsonRepresentation(), filename: "MXMetricPayload.json")
      attachments.append(attachment)
    }
    
    SentrySDK.capture(message: "MetricKit received MXMetricPayload.") { scope in
      attachments.forEach { scope.addAttachment($0) }
    }
  }
  nonisolated public func didReceive(_ payloads: [MXDiagnosticPayload]) {
    var attachments: [Attachment] = []

    for payload in payloads {
      let attachment = Attachment(data: payload.jsonRepresentation(), filename: "MXDiagnosticPayload.json")
      attachments.append(attachment)
    }
    
    SentrySDK.capture(message: "MetricKit received MXDiagnosticPayload.") { scope in
      attachments.forEach { scope.addAttachment($0) }
    }
  }
}

