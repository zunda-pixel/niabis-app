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
    Entry(date: .now, state: .placeholder, configuration: .init())
  }
  
  @MainActor
  func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> Entry {
    do {
      var descriptor = FetchDescriptor<Location>()
      descriptor.fetchLimit = 3
      let locations = try container.mainContext.fetch(descriptor)
      return Entry(date: .now, state: .snapshot(locations: locations), configuration: configuration)
    } catch {
      return Entry(date: .now,  state: .error(error: error), configuration: configuration)
    }
  }
  
  @MainActor
  func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<Entry> {
    do {
      var descriptor = FetchDescriptor<Location>()
      descriptor.fetchLimit = 3
      let locations = try container.mainContext.fetch(descriptor)
      return .init(entries: [Entry(date: .now, state: .timeline(locations: locations), configuration: configuration)], policy: .atEnd)
    } catch {
      return .init(entries: [Entry(date: .now, state: .error(error: error), configuration: configuration)], policy: .atEnd)
    }
  }
}
