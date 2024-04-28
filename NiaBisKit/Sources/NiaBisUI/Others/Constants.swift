import SwiftUI

public enum Constants {
  public static let redirectToURL = URL(string: "niabis://")!
  public static let appGroup = "group.zunda.niabis"
  public static var appIdentifierPrefix: String {
    var appIdentifierPrefix = Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String
    if appIdentifierPrefix.last == "." {
      appIdentifierPrefix.removeLast()  // remove [.] dot
    }
    return appIdentifierPrefix
  }

  public static var bundleIdentifier: String = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
  
  public static let presentationDetents:  [PresentationDetent] = [.height(300), .height(100), .large]
  public static let privateCloudKitDatabaseName = "iCloud.com.zunda.niabis"
  public static let niabisAPIToken = ""
  public static let cloudflareImagesAccountHashId = ""
}
