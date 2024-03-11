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
    case .medium:
      VStack(alignment: .leading) {
        Text(location.name)
          .bold()
        let address = location.postalAddress(style: .short)
        Text(formatter.string(from: address))
          .dynamicTypeSize(.small)
          .foregroundStyle(.secondary)
      }
    case .full:
      VStack(alignment: .leading) {
        Text(location.name)
          .bold()
        let address = location.postalAddress(style: .medium)
        Text(formatter.string(from: address))
          .dynamicTypeSize(.small)
          .foregroundStyle(.secondary)
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
          cell(location: location)
          Divider()
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
