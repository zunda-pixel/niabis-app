import WidgetKit
import SwiftUI

struct Widgets: Widget {
  let kind: String = "Widgets"
  
  var body: some WidgetConfiguration {
    AppIntentConfiguration(
      kind: kind,
      intent: ConfigurationAppIntent.self,
      provider: Provider()
    ) { entry in
      EntryView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
  }
}

#Preview(as: .systemSmall) {
  Widgets()
} timeline: {
  Entry(
    date: .now,
    state: .timeline(
      locations: [
        .init(
          id: .init(),
          name: "Apple Park",
          content: "content",
          createdDate: .now,
          postalCode: "94122",
          country: "United State",
          state:  "CA",
          city: "San Francisco",
          subAdministrativeArea: nil,
          subLocality: nil,
          street: "1231 Ninth Ave",
          tags: [],
          photoIDs: [],
          photoDatas: []
        )
      ]
    ),
    configuration: .init(displayStyle: .full)
  )
}
