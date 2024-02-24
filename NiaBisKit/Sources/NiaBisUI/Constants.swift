import Foundation

enum Constants {
  static let redirectToURL = URL(string: "niabis://")!
  static public let appGroup = "group.zunda.niabis"
  static var appIdentifierPrefix: String {
    var appIdentifierPrefix = Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String
    if appIdentifierPrefix.last == "." {
      appIdentifierPrefix.removeLast()  // remove [.] dot
    }
    return appIdentifierPrefix
  }
  
  static var bundleIdentifier: String = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
}
