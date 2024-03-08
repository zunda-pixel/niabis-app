import SwiftUI
import NiaBisData
import WidgetKit

struct EntryView : View {
  var entry: Provider.Entry
  
  var body: some View {
    switch entry.state {
    case .placeholder:
      Text("Loading...")
    case .snapshot(let locations), .timeline(let locations):
      VStack(alignment: .leading) {
        ForEach(locations) { location in
          Text(location.name)
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
  
  enum State {
    case placeholder
    case snapshot(locations: [Location])
    case timeline(locations: [Location])
    case error(error: any Error)
  }
}
