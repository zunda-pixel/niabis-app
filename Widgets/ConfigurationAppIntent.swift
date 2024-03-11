import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
  static var title: LocalizedStringResource = "Configuration"
  static var description = IntentDescription("This is an NiaBis widget.")

  @Parameter(title: "Display Style", default: DisplayStyle.medium)
  var displayStyle: DisplayStyle
  
  init() {
    displayStyle = .medium
  }
  
  init(displayStyle: DisplayStyle) {
    self.displayStyle = displayStyle
  }
}

enum DisplayStyle: String, CaseIterable, AppEnum {
  static var typeDisplayRepresentation: TypeDisplayRepresentation {
    "typeDisplayRepresentation"
  }
  
  static var caseDisplayRepresentations: [DisplayStyle : DisplayRepresentation] = [
    .short: .init(title: "Title only"),
    .medium: .init(title: "Title and Image"),
    .full: .init(title: "Title, Image and Address"),
  ]
  
  case short
  case medium
  case full
}
