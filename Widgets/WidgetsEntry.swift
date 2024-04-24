import SwiftUI
import NiaBisData
import WidgetKit
import Contacts

struct EntryView : View {
  var entry: Provider.Entry
  
  let formatter = CNPostalAddressFormatter()
  
  @ViewBuilder
  func cell(location: Location) -> some View {
    switch entry.configuration.displayStyle {
    case .short:
      Text(location.name)
        .font(.callout.bold())
        .lineLimit(1)
    case .medium:
      VStack(alignment: .leading) {
        Text(location.name)
          .font(.callout.bold())
          .lineLimit(1)
        let address = location.postalAddress(style: .short)
        Text(formatter.string(from: address))
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }
    case .full:
      VStack(alignment: .leading) {
        Text(location.name)
          .font(.callout.bold())
          .lineLimit(1)
        let address = location.postalAddress(style: .medium)
        Text(formatter.string(from: address))
          .foregroundStyle(.secondary)
          .lineLimit(1)
      }
    }
  }
  
  var body: some View {
    switch entry.state {
    case .placeholder:
      Text("Loading...")
    case .snapshot(let locations), .timeline(let locations):
      VStack(alignment: .leading) {
        ForEach(locations) { location in
          if locations.first?.id != location.id {
            Divider()
          }
          cell(location: location)
        }
      }
    case .error(let error):
      Text(error.localizedDescription)
    }
  }
}

struct Entry: TimelineEntry {
  let date: Date
  let state: State
  let configuration: ConfigurationAppIntent
  
  enum State {
    case placeholder
    case snapshot(locations: [Location])
    case timeline(locations: [Location])
    case error(error: any Error)
  }
}
