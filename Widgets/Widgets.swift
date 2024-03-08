import WidgetKit
import SwiftUI
import SwiftData
import NiaBisData
import NiaBisUI

struct Provider: AppIntentTimelineProvider {
  let container = try! ModelContainer(
    for: Location.self,
    configurations: ModelConfiguration(
      cloudKitDatabase: .private(Constants.privateCloudKitDatabaseName)
    )
  )

  func placeholder(in context: Context) -> Entry {
    Entry(date: .now, state: .placeholder)
  }
  
  @MainActor
  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> Entry {
    do {
      let locations = try container.mainContext.fetch(FetchDescriptor<Location>())
      return Entry(date: .now, state: .snapshot(locations: locations))
    } catch {
      return Entry(date: .now,  state: .error(error: error))
    }
  }
  
  @MainActor
  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<Entry> {
    do {
      let locations = try container.mainContext.fetch(FetchDescriptor<Location>())
      return .init(entries: [Entry(date: .now, state: .timeline(locations: locations))], policy: .atEnd)
    } catch {
      return .init(entries: [Entry(date: .now, state: .error(error: error))], policy: .atEnd)
    }
  }
}
